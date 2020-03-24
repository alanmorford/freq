import Foundation

enum SortOption: String, CaseIterable {
    case frequecy
    case durationMean = "duration-mean"
    case durationStdev = "duration-stdev"

    func sort(results: [SourceFileResult]) -> [SourceFileResult] {
        switch self {
        case .frequecy:
            return results.sorted(by: sortByFrequency)
        case .durationMean:
            return results.sorted(by: sortByDurationMean)
        case .durationStdev:
            return results.sorted(by: sortByDurationStdev)
        }
    }
}

private var sortByFrequency: (SourceFileResult, SourceFileResult) -> Bool = {
    if $0.frequency == $1.frequency {
        return $0.path.path.compare($1.path.path) == .orderedAscending
    } else {
        return $0.frequency > $1.frequency
    }
}

private var sortByDurationMean: (SourceFileResult, SourceFileResult) -> Bool = {
    if $0.durationMean == $1.durationMean {
        return $0.path.path.compare($1.path.path) == .orderedAscending
    } else {
        return $0.durationMean > $1.durationMean
    }
}

private var sortByDurationStdev: (SourceFileResult, SourceFileResult) -> Bool = {
    if $0.durationStdev == $1.durationStdev {
        return $0.path.path.compare($1.path.path) == .orderedAscending
    } else {
        return $0.durationStdev > $1.durationStdev
    }
}
