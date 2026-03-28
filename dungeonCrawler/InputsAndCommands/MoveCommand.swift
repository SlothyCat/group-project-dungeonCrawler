//
//  MoveCommand.swift
//  dungeonCrawler
//
//  Created by Letian on 28/3/26.
//

import Foundation
import simd

struct MoveCommand: Command {
    var id: CommandId
    
    var rawMoveVector: SIMD2<Float>
}
