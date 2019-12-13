
import Foundation

func day13(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [Int] {
    try input.components(separatedBy: ",").map { try Int($0).unwrap() }
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0)\n\(output.1)\n"
}


private struct Point: Hashable {
    let x: Int
    let y: Int

    static func +=(_ lhs: inout Point, rhs: Point) { lhs = Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
}

private enum TileType: Int {
    case empty = 0
    case wall = 1
    case block = 2
    case hpaddle = 3
    case ball = 4
    
    var displayCharacter: Character {
        switch self {
        case .empty: return " "
        case .wall: return "|"
        case .block: return "#"
        case .hpaddle: return "—"
        case .ball: return "@"
        }
    }
}

private func solve(input program: [Int]) throws -> (Int, Int) {
    func run(coins: Int) throws -> (score: Int, field: [Point: TileType]) {
        var field: [Point: TileType] = [:]
        var obuf: [Int] = []
        var score = 0;

        let coder = Intcoder(input: {
            var ballX = 0
            var padX = 0
            field.forEach {
                switch $0.value{
                case .ball: ballX = $0.key.x
                case .hpaddle: padX = $0.key.x
                default: break
                }
            }
            return (ballX - padX).signum()
            
        }, output: {
            obuf.append($0)
            guard obuf.count == 3 else { return }
            let x = obuf[0]
            let y = obuf[1]
            let z = obuf[2]
            if x == -1 && y == 0 {
                score = z
            } else {
                field[Point(x: x, y: y)] = try TileType(rawValue:z).unwrap(or: "Unknown tile type \(z)")
            }
            obuf.removeAll(keepingCapacity: true)
        })

        var memory = program
        if coins > 0 {
            memory[0] = coins
        }
        try coder.run(&memory)
        return (score, field)
    }

    return try (run(coins: 0).field.values.filter { $0 == .block }.count, run(coins: 2).score)
}
