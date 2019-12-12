import Foundation

func day3(input: String) throws -> String {
    try formatOutput(try solve(lines: try parseInput(input)))
}

private struct Point: Comparable {
    let x: Int
    let y: Int

    var magnitude: Int { abs(self.x) + abs(self.y) }

    static func < (lhs: Point, rhs: Point) -> Bool {
        lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
    }
}

private struct Interval {
    let begin: Point
    let end: Point

    var magnitude: Int { Point(x: self.end.x - self.begin.x, y: self.end.y - self.begin.y).magnitude }
    var normalized: Interval { self.begin < self.end ? self : Interval(begin: self.end, end: self.begin) }

    func intersection(with point: Point) -> Int? {
        guard min(self.begin.x, self.end.x)...max(self.begin.x, self.end.x) ~= point.x else { return nil }
        guard min(self.begin.y, self.end.y)...max(self.begin.y, self.end.y) ~= point.y else { return nil }
        return Point(x: point.x - self.begin.x, y: point.y - self.begin.y).magnitude
    }

    func intersection(with interval: Interval) -> Point? { // only considers axis-aligned intervals
        func imp(_ lhs: Interval, _ rhs: Interval) -> Point? {
            guard min(rhs.begin.x, rhs.end.x)...max(rhs.begin.x, rhs.end.x) ~= lhs.begin.x else { return nil }
            guard min(lhs.begin.y, lhs.end.y)...max(lhs.begin.y, lhs.end.y) ~= rhs.begin.y else { return nil }
            return Point(x: lhs.begin.x, y: rhs.begin.y)
        }

        return imp(self, interval) ?? imp(interval, self)
    }
}

private func parseInput(_ input: String) throws -> [[Interval]] {
    try input
        .components(separatedBy: .newlines)
        .map {
            try $0
            .components(separatedBy: ",")
            .map { (try $0.first.unwrap(), try Int($0.dropFirst()).unwrap()) }
            .reduce(into: Array<Point>()) { (result: inout [Point], element: (direction: Character, distance: Int)) in
                let last = result.last ?? Point(x: 0, y: 0)
                switch element.direction {
                    case "U": result.append(Point(x: last.x, y: last.y + element.distance))
                    case "L": result.append(Point(x: last.x -  element.distance, y: last.y))
                    case "D": result.append(Point(x: last.x, y: last.y - element.distance))
                    case "R": result.append(Point(x: last.x + element.distance, y: last.y))
                    default: throw "Invalid direction \(element.direction)"
                }
            }.reduce(into: Array<Interval>()) { (result, element) in
                result.append(result.last.map { Interval(begin: $0.end, end: element) } ?? Interval(begin: Point(x: 0, y: 0), end: element))
            }.intoArray()
        }
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0)\n\(output.1)\n"
}

private func solve(lines: [[Interval]]) throws -> (Int, Int) {
    var paths: [[Interval]] = lines.map { $0.map { $0.normalized }.sorted { l, r in l.begin > r.begin } }
    let start = try paths.compactMap { $0.last?.begin.x }.min().unwrap()
    var queue: [[Interval]] = Array(repeating: [], count: paths.count)
    var intersections: [Point] = []

    for sweep in start... {
        guard paths.allSatisfy({ !$0.isEmpty }) || queue.contains(where: { !$0.isEmpty }) else { break }

        for i in paths.indices {
            while paths[i].last?.begin.x == sweep {
                let newInterval = paths[i].popLast()!
                queue[i].append(newInterval)

                for j in queue.indices where j != i {
                    for interval in queue[j] {
                        guard let int = interval.intersection(with: newInterval), int.magnitude != 0 else { continue }
                        intersections.append(int)
                    }
                }
            }
        }

        for i in queue.indices {
            queue[i].removeAll { $0.end.x == sweep }
        }
    }

    let closest = intersections.map { $0.magnitude }.min()

    let shortest: Int? = intersections.map { int in
        lines.map { line in
            line.reduce((distance: Int, isCompleted: Bool)(0, false)) {
                guard !$0.isCompleted else { return $0 }
                if let int = $1.intersection(with: int) {
                    return ($0.distance + int, true)
                } else {
                    return ($0.distance + $1.magnitude, false)
                }
            }.distance
        }
    }.map { $0.reduce(0, +) }.min()

    return (try closest.unwrap(), try shortest.unwrap())
}
