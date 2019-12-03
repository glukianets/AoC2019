import XCTest
import class Foundation.Bundle

extension String: Error { }

final class AoC2019Tests: XCTestCase {
    static var allTests = [
        ("testDay3", testDay3),
    ]

    func testDay1() throws {
        let cases = [
            "14": (2, 2),
            "1969": (654, 966),
            "100756": (33583, 50346)
        ]

        try self.runTestCases(cases, forDay: 1)
    }

    func testDay3() throws {
        let cases = [
            """
            R75,D30,R83,U83,L12,D49,R71,U7,L72
            U62,R66,U55,R34,D71,R55,D58,R83
            """: (159, 610),
            """
            R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
            U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
            """: (135, 410),
        ]

        try self.runTestCases(cases, forDay: 3)
    }

    private var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    private func runTestCases(_ cases: [String: (Int, Int)], forDay day: Int) throws {
        for (i, (input, result)) in cases.enumerated() {
            guard let output = try runBinary(arguments: ["day\(day)"], input: input), output.count > 0 else { throw "case \(i) returned empty result" }
            let numbers = output.components(separatedBy: .whitespaces).compactMap { Int($0) }
            guard numbers.count == 2 else { throw "case \(i) returned output in invalid format: \(output)" }
            XCTAssertEqual(result.0, numbers[0])
            XCTAssertEqual(result.1, numbers[1])
        }
    }

    private func runBinary(arguments: [String]? = nil, input: String? = nil) throws -> String? {
        guard #available(macOS 10.13, *) else { return nil }

        let fooBinary = productsDirectory.appendingPathComponent("AoC2019")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = arguments

        let outPipe = Pipe()
        process.standardOutput = outPipe

        let inPipe = Pipe()
        process.standardInput = inPipe

        try process.run()

        input.flatMap { $0.data(using: .utf8) }.map { inPipe.fileHandleForWriting.write($0) }
        inPipe.fileHandleForWriting.closeFile()

        process.waitUntilExit()

        let output = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)

        return output
    }
}
