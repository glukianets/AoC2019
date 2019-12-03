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
    func unwrap() throws -> Wrapped {
        guard let wrapped = self else { throw "Optional unwrap error" }
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
