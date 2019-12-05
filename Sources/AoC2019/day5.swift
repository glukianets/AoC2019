import Foundation

func day5(input: String) throws -> String {
    try formatOutput(try solve(intcode: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [Int] {
    try input.components(separatedBy: ",").map { try Int($0).unwrap() }
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0) \(output.1)"
}

private func solve(intcode: [Int]) throws -> (Int, Int) {
    return try ({
        var output: Int = 0
        let runner = Intcoder(input: { 1 }, output: { output = $0 })
        var input = intcode
        try runner.run(&input)
        return output
    }(), {
        var output: Int = 0
        let runner = Intcoder(input: { 5 }, output: { output = $0 })
        var input = intcode
        try runner.run(&input)
        return output
    }())
}
