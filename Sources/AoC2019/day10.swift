import Foundation

func day10(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private struct Point: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    static func -(_ lhs: Point, rhs: Point) -> Point { .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    static func +(_ lhs: Point, rhs: Point) -> Point { .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
    static func /(_ lhs: Point, rhs: Int) -> Point { .init(x: lhs.x / rhs, y: lhs.y / rhs) }
    static func *(_ lhs: Point, rhs: Int) -> Point { .init(x: lhs.x * rhs, y: lhs.y * rhs) }

    var description: String { "(\(self.x) \(self.y))" }

    var angularValue: Double { atan2(Double(self.x), Double(self.y)) }
}

private func parseInput(_ input: String) throws -> Set<Point> {
    return input
        .components(separatedBy: .newlines)
        .enumerated()
        .flatMap { i, l in l.enumerated().filter { $0.element == "#" }.map { Point(x: $0.offset, y: i) } }
        .intoSet()
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0)\n\(output.1)\n"
}

private func solve(input points: Set<Point>) throws -> (Int, Int) {
    var pointsVisibleFrom: [Point: Set<Point>] = Dictionary(uniqueKeysWithValues: points.map { ($0, []) })

    func isOnTheLineOfSight<T: Collection>(_ lhs: Point, _ rhs: Point, in points: T) -> Bool where T.Element == Point {
        let vec = rhs - lhs
        let k = gcd(vec.x, vec.y)
        return (min(k, 0)...max(k, 0)).dropFirst().dropLast().map { vec / k * $0 + lhs }.allSatisfy { !points.contains($0) }
    }

    let result1: (point: Point, count: Int) = {
        var queue = points.intoArray()
        while let point = queue.popLast() {
            for other in queue where !pointsVisibleFrom[point]!.contains(other) && isOnTheLineOfSight(point, other, in: points) {
                pointsVisibleFrom[point]!.insert(other)
                pointsVisibleFrom[other]!.insert(point)
            }
        }

        return pointsVisibleFrom.map { (point: $0.key, count: $0.value.count) }.max { $0.count < $1.count }!
    }()

    let result2: Int = try {
        let center = result1.point
        let queue = points.sorted { ($0 - center).angularValue > ($1 - center).angularValue }.intoArray()
        let result: Point = try Produce(queue) { queue -> [Point]? in
            let batch = queue.enumerated().filter { isOnTheLineOfSight(center, $0.element, in: queue) }
            batch.reversed().forEach { queue.remove(at: $0.offset) }
            return batch.map { $0.element }.nonEmptyOrNil
        }.flatMap { $0 }[safe: 200].unwrap(or: "Less than 200 output values")

        return result.x * 100 + result.y
    }()

    return (result1.count, result2)
}
