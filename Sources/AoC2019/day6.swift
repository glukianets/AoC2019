import Foundation

func day6(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [(String, String)] {
    try input
        .components(separatedBy: .newlines)
        .map { $0.components(separatedBy: ")") }
        .map {
            guard $0.count == 2 else { throw "Parse input failure" }
            return ($0[0], $0[1])
    }
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0)\n\(output.1)\n"
}

private func solve(input: [(String, String)]) throws -> (Int, Int) {
    let map: [String: String] = Dictionary(uniqueKeysWithValues: input.map { ($0.1, $0.0) })
    let rev: [String: [String]] = Dictionary(grouping: input) { $0.0 }.mapValues { $0.map { $0.1 } }

    let names = input.reduce(into: Set<String>()) { $0.insert($1.0); $0.insert($1.1) }
    func pathLength(name: String) -> Int {
        return map[name].map { pathLength(name: $0) + 1 } ?? 0
    }

    func path(from: String, to: String, excluding: String? = nil) -> Int? {
        from == to ? 0 : map[from].flatMap {
            $0 == excluding ? nil : path(from: $0, to: to, excluding: from).map { $0 + 1 }
        } ?? rev[from].flatMap {
            $0.filter { $0 != excluding }
              .compactMap { path(from: $0, to: to, excluding: from).map { $0 + 1 } }
              .min()
        }
    }

    let pt1 = names.map(pathLength(name:)).reduce(0, +)
    guard let pt2 = path(from: "YOU", to: "SAN") else { throw "Failed to find solution to pt. 2" }

    return (pt1, pt2 - 2)
}
