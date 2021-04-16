//
//  AtomicArray.swift
//  RC.Pay
//
//  Created by mac on 04.02.2021.
//  Copyright © 2021 Олег Герман. All rights reserved.
//

import Foundation

protocol Atomicable {
    func lock()
    func unlock()
}

final class SpinLock: Atomicable {
    private var unfairLock = os_unfair_lock_s()

    func lock() {
        os_unfair_lock_lock(&unfairLock)
    }

    func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}

final class AtomicArray<Element: URLSessionTask> {
    private let locker: Atomicable
    private var array = [Element]()

    init(locker: Atomicable = SpinLock()) {
        self.locker = locker
    }
}

// MARK: - Properties
extension AtomicArray {

    var count: Int {
        locker.lock()
        defer {
            locker.unlock()
        }

        return array.count
    }

    var isEmpty: Bool {
        locker.lock()
        defer {
            locker.unlock()
        }

        return array.isEmpty
    }

    var isNotEmpty: Bool {
        locker.lock()
        defer {
            locker.unlock()
        }
        return !array.isEmpty
    }

    var capacity: Int {
        locker.lock()
        defer {
            locker.unlock()
        }
        return array.capacity
    }

    var description: String {
        locker.lock()
        defer {
            locker.unlock()
        }
        return array.description
    }
}

//MARK: - Immutabale
extension AtomicArray {

    func reserveCapacity(minimumCapacity: Int) {
        locker.lock()
        defer {
            locker.unlock()
        }
        array.reserveCapacity(minimumCapacity)
    }

    func reserveCapacity(n: Int) {
        locker.lock()
        defer {
            locker.unlock()
        }
        array.reserveCapacity(n)
    }
}

//MARK: - Mutable
extension AtomicArray {

    func append(_ element: Element) {
        locker.lock()
        defer {
            locker.unlock()
        }

        array.append(element)
    }

    func append(_ elements: [Element]) {
        locker.lock()
        defer {
            locker.unlock()
        }

        array.append(contentsOf: elements)
    }

    func remove(at index: Int) {
        locker.lock()
        defer {
            locker.unlock()
        }

        array.remove(at: index)
    }

    func remove(_ element: Element) {
        locker.lock()
        defer {
            locker.unlock()
        }

        array.removeAll(where: { $0 == element })
    }

    func removeAll(keepingCapacity isKeeping: Bool) {
        locker.lock()
        defer {
            locker.unlock()
        }

        array.removeAll(keepingCapacity: isKeeping)
    }

    func removeAll() {
        locker.lock()
        defer {
            locker.unlock()
        }

        array.removeAll()
    }
}

extension AtomicArray {
    func compactMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {

        locker.lock()
        defer {
            locker.unlock()
        }

        return array.compactMap(transform)
    }

    func getArray() -> [Element] {
        locker.lock()
        defer {
            locker.unlock()
        }

        return array
    }
}

extension AtomicArray where Element: Equatable {

    func containts(_ element: Element) -> Bool {
        locker.lock()
        defer {
            locker.unlock()
        }

        return array.contains(element)
    }
}

extension AtomicArray {
    func cancelAll() {
        locker.lock()
        defer {
            locker.unlock()
        }

        array.forEach({ $0.cancel() })
    }
}
