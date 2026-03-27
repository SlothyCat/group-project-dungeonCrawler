//
//  CommandQueue.swift
//  dungeonCrawler
//
//  Created by Letian on 27/3/26.
//

import Foundation

final class CommandQueue<C: Command>: Cancellable {
    private var buffer: RingBuffer<C>
    
    init(capacity: Int) {
        self.buffer = RingBuffer(capacity: capacity)
    }
    
    func enqueue(_ command: C) {
        buffer.push(command)
    }
    
    func dequeue() -> (C)? {
        return buffer.pop()
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
