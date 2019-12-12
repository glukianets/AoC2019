import Foundation

func day7(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [Int] {
    try input.components(separatedBy: ",").map { try Int($0).unwrap() }
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0)\n\(output.1)\n"
}

private func solve(input program: [Int]) throws -> (Int, Int) {
    func test(phaseSequence: [Int]) throws -> Int {
        var foodchain = phaseSequence.map { [$0] }
        foodchain[0].insert(0, at: 0)
        var states = (0..<phaseSequence.count).map { _ -> Intcoder.State? in nil }
        var memory = (0..<phaseSequence.count).map { _ -> [Int] in program }
        let coders = (0..<phaseSequence.count).map { i in
            Intcoder(input: {
                guard let value = foodchain[wrapping: i].popLast() else { throw Intcoder.ExecutionControl.pause }
                return value
            }, output: {
                foodchain[wrapping: i + 1].insert($0, at: 0)
            })
        }

        while states.contains(where: { $0 != .halted }) {
            for i in coders.indices {
                guard states[i] != .halted else { throw "Out of order halting detected" }
                states[i] = try coders[i].run(&memory[i], state: states[i])
            }
        }

        guard let result = foodchain.first?.first else { throw "No output to give" }
        return result
    }

    let result1 = try (0..<5).permutations.map { ($0, try test(phaseSequence:$0)) }.max { $0.1 < $1.1 }.unwrap()
    let result2 = try (5..<10).permutations.map { ($0, try test(phaseSequence:$0)) }.max { $0.1 < $1.1 }.unwrap()
    return (result1.1, result2.1)
}
