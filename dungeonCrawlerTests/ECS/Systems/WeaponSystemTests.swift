import Foundation
import XCTest
import simd
@testable import dungeonCrawler

@MainActor
final class WeaponSystemTests: XCTestCase {

    var world: World!
    var system: WeaponSystem!

    override func setUp() {
        super.setUp()
        world = World()
        system = WeaponSystem()
    }

    override func tearDown() {
        system = nil
        world = nil
        super.tearDown()
    }

    // MARK: - Helpers

    @discardableResult
    private func makeWeaponWithOwner(
        ownerPosition: SIMD2<Float> = .zero,
        ownerVelocity: SIMD2<Float> = .zero,
        offset: SIMD2<Float> = SIMD2(10, -5),
        isShooting: Bool = false,
        aimDirection: SIMD2<Float> = SIMD2(1, 0),
        coolDownInterval: TimeInterval = 1.0,
        lastFiredAt: Float = 0
    ) -> (owner: Entity, weapon: Entity) {
        let owner = world.createEntity()
        world.addComponent(component: TransformComponent(position: ownerPosition), to: owner)
        world.addComponent(component: VelocityComponent(linear: ownerVelocity), to: owner)
        world.addComponent(component: InputComponent(
            moveDirection: .zero,
            aimDirection: aimDirection,
            isShooting: isShooting
        ), to: owner)

        let weapon = world.createEntity()
        world.addComponent(component: TransformComponent(position: ownerPosition + offset), to: weapon)
        world.addComponent(component: VelocityComponent(), to: weapon)
        world.addComponent(component: OwnerComponent(ownerEntity: owner, offset: offset), to: weapon)
        world.addComponent(component: WeaponComponent(
            type: .handgun,
            manaCost: 0,
            attackSpeed: 1,
            coolDownInterval: coolDownInterval,
            lastFiredAt: lastFiredAt
        ), to: weapon)

        return (owner, weapon)
    }

    private func getSpawnedProjectiles() -> [Entity] {
        world.entities(with: ProjectileComponent.self)
    }

    // Position, mirrow offset

    func testWeaponPositionFollowsOwnerFacingRight() {
        let (_, weapon) = makeWeaponWithOwner(
            ownerPosition: SIMD2(100, 50),
            ownerVelocity: SIMD2(1, 0),
            offset: SIMD2(10, -5)
        )

        system.update(deltaTime: 0.1, world: world)

        let transform = world.getComponent(type: TransformComponent.self, for: weapon)!
        // offset unmirrored: 100 + 10 = 110, 50 + (-5) = 45
        XCTAssertEqual(transform.position.x, 110, accuracy: 0.01)
        XCTAssertEqual(transform.position.y, 45, accuracy: 0.01)
    }

    func testWeaponOffsetXMirroredWhenFacingLeft() {
        let (_, weapon) = makeWeaponWithOwner(
            ownerPosition: SIMD2(100, 50),
            ownerVelocity: SIMD2(-1, 0),
            offset: SIMD2(10, -5)
        )

        system.update(deltaTime: 0.1, world: world)

        let transform = world.getComponent(type: TransformComponent.self, for: weapon)!
        // offset.x negated: 100 + (-10) = 90, y unchanged: 50 + (-5) = 45
        XCTAssertEqual(transform.position.x, 90, accuracy: 0.01)
        XCTAssertEqual(transform.position.y, 45, accuracy: 0.01)
    }

    func testWeaponYOffsetUnchangedWhenFacingRight() {
        let (_, weapon) = makeWeaponWithOwner(ownerVelocity: SIMD2(1, 0), offset: SIMD2(10, -5))
        system.update(deltaTime: 0.1, world: world)
        let y = world.getComponent(type: TransformComponent.self, for: weapon)!.position.y
        XCTAssertEqual(y, -5, accuracy: 0.01)
    }

    func testWeaponYOffsetUnchangedWhenFacingLeft() {
        let (_, weapon) = makeWeaponWithOwner(ownerVelocity: SIMD2(-1, 0), offset: SIMD2(10, -5))
        system.update(deltaTime: 0.1, world: world)
        let y = world.getComponent(type: TransformComponent.self, for: weapon)!.position.y
        XCTAssertEqual(y, -5, accuracy: 0.01)
    }

    func testWeaponDefaultsFacingRightWhenVelocityIsZero() {
        let (_, weapon) = makeWeaponWithOwner(
            ownerPosition: .zero,
            ownerVelocity: .zero,
            offset: SIMD2(10, -5)
        )

        system.update(deltaTime: 0.1, world: world)

        let transform = world.getComponent(type: TransformComponent.self, for: weapon)!
        // zero velocity → facingRight = true → offset.x positive
        XCTAssertEqual(transform.position.x, 10, accuracy: 0.01)
        XCTAssertEqual(transform.position.y, -5, accuracy: 0.01)
    }

    func testWeaponTracksOwnerAfterOwnerMoves() {
        let (owner, weapon) = makeWeaponWithOwner(
            ownerPosition: SIMD2(0, 0),
            ownerVelocity: SIMD2(1, 0),
            offset: SIMD2(10, 0)
        )

        system.update(deltaTime: 0.1, world: world)

        // Move owner
        world.modifyComponent(type: TransformComponent.self, for: owner) { t in
            t.position = SIMD2(50, 0)
        }
        system.update(deltaTime: 0.1, world: world)

        let transform = world.getComponent(type: TransformComponent.self, for: weapon)!
        XCTAssertEqual(transform.position.x, 60, accuracy: 0.01)
    }

    // Cooldown

    func testWeaponDoesNotFireBeforeCooldownElapses() {
        makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 1.0,
            lastFiredAt: 0
        )

        // gameTime after update = 0.5, cooldown = 1.0 → not ready
        system.update(deltaTime: 0.5, world: world)

        XCTAssertTrue(getSpawnedProjectiles().isEmpty)
    }

    func testWeaponFiresWhenCooldownElapsed() {
        makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        // gameTime = 1.0 >= cooldown 0.5 → fires
        system.update(deltaTime: 1.0, world: world)

        XCTAssertEqual(getSpawnedProjectiles().count, 1)
    }

    func testWeaponUpdatesLastFiredAtAfterFiring() {
        let (_, weapon) = makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world)

        let weaponComp = world.getComponent(type: WeaponComponent.self, for: weapon)!
        XCTAssertEqual(weaponComp.lastFiredAt, 1.0, accuracy: 0.001)
    }

    func testWeaponDoesNotFireAgainWithinCooldown() {
        makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 1.0,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world) // fires, lastFiredAt = 1.0
        system.update(deltaTime: 0.5, world: world) // gameTime = 1.5, diff = 0.5 < 1.0 → blocked

        XCTAssertEqual(getSpawnedProjectiles().count, 1)
    }

    func testWeaponFiresAgainAfterCooldownResets() {
        makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 1.0,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world) // fires, lastFiredAt = 1.0
        system.update(deltaTime: 1.0, world: world) // gameTime = 2.0, diff = 1.0 >= 1.0 → fires again

        XCTAssertEqual(getSpawnedProjectiles().count, 2)
    }

    func testWeaponDoesNotFireWhenNotShooting() {
        makeWeaponWithOwner(
            isShooting: false,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world)

        XCTAssertTrue(getSpawnedProjectiles().isEmpty)
    }

    // Projectile

    func testSpawnedProjectileHasTransformAtOwnerPosition() {
        makeWeaponWithOwner(
            ownerPosition: SIMD2(50, 30),
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world)

        let projectiles = getSpawnedProjectiles()
        XCTAssertEqual(projectiles.count, 1)
        let transform = world.getComponent(type: TransformComponent.self, for: projectiles[0])!
        XCTAssertEqual(transform.position.x, 50, accuracy: 0.01)
        XCTAssertEqual(transform.position.y, 30, accuracy: 0.01)
    }

    func testSpawnedProjectileHasVelocityAlignedWithAimDirection() {
        makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world)

        let velocity = world.getComponent(type: VelocityComponent.self, for: getSpawnedProjectiles()[0])!
        XCTAssertGreaterThan(velocity.linear.x, 0)
        XCTAssertEqual(velocity.linear.y, 0, accuracy: 0.01)
    }

    func testSpawnedProjectileVelocityReflectsAimDirection() {
        // Aim left — velocity.x should be negative
        makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(-1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world)

        let velocity = world.getComponent(type: VelocityComponent.self, for: getSpawnedProjectiles()[0])!
        XCTAssertLessThan(velocity.linear.x, 0)
    }

    func testSpawnedProjectileHasSpriteComponent() {
        makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world)

        let sprite = world.getComponent(type: SpriteComponent.self, for: getSpawnedProjectiles()[0])
        XCTAssertNotNil(sprite)
    }

    func testSpawnedProjectileOwnerMatchesPlayerEntity() {
        let (owner, _) = makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world)

        let projectileComp = world.getComponent(type: ProjectileComponent.self, for: getSpawnedProjectiles()[0])!
        XCTAssertEqual(projectileComp.owner, owner)
    }

    func testSpawnedProjectileHasPositiveEffectiveRange() {
        makeWeaponWithOwner(
            isShooting: true,
            aimDirection: SIMD2(1, 0),
            coolDownInterval: 0.5,
            lastFiredAt: 0
        )

        system.update(deltaTime: 1.0, world: world)

        let projectileComp = world.getComponent(type: ProjectileComponent.self, for: getSpawnedProjectiles()[0])!
        XCTAssertGreaterThan(projectileComp.effectiveRange, 0)
    }
}
