import Foundation

func day9(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [Int] {
    try input.components(separatedBy: ",").map { try Int($0).unwrap() }
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0) \(output.1)\n"
}

private func solve(input program: [Int]) throws -> (Int, Int) {
    func run(input: Int) throws -> [Int] {
        var output: [Int] = []
        let coder = Intcoder(input: { input }, output: { output.append($0) })
        var memory = program
        try coder.run(&memory)
        return output
    }

    let result1 = try run(input: 1)
    guard let r1 = result1.first, result1.count == 1 else { throw "Invalid output for pt.1: \(result1)" }

    let result2 = try run(input: 2)
    guard let r2 = result2.first, result2.count == 1 else { throw "Invalid output for pt.1: \(result2)" }

    return (r1, r2)
}
