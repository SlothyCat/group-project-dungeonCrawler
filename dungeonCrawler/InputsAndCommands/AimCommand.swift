//
//  AimCommand.swift
//  dungeonCrawler
//
//  Created by Letian on 28/3/26.
//

import Foundation
import simd

struct AimCommand: Command {
    var id: CommandId
    
    var rawAimVector: SIMD2<Float>
}
