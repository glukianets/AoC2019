import Foundation

func day1(input: String) throws -> String {
    try formatOutput(try solve(moduleWeights: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [Int] {
    try input.components(separatedBy: .newlines).map { try Int($0).unwrap() }
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0) \(output.1)"
}

private func solve(moduleWeights: [Int]) throws -> (naive: Int, smart: Int) {
    func requiredFuel(for mass: Int) -> Int? {
        mass / 3 < 2 ? nil : mass / 3 - 2
    }

    let naive = moduleWeights.compactMap(requiredFuel(for:)).reduce(0, +)

    func totalMass(for mass: Int) -> Int {
        mass + (requiredFuel(for: mass).map(totalMass(for:)) ?? 0)
    }

    let smart = moduleWeights.map { totalMass(for: requiredFuel(for: $0) ?? 0) }.reduce(0, +)

    return (naive: naive, smart: smart)
}
