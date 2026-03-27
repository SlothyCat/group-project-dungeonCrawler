//
//  Command.swift
//  dungeonCrawler
//
//  Created by Letian on 27/3/26.
//

import Foundation

typealias CommandId = UUID

protocol Command {
    var id: CommandId { get }
}
