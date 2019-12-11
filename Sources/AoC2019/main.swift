
import Foundation

let actions: [String: (String) throws -> String] = [
    "day1": day1(input:),
    "day2": day2(input:),
    "day3": day3(input:),
    "day4": day4(input:),
    "day5": day5(input:),
    "day6": day6(input:),
    "day7": day7(input:),
    "day8": day8(input:),
    "day9": day9(input:),
    "day10": day10(input:),
    "day11": day11(input:),
    "debug": day11(input:),
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
