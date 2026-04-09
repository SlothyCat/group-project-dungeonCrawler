//
//  EnemyStateComponent.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 17/3/26.
//

import Foundation

public struct EnemyStateComponent: Component {
    public var strategy: any EnemyStrategy

    public init(strategy: any EnemyStrategy = StandardStrategy()) {
        self.strategy = strategy
    }
}
