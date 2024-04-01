//
//  Repository.swift
//  App
//
//  Created by Denis Shkultetskyy on 01.03.2024.
//

import Foundation
import SQLite
import RxSwift

final class Repository {
    
    private init() {}
    private static let semaphore = DispatchSemaphore(value: 1)
    static let dbName = "ctavki.sqlite3"
    private static var con: SQLite.Connection?
    private static let dispatchQueue = DispatchQueue(label: dbName,
                                                     qos: .default,
                                                     attributes: .concurrent)
    private static let globalScheduler = ConcurrentDispatchQueueScheduler(queue: dispatchQueue)
    
    static var db: SQLite.Connection {
        if let con = Self.con { return con }
        do {
            let fileUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(Self.dbName)
            printAppEvent("Open db \(fileUrl.path)", marker: ">>")
            Self.con = try SQLite.Connection(fileUrl.path)
        } catch let error {
            printAppEvent("\(error)")
        }
        
        return con!
    }
    
    static func initDB(ts: [DBComparable.Type]) {
        do {
            try Self.db.transaction {
                for t in ts {
                    try Self.db.run(t.table.create(ifNotExists: true) { builder in
                        t.createColumns(builder: builder)
                    })
                }
            }
        } catch let error {
            printAppEvent(error.localizedDescription)
        }
        
    }
    
    @discardableResult
    static func refreshData<T: DBComparable>(_ items: [T]) -> Bool {
        var deletedCount: Int = 0
        var insertCount: Int64 = 0
        if items.isEmpty { return false }
        do {
            try Self.db.transaction {
                deletedCount = try Self.db.run(T.table.delete())
                insertCount = try Self.db.run(T.table.insertMany(or: .replace, items.map { $0.setters } ))
            }
            
        } catch let error {
            printAppEvent("Repository error: \(error.localizedDescription)", marker: ">>db ")
        }
        
        return deletedCount + Int(insertCount) > 0
    }
    
    static func `async`(_ function: @escaping () -> ()) {
        dispatchQueue.async(flags: .barrier) {
            function()
        }
    }
    
    static func selectObservable<T: DBComparable>(_ query: Table? = nil) -> Observable<[T]> {
        Observable<[T]>.create {observer in
            let result: [T] = Self.select(query)
            observer.onNext(result)
            observer.onCompleted()
    
            return Disposables.create()
        }.subscribe(on: globalScheduler)
    }
    
    static func select<T: DBComparable>(_ query: Table? = nil) -> [T]  {
        var result = [T]()
        do {
            let mapRowIterator = try? db.prepareRowIterator(query ?? T.table)
            while let row = try mapRowIterator?.failableNext() {
                result.append(T(row: row))
            }
            
        } catch let error {
            printAppEvent("\(error)", marker: ">>db ")
            return []
        }
        
        return result
    }
    
    static func selectTopObservable<T: DBComparable>(_ query: Table) -> Observable<T?> {
        Observable<T?>.create {observer in
            let result: T? = Self.selectTop(query)
            observer.onNext(result)
            observer.onCompleted()
    
            return Disposables.create()
        }.subscribe(on: globalScheduler)
    }
    
    static func selectTop<T: DBComparable>(_ query: Table) -> T?  {
        do {
            if let row = try db.pluck(query) {
               return T(row: row)
            }
            return nil
            
        } catch let error {
            printAppEvent("\(error)", marker: ">>db ")
            return nil
        }
    }
    static func countObservable(_ selectQuery: Table) -> Observable<Int> {
        Observable<Int>.create { observer in
            let result = Self.count(selectQuery)
            observer.onNext(result)
            observer.onCompleted()
    
            return Disposables.create()
        }.subscribe(on: globalScheduler)
    }
    
    static func count(_ selectQuery: Table) -> Int  {
        do {
            return try db.scalar(selectQuery.count)
            
        } catch let error {
            printAppEvent("\(error)", marker: ">>db ")
            return 0
        }
    }
    static func scalarObservable<V: Value>(_ query: Table) -> Observable<V?> {
        Observable<V?>.create { observer in
            let result: V? = Self.scalar(query)
            observer.onNext(result)
            observer.onCompleted()
    
            return Disposables.create()
        }.subscribe(on: globalScheduler)
    }
    static func scalar<V: Value>(_ query: Table) -> V? {
        do {
            let expression = query.expression
            
            return try db.scalar(expression.template, expression.bindings) as? V
            
            
        } catch let error {
            printAppEvent("\(error)", marker: ">>db ")
            return nil
        }
    }
}

protocol DBComparable {
    static var table: Table { get }
    static var idField: Expression<Int> { get }
    
    static func createColumns(builder: SQLite.TableBuilder)
    
    init(row: Row)
    
    var setters: [Setter] { get }
    var id: Int { get }
}
