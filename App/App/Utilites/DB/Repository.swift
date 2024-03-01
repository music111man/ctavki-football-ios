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
            print("Open db \(fileUrl.path)")
            Self.con = try Connection(fileUrl.path)
            try Team.createTable(db: Self.con!)
            try Faq.createTable(db: Self.con!)
            try Bet.createTable(db: Self.con!)
            try BetType.createTable(db: Self.con!)
        } catch let error {
            print(error)
        }
        
        return con
    }
    
    static func refreshData<T: DBComparable>(_ items: [T]) -> Bool {
        defer { semaphore.signal() }
        semaphore.wait()
        var deletedCount: Int = 0
        var insertCount: Int64 = 0
        if items.isEmpty { return false }
        do {
            try Self.connection?.transaction {
                deletedCount = try Self.connection?.run(T.table.filter(T.idField < items.min(by: { item1, item2 in
                    item1.id < item2.id
                })?.id ?? 0 ).delete()) ?? 0
                print("delete \(deletedCount) old records from \(T.self)s")
                insertCount = try Self.connection?.run(T.table.insertMany(or: .replace, items.map({ $0.setters }))) ?? 0
                print("insert \(insertCount) new records to \(T.self)s")
            }
            
        } catch let error {
            print(error)
        }
        return (Int64(deletedCount) + insertCount) > 0
    }
}

protocol DBComparable {
    static var table: Table { get }
    static var idField: Expression<Int> { get }
    
    var setters: [Setter] { get }
    var id: Int { get }
}
