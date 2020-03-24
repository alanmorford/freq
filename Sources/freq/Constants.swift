import Foundation

extension Freq {
    static var schemeStoragePath: URL {
        guard let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Failed to determine application support directory.")
        }

        return path.appendingPathComponent("com.github.ileitch.freq/schemes")
    }
}
