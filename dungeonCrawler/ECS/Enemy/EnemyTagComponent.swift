//
//  EnemyTagComponent.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 16/3/26.
//

import Foundation

public struct EnemyTagComponent: Component {
    public let enemyType: EnemyType

    public init(enemyType: EnemyType) {
        self.enemyType = enemyType
    }
}
