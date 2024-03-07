//
//  Repository.swift
//  App
//
//  Created by Denis Shkultetskyy on 01.03.2024.
//

import Foundation
import SQLite

final class Repository {
    
    private init() {}
    private static let semaphore = DispatchSemaphore(value: 1)
    static let dbName = "ctavki.sqlite3"
    private static var con: Connection?

    static var connection: Connection? {
        if Self.con != nil { return con }
        do {
            let fileUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(Self.dbName)
            printAppEvent("Open db \(fileUrl.path)")
            Self.con = try Connection(fileUrl.path)
        } catch let error {
            printAppEvent("\(error)")
        }
        
        return con
    }
    @discardableResult
    static func refreshData<T: DBComparable>(_ items: [T]) -> Bool {
        defer { semaphore.signal() }
        semaphore.wait()
        var deletedCount: Int = 0
        var insertCount: Int64 = 0
        if items.isEmpty { return false }
        do {
            try Self.connection?.transaction {
                try Self.connection?.run(T.table.create(ifNotExists: true) { builder in
                    T.createColumns(builder: builder)
                })
                
                deletedCount = try Self.connection?.run(T.table.delete()) ?? 0
                printAppEvent("delete \(deletedCount) old records from \(T.self)s")
                insertCount = try Self.connection?.run(T.table.insertMany(or: .replace, items.map({ $0.setters }))) ?? 0
                printAppEvent("insert \(insertCount) new records to \(T.self)s")
            }
            
        } catch let error {
            print(error)
        }
        
        return deletedCount + Int(insertCount) > 0
    }
    
    static func selectData<T: DBComparable>(_ selectQuery: Table? = nil) -> [T]  {
        defer { semaphore.signal() }
        semaphore.wait()
        var result = [T]()
        do {
            let mapRowIterator = try connection?.prepareRowIterator(selectQuery ?? T.table)
            while let row = try mapRowIterator?.failableNext() {
                result.append(T(row: row))
            }
            
        } catch let error {
            printAppEvent("\(error)")
            return []
        }
        
        return result
    }
    
    static func scalarData<T: DBComparable>(_ selectQuery: Table) -> T?  {
        defer { semaphore.signal() }
        semaphore.wait()
        do {
            let mapRowIterator = try connection?.prepareRowIterator(selectQuery)
            if let row = try mapRowIterator?.failableNext() {
               return T(row: row)
            }
            return nil
            
        } catch let error {
            printAppEvent("\(error)")
            return nil
        }
    }
}

protocol DBComparable {
    static var table: Table { get }
    static var idField: Expression<Int> { get }
    
    static func createColumns(builder: TableBuilder)
    
    init(row: Row)
    
    var setters: [Setter] { get }
    var id: Int { get }
}
