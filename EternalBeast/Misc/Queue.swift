//
//  Queue.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 19/05/2021.
//

import Foundation

class Queue<T> {
    private var queue: [T]

    init() {
        self.queue = []
    }

    // Push item to the queue
    func push(_ item: T) {
        self.queue.append(item)
    }

    // Pop item from the queue
    func pop() ->T? {
        if queue.isEmpty {
            return nil
        }

        let item = queue.first
        queue.removeFirst()
        return item
    }

    // Remove all items from the queue
    func clear() {
        self.queue.removeAll()
    }

    // Return first item of the queue
    func first() -> T? {
        return queue.first
    }

    func items() -> [T] {
        return queue
    }

    func insert(_ item: T, at index: Int) {
        queue.insert(item, at: index)
    }

    // Return true if the queue is empty, false otherwise
    func isEmpty() -> Bool {
        return queue.isEmpty
    }
}
