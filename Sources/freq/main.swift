import ArgumentParser

struct Freq: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for analyzing Xcode incremental build behavior.",
        subcommands: [Collect.self, Analyze.self])

    struct Collect: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Collect most recent build log for analysis.")

        func run() throws {
            try Collector().run()
        }
    }

    struct Analyze: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Analyze collected build logs.")

        @Option(parsing: .upToNextOption,
                help: "Relative paths to exclude.")
        var exclude: [String]

        @Option(
            default: .frequecy,
            help: "\(SortOption.allCases.map { $0.rawValue }.joined(separator: ", "))")
        var sort: SortOption

        @Option(
            default: .text,
            help: "\(ReporterOption.allCases.map { $0.rawValue }.joined(separator: ", "))")
        var reporter: ReporterOption

        @Flag(name: .shortAndLong, help: "Enable verbose output.")
        var verbose: Bool

        func run() throws {
            try Analyzer().run(
                excludeOptions: exclude,
                sortOption: sort,
                reporterOption: reporter)
        }
    }
}

extension ReporterOption: ExpressibleByArgument {}
extension SortOption: ExpressibleByArgument {}

Freq.main()
