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
    let result1 = try { () -> Int in
        var output = 0
        let coder = Intcoder(input: {
            print("in")
            return 1
        }, output: { output = $0 })
        var memory = program
        try coder.run(&memory)
        return output
    }()

    return (result1, 0)
}
