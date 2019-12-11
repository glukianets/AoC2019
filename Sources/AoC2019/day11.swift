import Foundation

func day11(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [Int] {
    try input.components(separatedBy: ",").map { try Int($0).unwrap() }
}

private func formatOutput(_ output: (Int, String)) throws -> String {
    return "\(output.0)\n\(output.1)\n"
}

private struct Point: Hashable {
    let x: Int
    let y: Int

    static func +=(_ lhs: inout Point, rhs: Point) { lhs = Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
}

private func solve(input program: [Int]) throws -> (Int, String) {
    let orientations: [Point] = [Point(x: 0, y: -1), Point(x: 1, y: 0), Point(x: 0, y: 1), Point(x: -1, y: 0)]

    func run(field initialField: [Point: Int]) throws -> [Point: Int] {
        var orientation = 0
        var position = Point(x: 0, y: 0)
        var field: [Point: Int] = initialField
        var isPhaseOne = true

        let coder = Intcoder(input: {
            field[position] ?? 0
        }, output: {
            if isPhaseOne {
                field[position] = $0
            } else {
                orientation += $0 == 0 ? -1 : 1
                position += orientations[wrapping: orientation]
            }
            isPhaseOne.toggle()
        })

        var memory = program
        try coder.run(&memory)
        return field
    }

    let result1 = try run(field: [:]).count

    let result2: String = try {
        let field = try run(field: [Point(x: 0, y: 0): 1])
        let minmax = field.keys.reduce((min: Point(x: 0, y: 0), max: Point(x: 0, y: 0))) {
            (min: Point(x: min($1.x, $0.min.x), y: min($1.y, $0.min.y)),
             max: Point(x: max($1.x, $0.max.x), y: max($1.y, $0.max.y)))
        }
        return (minmax.min.y...minmax.max.y)
            .map { y in
                String((minmax.min.x...minmax.max.x).map { x -> Character in
                    (field[Point(x: x, y: y)] ?? 0) == 0 ? " " : "*"
                })
            }.joined(separator: "\n")
    }()

    return (result1, result2)
}
