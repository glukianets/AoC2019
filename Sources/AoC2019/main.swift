
import Foundation

let actions: [String: (String) throws -> String] = [
    "day3": day3(input:)
]

func printUsage() -> Never {
    var stderr = FileHandle.standardError
    print("Usage: AoC2019 day[1...25]", to: &stderr)
    exit(1)
}

func printError(_ error: Error) -> Never {
    var stderr = FileHandle.standardError
    print("Error: \(error.localizedDescription)", to: &stderr)
    exit(1)
}

guard CommandLine.arguments.count == 2 else { printUsage() }
guard let input = String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8) else { printError("Failed to read data") }
guard let action = actions[CommandLine.arguments[1]] else { printUsage() }

do {
    FileHandle.standardOutput.write(try action(input))
} catch {
    printError(error)
}
