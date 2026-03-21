//
//  FacingComponent.swift
//  dungeonCrawler
//
//  Created by Letian on 20/3/26.
//

import Foundation

public struct FacingComponent: Component {
    var facing: FacingType
    
    init(facing: FacingType) {
        self.facing = facing
    }
    
    init() {
        // force unwrap here is safe since the enum has at least one case,
        // as randomElement() only returns nil for empty collections.
        self.facing = FacingType.allCases.randomElement()!
    }
}

enum FacingType: CaseIterable {
    case left
    case right
}
