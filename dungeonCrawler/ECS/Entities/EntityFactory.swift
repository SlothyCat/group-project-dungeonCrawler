//
//  EntityFactory.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 11/3/26.
//

import Foundation
import simd

public enum EntityFactory {
    
    // MARK: - Player
    //
    // Components attached:
    //   • TransformComponent  — position, rotation, scale
    //   • VelocityComponent   — movement vector (starts at zero)
    //   • InputComponent      — intent from InputSystem
    //   • SpriteComponent     — visual representation
    //   • PlayerTag           — marks this as the human-controlled entity
    //   • HealthComponent     — current/max HP; entity destroyed at 0
    //   • MoveSpeedComponent  — scalar speed used by MovementSystem
    //
    // Future additions:
    //   • WeaponSlotComponent — which weapon is equipped
    //   • AnimationComponent  — walk / idle / attack animation state machine
    
    @discardableResult
    public static func makePlayer(
        in world: World,
        at position: SIMD2<Float>,
        textureName: String = "knight", // set to knight for now
        scale: Float = 1
    ) -> Entity {
        let entity = world.createEntity()
        
        world.addComponent(component: TransformComponent(position: position, rotation: 0, scale: scale), to: entity)
        world.addComponent(component: VelocityComponent(), to: entity)
        world.addComponent(component: InputComponent(), to: entity)
        world.addComponent(component: SpriteComponent(textureName: textureName), to: entity)
        world.addComponent(component: CollisionBoxComponent(size: SIMD2<Float>(28, 28)), to: entity)
        world.addComponent(component: PlayerTagComponent(), to: entity)
        world.addComponent(component: CameraFocusComponent(), to: entity)
        world.addComponent(component: HealthComponent(base: 100), to: entity)
        world.addComponent(component: MoveSpeedComponent(base: 90), to: entity)

        return entity
    }

    // MARK: - Enemy
    //
    // Components attached:
    //   • TransformComponent  — position, rotation, scale
    //   • SpriteComponent     — visual representation
    //   • EnemyTagComponent   — marks this as an enemy and holds its type
    //
    // Future additions:
    //   • HealthComponent      — current / max health
    //   • CombatStatsComponent — attack damage, attack speed
    //   • AIComponent          — movement behaviour state machine

    @discardableResult
    public static func makeEnemy(
        in world: World,
        at position: SIMD2<Float>,
        type: EnemyType,
        scale: Float = 1
    ) -> Entity {
        let entity = world.createEntity()

        world.addComponent(component: TransformComponent(position: position, rotation: 0, scale: scale), to: entity)
        world.addComponent(component: SpriteComponent(textureName: type.textureName), to: entity)
        world.addComponent(component: EnemyTagComponent(enemyType: type), to: entity)

        return entity
    }
    
    // MARK: - Room Factory
        
    // Creates a room entity with all necessary components
    //
    // Components attached:
    //   • RoomComponent       — bounds, doorways, spawn points
    //   • TransformComponent  — position at room center (for spatial queries)
    //
    // Future additions:
    //   • RoomThemeComponent  — visual style (dungeon, forest, ice cave)
    //   • RoomLootComponent   — treasure chest spawn points
    
    @discardableResult
    public static func makeRoom(
        in world: World,
        bounds: RoomBounds,
        doorways: [Doorway] = [],
        spawnPoints: [SpawnPoint] = [],
        useGrid: Bool = false
    ) -> Entity {
        let entity = world.createEntity()
        var roomComponent = RoomComponent(bounds: bounds, doorways: doorways, spawnPoints: spawnPoints)
        
        // Optionally add grid layout for tile-based generation
        if useGrid {
            let gridSize = SIMD2<Int>(
                Int(bounds.size.x / 32), // 32 units per tile
                Int(bounds.size.y / 32)
            )
            roomComponent.gridLayout = GridLayout(gridSize: gridSize, cellSize: 32)
        }
        
        world.addComponent(component: roomComponent, to: entity)
        world.addComponent(component: TransformComponent(position: bounds.center), to: entity)
        
        return entity
    }
}
