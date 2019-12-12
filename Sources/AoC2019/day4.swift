import Foundation

func day4(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> ClosedRange<Int> {
    let numbers = try input.components(separatedBy: "-").map { try Int($0).unwrap() }
    guard numbers.count == 2 else { throw "Invalid input: \(input)" }
    return numbers[0]...numbers[1]
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0)\n\(output.1)\n"
}

private func solve(input range: ClosedRange<Int>) throws -> (Int, Int) {
    return range.lazy
        .filter { 100000...999999 ~= $0 && $0.digits.intervals.allSatisfy({ $0.0 <= $0.1 }) }
        .map { $0.digits.grouping { $0 }.map { $0.count } }
        .reduce(into: (0, 0)) {
            $0.0 += $1.contains { $0 >= 2 } ? 1 : 0
            $0.1 += $1.contains(2) ? 1 : 0
        }
}
