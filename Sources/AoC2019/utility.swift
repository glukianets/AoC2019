import Foundation

extension String: Error {}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

extension Optional {
    func unwrap(or error: @autoclosure () -> Error = "OptionalUnwrapError") throws -> Wrapped {
        guard let wrapped = self else { throw error() }
        return wrapped
    }
}

extension Collection {
    func intoArray() -> [Element] { .init(self) }

    subscript(safe index: Self.Index) -> Self.Element? {
        self.indices.contains(index) ? self[index] : nil
    }

    func get(at index: Self.Index) throws -> Self.Element {
        guard self.indices.contains(index) else { throw "Index \(index) is out of bounds" }
        return self[index]
    }

    var intervals: [(first: Self.Element, second: Self.Element)] {
        guard !self.isEmpty else { return [] }
        return self.dropFirst().reduce(into: []) { a, e in a.append(a.last.map { ($0.second, e) } ?? (self.first!, e)) }
    }

    func grouping<T: Equatable>(by trait: (Self.Element) -> T) -> [Self.SubSequence] {
        var result: [Self.SubSequence] = []
        var state: (t: T, i: Self.Index)? = nil

        for i in self.indices {
            let t = trait(self[i])
            guard let s = state else { state = (t: t, i: i); continue }
            guard s.t != t else { continue }
            result.append(self[s.i..<i])
            state = (t: t, i: i)
        }

        state.map { result.append(self[$0.i...]) }

        return result
    }

    func grouping(by count: Int) -> [Self.SubSequence] {
        guard count > 0 else { return [] }
        guard count < self.count else { return [self[self.startIndex..<self.endIndex]] }
        return (0 ... (self.count - 1) / count).map { self.dropLast($0 * count).suffix(count) }.reversed()
    }
}

extension Array {
    subscript(safe index: Self.Index) -> Self.Element? {
        get {
            self.indices.contains(index) ? self[index] : nil
        }
        set {
            guard self.indices.contains(index) else { return }
            if let value = newValue {
                self[index] = value
            } else {
                self.remove(at: index)
            }
        }
    }

    mutating func set(_ value: Self.Element, at index: Self.Index) throws {
        guard self.indices.contains(index) else { throw "Index \(index) is out of bounds" }
        return self[index] = value
    }
}

extension BinaryInteger {
    var digits: [Self] {
        guard self != 0 else { return [0] }
        var result: [Self] = []
        var num = self
        while num > 0 {
            result.append(num % 10)
            num /= 10
        }
        return result.reversed()
    }
}
