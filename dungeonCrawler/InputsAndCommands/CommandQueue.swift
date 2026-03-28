//
//  CommandQueue.swift
//  dungeonCrawler
//
//  Created by Letian on 27/3/26.
//

import Foundation

final class CommandQueue<C: Command>: Cancellable {
    private var buffer: RingQueue<C>
    
    init(capacity: Int) {
        self.buffer = RingQueue(capacity: capacity)
    }
    
    func enqueue(_ command: C) {
        buffer.push(command)
    }
    
    func dequeue() -> C? {
        return buffer.pop()
    }
    
    func peek() -> C? {
        return buffer.peek()
    }

    func cancel(commandId: CommandId) {
        buffer.modifyFirst(
            where: { $0?.id == commandId }) { slot in
                slot = nil
            }
    }
}

protocol Cancellable {
    func cancel(commandId: CommandId)
}
