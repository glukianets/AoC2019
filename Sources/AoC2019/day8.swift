import Foundation

func day8(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private let w = 25
private let h = 6

private func parseInput(_ input: String) throws -> [[[Int]]] {
    try input.map { try Int(String($0)).unwrap() }.grouping(by: w * h).map { $0.grouping(by: w).map(Array.init(_:)) }
}

private func formatOutput(_ output: (Int, String)) throws -> String {
    "\(output.0)\n\(output.1)\n"
}

private func solve(input layers: [[[Int]]]) throws -> (Int, String) {
    let first: (Int, Int) = try layers
        .map { $0.flatMap { $0 } }
        .min { (l: [Int], r: [Int]) -> Bool in l.filter { $0 == 0 }.count < r.filter { $0 == 0 }.count }
        .unwrap()
        .reduce((0, 0)) { (a: (Int, Int), e: Int) -> (Int, Int) in (a.0 + (e == 1 ? 1 : 0), a.1 + (e == 2 ? 1 : 0)) }

    let render = (0..<h).map { _ in (0..<w).map { _ -> Character in " " } }

    let renderString = layers
        .map { $0.enumerated().flatMap { (o, e) in e.enumerated().map { (x: $0.offset, y: o, e: $0.element) } } }
        .reversed()
        .reduce(into: render) { (a: inout [[Character]], e: [(x: Int, y: Int, e: Int)]) -> Void in
            e.forEach { a[$0.y][$0.x] = $0.e == 0 ? "-" : $0.e == 1 ? "0" : a[$0.y][$0.x] }
        }.map { String($0) }
        .joined(separator: "\n")

    return (first.0 * first.1, renderString)
}
