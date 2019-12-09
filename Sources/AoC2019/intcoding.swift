import Foundation

struct Intcoder {
    enum State: Equatable {
        case running(at: Int, rb: Int)
        case paused(at: Int, rb: Int)
        case halted
    }

    struct Command {
        fileprivate let function: Any
        fileprivate let scheme: (arity: Int, returns: Bool)

        init(_ f: @escaping () throws -> Void) { self.init(f, (0, false)) }
        init(_ f: @escaping (Int) throws -> Void) { self.init(f, (1, false)) }
        init(_ f: @escaping (Int, Int) throws -> Void) { self.init(f, (2, false)) }
        init(_ f: @escaping (Int, Int, Int) throws -> Void) { self.init(f, (3, false)) }
        init(_ f: @escaping () throws -> Int) { self.init(f, (0, true)) }
        init(_ f: @escaping (Int) throws -> Int) { self.init(f, (1, true)) }
        init(_ f: @escaping (Int, Int) throws -> Int) { self.init(f, (2, true)) }
        init(_ f: @escaping (Int, Int, Int) throws -> Int) { self.init(f, (3, true)) }

        private init(_ f: Any, _ scheme: (Int, Bool)) {
            self.scheme = scheme
            self.function = f
        }
    }

    enum ExecutionControl: Error {
        case jump(Int)
        case adjustRelBase(Int)
        case halt
        case pause
    }

    let commands: [Int: Command]

    init(commands: [Int: Command]) {
        self.commands = commands
    }

    init(input: @escaping () throws -> Int, output: @escaping (Int) throws -> Void) {
        self.init(commands: [
            1: Command(+),
            2: Command(*),
            3: Command(input),
            4: Command(output),
            5: Command { (cond, addr) -> Void in if cond != 0 { throw ExecutionControl.jump(addr) } },
            6: Command { (cond, addr) -> Void in if cond == 0 { throw ExecutionControl.jump(addr) } },
            7: Command { $0 < $1 ? 1 : 0 },
            8: Command { $0 == $1 ? 1 : 0 },
            9: Command { (i) -> Void in throw ExecutionControl.adjustRelBase(i) },
            99: Command { () -> Void in throw ExecutionControl.halt },
        ])
    }

    @discardableResult func run(_ ll: inout [Int], state initialState: State? = nil) throws -> State {
        var state: State
        switch initialState {
        case let .running(ll, rb)?:
            state = .running(at: ll, rb: rb)
        case let .paused(ii, rb)?:
            state = .running(at: ii, rb: rb)
        case .halted?:
            throw "Cannot continue from halted state"
        case nil:
            state = .running(at: 0, rb: 0)
        }

        func get(_ index: Int, rb: Int, mode: ArgMode) throws -> Int {
            switch mode {
            case .position: return try get(get(index, rb: rb, mode: .immediate), rb: rb, mode: .immediate)
            case .relative: return try get(rb + get(index, rb: rb, mode: .immediate), rb: rb, mode: .immediate)
            case .immediate:
                guard index < ll.count else { return 0 }
                return try ll.get(at: index)
            }
        }

        func set(_ value: Int, at index: Int, rb: Int, mode: ArgMode) throws {
            switch mode {
            case .position: try set(value, at: get(index, rb: rb, mode: .immediate), rb: rb, mode: .immediate)
            case .relative: try set(value, at: rb + get(index, rb: rb, mode: .immediate), rb: rb, mode: .immediate)
            case .immediate:
                if index >= ll.count {
                    ll += Array(repeating: 0, count: index - ll.count + 1)
                }
                try ll.set(value, at: index)
            }
        }

        while case var .running(ii, rb) = state {
            let opcode = try get(ii, rb: rb, mode: .immediate)
            ii += 1
            var argmodes = try (opcode / 100).digits.map { try ArgMode(rawValue: $0).unwrap(or: "Unrecognized arg mode: \($0) in \(opcode)") }
            let code = opcode % 100
            let command = try commands[code].unwrap(or: "Unrecognized command code: \(code) in \(opcode)")

            func arg() throws -> Int { defer { ii += 1 }; return try get(ii, rb: rb, mode: argmodes.popLast() ?? .position) }
            func ret(_ value: Int) throws { try set(value, at: ii, rb: rb, mode: .position); ii += 1 }

            do {
                switch command.scheme {
                case (0, false): try (command.function as! () throws -> Void)()
                case (1, false): try (command.function as! (Int) throws -> Void)(arg())
                case (2, false): try (command.function as! (Int, Int) throws -> Void)(arg(), arg())
                case (3, false): try (command.function as! (Int, Int, Int) throws -> Void)(arg(), arg(), arg())
                case (0, true): try ret((command.function as! () throws -> Int)())
                case (1, true): try ret((command.function as! (Int) throws -> Int)(arg()))
                case (2, true): try ret((command.function as! (Int, Int) throws -> Int)(arg(), arg()))
                case (3, true): try ret((command.function as! (Int, Int, Int) throws -> Int)(arg(), arg(), arg()))
                default: throw "Unsupported op scheme: \(command.scheme)"
                }
                state = .running(at: ii, rb: rb)
            } catch ExecutionControl.jump(let address) {
                guard case let .running(_, rb) = state else { throw "Cannot jump while not running (halted)" }
                state = .running(at: address, rb: rb)
            } catch ExecutionControl.adjustRelBase(let offset) {
                guard case let .running(ii, rb) = state else { throw "Cannot relrebase while not running (halted)" }
                state = .running(at: ii, rb: rb + offset)
            } catch ExecutionControl.halt {
                state = .halted
            } catch ExecutionControl.pause {
                guard case let .running(ii, rb) = state else { throw "Cannot pause while not running (halted)" }
                return .paused(at: ii, rb: rb)
            } catch {
                throw error
            }
        }

        return state
    }
}

private enum ArgMode: Int, RawRepresentable {
    case relative = 2
    case immediate = 1
    case position = 0
}
