import Testing
import simd
@testable import dungeonCrawler

@Suite("RoomMetadataComponent")
struct RoomMetadataComponentTests {

    // MARK: - RoomBounds computed properties

    @Suite("RoomBounds")
    struct RoomBoundsTests {

        @Test func centerIsMiddleOfBounds() {
            let bounds = RoomBounds(origin: SIMD2(0, 0), size: SIMD2(200, 100))
            #expect(bounds.center.x == 100)
            #expect(bounds.center.y == 50)
        }

        @Test func centerWithNegativeOrigin() {
            let bounds = RoomBounds(origin: SIMD2(-100, -50), size: SIMD2(200, 100))
            #expect(bounds.center.x == 0)
            #expect(bounds.center.y == 0)
        }

        @Test func maxIsOriginPlusSize() {
            let bounds = RoomBounds(origin: SIMD2(10, 20), size: SIMD2(300, 400))
            #expect(bounds.max.x == 310)
            #expect(bounds.max.y == 420)
        }

        // MARK: contains

        @Test func containsCenterPoint() {
            let bounds = RoomBounds(origin: SIMD2(-100, -100), size: SIMD2(200, 200))
            #expect(bounds.contains(SIMD2(0, 0)))
        }

        @Test func containsOriginPoint() {
            let bounds = RoomBounds(origin: SIMD2(-100, -100), size: SIMD2(200, 200))
            #expect(bounds.contains(SIMD2(-100, -100)))
        }

        @Test func containsMaxPoint() {
            let bounds = RoomBounds(origin: SIMD2(-100, -100), size: SIMD2(200, 200))
            #expect(bounds.contains(SIMD2(100, 100)))
        }

        @Test func doesNotContainPointJustOutsideLeft() {
            let bounds = RoomBounds(origin: SIMD2(-100, -100), size: SIMD2(200, 200))
            #expect(!bounds.contains(SIMD2(-100.1, 0)))
        }

        @Test func doesNotContainPointJustOutsideBottom() {
            let bounds = RoomBounds(origin: SIMD2(-100, -100), size: SIMD2(200, 200))
            #expect(!bounds.contains(SIMD2(0, -100.1)))
        }

        @Test func doesNotContainFarOutsidePoint() {
            let bounds = RoomBounds(origin: SIMD2(0, 0), size: SIMD2(100, 100))
            #expect(!bounds.contains(SIMD2(999, 999)))
        }

        // MARK: randomPosition

        @Test func randomPositionIsWithinBoundsMinusMargin() {
            let bounds = RoomBounds(origin: SIMD2(-200, -200), size: SIMD2(400, 400))
            let margin: Float = 50
            var generator = SeededGenerator(seed: 123)
            for _ in 0..<50 {
                let pos = bounds.randomPosition(margin: margin, using: &generator)
                #expect(pos.x >= bounds.origin.x + margin)
                #expect(pos.x <= bounds.max.x    - margin)
                #expect(pos.y >= bounds.origin.y + margin)
                #expect(pos.y <= bounds.max.y    - margin)
            }
        }

        @Test func randomPositionDefaultMarginIsWithinBounds() {
            let bounds = RoomBounds(origin: SIMD2(0, 0), size: SIMD2(500, 500))
            var generator = SeededGenerator(seed: 456)
            for _ in 0..<20 {
                #expect(bounds.contains(bounds.randomPosition(using: &generator)))
            }
        }
    }

    // MARK: - RoomMetadataComponent initialisation

    @Test func defaultsToEmptyDoorwaysAndSpawnPoints() {
        let bounds = RoomBounds(origin: .zero, size: SIMD2(200, 200))
        let room = RoomMetadataComponent(bounds: bounds)
        #expect(room.doorways.isEmpty)
        #expect(room.spawnPoints.isEmpty)
    }

    @Test func assignsUniqueRoomIDs() {
        let bounds = RoomBounds(origin: .zero, size: SIMD2(200, 200))
        let roomA = RoomMetadataComponent(bounds: bounds)
        let roomB = RoomMetadataComponent(bounds: bounds)
        #expect(roomA.roomID != roomB.roomID)
    }

    @Test func preservesDoorways() {
        let bounds   = RoomBounds(origin: .zero, size: SIMD2(400, 400))
        let doorway  = Doorway(position: SIMD2(200, 400), direction: .north)
        let room     = RoomMetadataComponent(bounds: bounds, doorways: [doorway])
        #expect(room.doorways.count == 1)
        #expect(room.doorways[0].direction == .north)
    }

    @Test func preservesSpawnPoints() {
        let bounds = RoomBounds(origin: .zero, size: SIMD2(400, 400))
        let spawn  = SpawnPoint(position: SIMD2(200, 200), type: .playerEntry)
        let room   = RoomMetadataComponent(bounds: bounds, spawnPoints: [spawn])
        #expect(room.spawnPoints.count == 1)
        #expect(room.spawnPoints[0].type == .playerEntry)
    }
}
