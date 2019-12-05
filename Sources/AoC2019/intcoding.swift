import Foundation

struct Intcoder {
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
        case halt
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
            99: Command { () -> Void in throw ExecutionControl.halt },
        ])
    }

    func run(_ ll: inout [Int]) throws {
        var ii = 0
        var halt = false

        func get(_ i: Int, mode: ArgMode) throws -> Int {
            switch mode {
            case .immediate: return try ll.get(at: i)
            case .position: return try ll.get(at: ll.get(at: i))
            }
        }

        func set(_ value: Int, at index: Int, mode: ArgMode) throws {
            switch mode {
            case .immediate: try ll.set(value, at: index)
            case .position: try ll.set(value, at: ll.get(at: index))
            }
        }

        while !halt {
            let opcode = try get(ii, mode: .immediate)
            ii += 1
            var argmodes = try (opcode / 100).digits.map { try ArgMode(rawValue: $0).unwrap(or: "Unrecognized arg mode: \($0) in \(opcode)") }
            let code = opcode % 100
            let command = try commands[code].unwrap(or: "Unrecognized command code: \(code) in \(opcode)")

            func arg() throws -> Int { defer { ii += 1 }; return try get(ii, mode: argmodes.popLast() ?? .position) }
            func ret(_ value: Int) throws { try set(value, at: ii, mode: .position); ii += 1 }

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
            } catch ExecutionControl.jump(let address) {
                print("jmp ", address)
                ii = address
            } catch ExecutionControl.halt {
                halt = true
            } catch {
                throw error
            }
        }
        print("HALT")
    }
}

private enum ArgMode: Int, RawRepresentable {
    case immediate = 1
    case position = 0
}
