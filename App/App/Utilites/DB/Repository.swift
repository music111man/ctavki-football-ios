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

    static var db: Connection? {
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
    
    static func initTable<T: DBComparable>(t: T.Type) {
        do {
            try Self.db?.transaction {

                    try Self.db?.run(t.table.create(ifNotExists: true) { builder in
                        t.createColumns(builder: builder)
                    })

            }
        } catch let error {
            printAppEvent(error.localizedDescription)
        }
    }
    
    @discardableResult
    static func refreshData<T: DBComparable>(_ items: [T]) -> Bool {
        defer { semaphore.signal() }
        semaphore.wait()
        var deletedCount: Int = 0
        var insertCount: Int64 = 0
        if items.isEmpty { return false }
        do {
            try Self.db?.transaction {
                
                deletedCount = try Self.db?.run(T.table.delete()) ?? 0
                printAppEvent("delete \(deletedCount) old records from \(T.self)s")
                insertCount = try Self.db?.run(T.table.insertMany(or: .replace, items.map({ $0.setters }))) ?? 0
                printAppEvent("insert \(insertCount) new records to \(T.self)s")
            }
            
        } catch let error {
            printAppEvent("Repository error: \(error.localizedDescription)")
        }
        
        return deletedCount + Int(insertCount) > 0
    }
    
    static func select<T: DBComparable>(_ query: Table? = nil) -> [T]  {
        defer { semaphore.signal() }
        semaphore.wait()
        var result = [T]()
        do {
            let mapRowIterator = try db?.prepareRowIterator(query ?? T.table)
            while let row = try mapRowIterator?.failableNext() {
                result.append(T(row: row))
            }
            
        } catch let error {
            printAppEvent("\(error)")
            return []
        }
        
        return result
    }
    
    static func selectTop<T: DBComparable>(_ query: Table) -> T?  {
        defer { semaphore.signal() }
        semaphore.wait()
        do {
            if let row = try db?.pluck(query) {
               return T(row: row)
            }
            return nil
            
        } catch let error {
            printAppEvent("\(error)")
            return nil
        }
    }
    
    static func count(_ selectQuery: Table) -> Int  {
        defer { semaphore.signal() }
        semaphore.wait()
        do {
            return try db?.scalar(selectQuery.count) ?? 0
            
        } catch let error {
            printAppEvent("\(error)")
            return 0
        }
    }
    
    static func scalar<V: Value>(_ query: ScalarQuery<V>) throws -> V?  {
        defer { semaphore.signal() }
        semaphore.wait()
        do {
            return try db?.scalar(query) ?? nil
            
            
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
