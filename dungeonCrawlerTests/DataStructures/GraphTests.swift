import Testing
@testable import dungeonCrawler

@Suite("Graph")
struct GraphTests {

    // MARK: - Node Operations

    @Suite("Node operations")
    struct NodeOperations {

        @Test func setAndRetrieve() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "alpha")
            #expect(graph.node(1) == "alpha")
        }

        @Test func overwrite() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "alpha")
            graph.setNode(1, data: "beta")
            #expect(graph.node(1) == "beta")
        }

        @Test func missingReturnsNil() {
            let graph = Graph<Int, String, String>()
            #expect(graph.node(99) == nil)
        }

        @Test func hasNodeTrueAfterInsert() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "alpha")
            #expect(graph.hasNode(1))
        }

        @Test func hasNodeFalseForMissing() {
            let graph = Graph<Int, String, String>()
            #expect(!graph.hasNode(99))
        }

        @Test func nodeCount() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.setNode(2, data: "b")
            graph.setNode(3, data: "c")
            #expect(graph.nodeCount == 3)
        }

        @Test func overwriteDoesNotIncrementCount() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.setNode(1, data: "b")
            #expect(graph.nodeCount == 1)
        }

        @Test func allNodeIDs() {
            var graph = Graph<Int, String, String>()
            graph.setNode(10, data: "a")
            graph.setNode(20, data: "b")
            #expect(Set(graph.allNodeIDs) == Set([10, 20]))
        }
    }

    // MARK: - Edge Operations

    @Suite("Edge operations")
    struct EdgeOperations {

        @Test func addAndQuery() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.setNode(2, data: "b")
            graph.addEdge(from: 1, to: 2, data: "link")

            let edges = graph.edges(from: 1)
            #expect(edges.count == 1)
            #expect(edges[0].from == 1)
            #expect(edges[0].to == 2)
            #expect(edges[0].data == "link")
        }

        @Test func unknownNodeReturnsEmpty() {
            let graph = Graph<Int, String, String>()
            #expect(graph.edges(from: 99).isEmpty)
        }

        @Test func multipleEdgesFromSameNode() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.setNode(2, data: "b")
            graph.setNode(3, data: "c")
            graph.addEdge(from: 1, to: 2, data: "one")
            graph.addEdge(from: 1, to: 3, data: "two")
            #expect(graph.edges(from: 1).count == 2)
        }

        @Test func directedEdgeIsOneWay() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.setNode(2, data: "b")
            graph.addEdge(from: 1, to: 2, data: "forward")
            #expect(graph.edges(from: 2).isEmpty)
        }

        @Test func allEdges() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.setNode(2, data: "b")
            graph.setNode(3, data: "c")
            graph.addEdge(from: 1, to: 2, data: "e1")
            graph.addEdge(from: 2, to: 3, data: "e2")
            graph.addEdge(from: 3, to: 1, data: "e3")
            #expect(graph.allEdges.count == 3)
        }
    }

    // MARK: - Neighbor Queries

    @Suite("Neighbor queries")
    struct NeighborQueries {

        @Test func neighbors() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.setNode(2, data: "b")
            graph.setNode(3, data: "c")
            graph.addEdge(from: 1, to: 2, data: "x")
            graph.addEdge(from: 1, to: 3, data: "y")
            #expect(Set(graph.neighbors(of: 1)) == Set([2, 3]))
        }

        @Test func noEdgesReturnsEmpty() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            #expect(graph.neighbors(of: 1).isEmpty)
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge cases")
    struct EdgeCases {

        @Test func emptyGraph() {
            let graph = Graph<Int, String, String>()
            #expect(graph.nodeCount == 0)
            #expect(graph.allNodeIDs.isEmpty)
            #expect(graph.allEdges.isEmpty)
        }

        @Test func selfLoop() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.addEdge(from: 1, to: 1, data: "loop")

            let edges = graph.edges(from: 1)
            #expect(edges.count == 1)
            #expect(edges[0].from == 1)
            #expect(edges[0].to == 1)
        }

        @Test func parallelEdges() {
            var graph = Graph<Int, String, String>()
            graph.setNode(1, data: "a")
            graph.setNode(2, data: "b")
            graph.addEdge(from: 1, to: 2, data: "first")
            graph.addEdge(from: 1, to: 2, data: "second")
            #expect(graph.edges(from: 1).count == 2)
        }
    }
}