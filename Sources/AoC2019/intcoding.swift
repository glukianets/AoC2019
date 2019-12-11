import Foundation

struct Intcoder {
    enum State: Equatable {
        case running(at: Int, rb: Int)
        case paused(at: Int, rb: Int)
        case halted
    }

    struct Command {
        typealias Function = (() throws -> Int, (Int) throws -> Void) throws -> ExecutionControl

        fileprivate let function: Function

        init(_ function: @escaping Function) {
            self.function = function
        }
    }

    enum ExecutionControl: Error {
        case jump(ii: Int?, rb: Int?)
        case halt
        case pause
        case rollback
        case `continue`
    }

    let commands: [Int: Command]

    init(commands: [Int: Command]) {
        self.commands = commands
    }

    init(input: @escaping () throws -> Int, output: @escaping (Int) throws -> Void) {
        self.init(commands: [
            1: Command { take, put in try put(take() + take()); return .continue }, // +
            2: Command { take, put in try put(take() * take()); return .continue }, // *
            3: Command { _, put in try put(input()); return .continue }, // input
            4: Command { take, _ in try output(take()); return .continue }, // output
            5: Command { take, put in let cond = try take(); let addr = try take(); return cond == 0 ? .continue : .jump(ii: addr, rb: nil) }, // jmp
            6: Command { take, put in let cond = try take(); let addr = try take(); return cond == 0 ? .jump(ii: addr, rb: nil) : .continue }, // njump
            7: Command { take, put in try put(try take() < (try take()) ? 1 : 0); return .continue }, // <
            8: Command { take, put in try put(try take() == (try take()) ? 1 : 0); return .continue }, // =
            9: Command { take, _ in ExecutionControl.jump(ii: nil, rb: try take()) }, // adj rb
            99: Command { _, _ in ExecutionControl.halt }, // halt
        ])
    }

    @discardableResult func run(_ ll: inout [Int], state initialState: State? = nil) throws -> State {
        var trace: [Int] = []
        var state: State = try {
            switch initialState {
            case let .running(ll, rb)?: return .running(at: ll, rb: rb)
            case let .paused(ii, rb)?: return .running(at: ii, rb: rb)
            case .halted?: throw "Cannot continue from halted state"
            case nil: return .running(at: 0, rb: 0)
            }
        }()

        func get(_ index: Int, rb: Int, mode: ParameterMode) throws -> Int {
            switch mode {
            case .position: return try get(get(index, rb: rb, mode: .immediate), rb: rb, mode: .immediate)
            case .relative: return try get(rb + get(index, rb: rb, mode: .immediate), rb: rb, mode: .immediate)
            case .immediate:
                guard index < ll.count else { return 0 }
                return try ll.get(at: index)
            }
        }

        func set(_ value: Int, at index: Int, rb: Int, mode: ParameterMode) throws {
            switch mode {
            case .position: return try set(value, at: get(index, rb: rb, mode: .immediate), rb: rb, mode: .immediate)
            case .relative: return try set(value, at: rb + get(index, rb: rb, mode: .immediate), rb: rb, mode: .immediate)
            case .immediate:
                if index >= ll.count { ll += Array(repeating: 0, count: index - ll.count + 1) }
                return try ll.set(value, at: index)
            }
        }

        while case var .running(ii, rb) = state {
            trace.append(ii)
            var opcode = try get(ii, rb: rb, mode: .immediate)
            ii += 1
            let command = try commands[opcode /=% 100].unwrap(or: "Unrecognized command code in \(opcode)")

            func nextMode() throws -> ParameterMode { try ParameterMode(rawValue: opcode /=% 10).unwrap(or: "Unrecognized parameter mode in \(opcode)") }
            func takeNext() throws -> Int { defer { ii += 1 }; return try get(ii, rb: rb, mode: nextMode()) }
            func putNext(_ value: Int) throws { defer { ii += 1 }; return try set(value, at: ii, rb: rb, mode: nextMode()) }

            switch try command.function(takeNext, putNext) {
            case let .jump(_ii, _rb):
                state = .running(at: _ii ?? ii, rb: rb + (_rb ?? 0))
            case .halt:
                state = .halted
            case .pause:
                guard case let .running(ii, rb) = state else { throw "Cannot pause while not running (halted)" }
                return .paused(at: ii, rb: rb)
            case .rollback:
                break;
            case .continue:
                state = .running(at: ii, rb: rb)
            }
        }

        return state
    }
}

private enum ParameterMode: Int, RawRepresentable {
    case relative = 2
    case immediate = 1
    case position = 0
}
