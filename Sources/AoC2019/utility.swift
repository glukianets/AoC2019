import Foundation

extension String: Error {}

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
}
