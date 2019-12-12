import Foundation

func day12(input: String) throws -> String {
    try formatOutput(try solve(input: try parseInput(input)))
}

private func parseInput(_ input: String) throws -> [(x: Int, y: Int, z: Int)] {
    try input.components(separatedBy: .newlines).map {
        let values: [String: Int] = try Dictionary(uniqueKeysWithValues: $0
            .dropFirst()
            .dropLast()
            .components(separatedBy: ", ")
            .map { $0.components(separatedBy: "=") }
            .map { try ($0.get(at: 0), Int($0.get(at: 1)).unwrap(or: "Failed to parse \(try! $0.get(at: 1))")) })
        
        return try (x: values["x"].unwrap(or: "\(values) does not contain x"),
                    y: values["y"].unwrap(or: "\(values) does not contain y"),
                    z: values["z"].unwrap(or: "\(values) does not contain z"))
    }
}

private func formatOutput(_ output: (Int, Int)) throws -> String {
    return "\(output.0)\n\(output.1)\n"
}

private func solve(input: [(x: Int, y: Int, z: Int)]) throws -> (Int, Int) {
    typealias Impulse = (p: Int, v: Int)
    
    func simulate(system s: inout [Impulse]) {
        s.indices.flatMap { i in s.indices.map { j in (i, j) } }.forEach { i, j in s[i].v += (s[j].p - s[i].p).signum() }
        s.indices.forEach { i in s[i].p += s[i].v }
    }
   
    func period(system: [Impulse]) -> Int {
        var s = system
        var i = 0
        repeat {
            i += 1
            simulate(system: &s)
        } while !zip(s, system).allSatisfy({ $0.p == $1.p && $0.v == $1.v })
        return i
    }
    
    var systemX = input.map { Impulse(p: $0.x, v: 0) }
    var systemY = input.map { Impulse(p: $0.y, v: 0) }
    var systemZ = input.map { Impulse(p: $0.z, v: 0) }
        
    let systemPeriod: Int = {
        let periodX = period(system: systemX)
        let periodY = period(system: systemY)
        let periodZ = period(system: systemZ)
        return lcm(lcm(periodX, periodY), periodZ)
    }()

    (0..<1000).forEach { _ in
        simulate(system: &systemX)
        simulate(system: &systemY)
        simulate(system: &systemZ)
    }

    let systemEnergy: Int = zip(systemX, zip(systemY, systemZ))
        .map { (x: $0.0, y: $0.1.0, z: $0.1.1) }
        .map { (a: (x: Impulse, y: Impulse, z: Impulse)) -> Int in
            (abs(a.x.p) + abs(a.y.p) + abs(a.z.p)) * (abs(a.x.v) + abs(a.y.v) + abs(a.z.v))
        }.reduce(0, +)
    
    return (systemEnergy, systemPeriod)
}
