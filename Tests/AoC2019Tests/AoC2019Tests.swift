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
    
    func testDay2() throws {
        let cases = [
            """
            1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,10,19,1,19,6,23,2,23,13,27,1,27,5,31,2,31,10,35,1,9,35,39,1,39,9,43,2,9,43,47,1,5,47,51,2,13,51,55,1,55,9,59,2,6,59,63,1,63,5,67,1,10,67,71,1,71,10,75,2,75,13,79,2,79,13,83,1,5,83,87,1,87,6,91,2,91,13,95,1,5,95,99,1,99,2,103,1,103,6,0,99,2,14,0,0
            """: (3790645, 6577),
            
            """
            1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,13,1,19,1,10,19,23,1,6,23,27,1,5,27,31,1,10,31,35,2,10,35,39,1,39,5,43,2,43,6,47,2,9,47,51,1,51,5,55,1,5,55,59,2,10,59,63,1,5,63,67,1,67,10,71,2,6,71,75,2,6,75,79,1,5,79,83,2,6,83,87,2,13,87,91,1,91,6,95,2,13,95,99,1,99,5,103,2,103,10,107,1,9,107,111,1,111,6,115,1,115,2,119,1,119,10,0,99,2,14,0,0
            """: (5482655, 4967),

            """
            1,0,0,0,99,19690719,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
            """: (2, 5),

            """
            2,5,6,0,99,9845360,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
            """: (0, 5),
        ]
        
        try self.runTestCases(cases, forDay: 2)
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
