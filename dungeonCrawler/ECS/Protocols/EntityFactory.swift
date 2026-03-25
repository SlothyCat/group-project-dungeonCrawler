//
//  EntityFactory.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 24/3/26.
//

public protocol EntityFactory {
    @discardableResult
    func make(in world: World) -> Entity
}
