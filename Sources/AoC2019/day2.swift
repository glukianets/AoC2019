import Foundation

func day2(input: String) throws -> String {
    try formatOutput(try solve(intcode: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [Int] {
    try input.components(separatedBy: ",").map { try Int($0).unwrap() }
}

private func formatOutput(_ output: [Int]) throws -> String {
    return output.map { $0.description }.joined(separator: " ")
}

private func solve(intcode: [Int]) throws -> [Int] {
    func run(_ ll: inout [Int]) throws {
        guard intcode.count >= 4 else { throw "Invalid input" }
        var ii = 0

        execution: while true {
            switch try ll.get(at: ii) {
            case 1:
                try ll.set(ll.get(at: ll.get(at: ii + 1)) + ll.get(at: ll.get(at: ii + 2)), at: ll.get(at: ii + 3))
                ii += 4

            case 2:
                try ll.set(ll.get(at: ll.get(at: ii + 1)) * ll.get(at: ll.get(at: ii + 2)), at: ll.get(at: ii + 3))
                ii += 4

            case 99:
                break execution

            case let opcode:
                throw "Unknown opcode \(opcode)"
            }
        }
    }

    func run(noun: Int, verb: Int) throws -> Int {
        var input = intcode
        input[1] = noun
        input[2] = verb
        try run(&input)
        return input[0]
    }

    let result1 = try run(noun: 12, verb: 02)

    let target = 19690720
    let match = try (0..<100).flatMap { l in (0..<100).map { r in (l, r) } }
        .lazy
        .first { try run(noun: $0.0, verb: $0.1) == target }
        .map { 100 * $0.0 + $0.1 }
    
    guard let result2 = match else { throw "No solution for the second problem found" }

    return [result1, result2]
}


// 190643 - too low
