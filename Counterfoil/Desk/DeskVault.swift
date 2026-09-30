import Foundation

/// Role: Desk. Projects Desk to UserDefaults ctf.desk.v1 plus an atomic Application Support file. Views never touch this type.
actor DeskVault {
    private let directory: URL
    private let suiteName: String?
    private let fileManager: FileManager

    init(
        directory: URL,
        suiteName: String? = nil,
        fileManager: FileManager = .default
    ) {
        self.directory = directory
        self.suiteName = suiteName
        self.fileManager = fileManager
    }

    nonisolated static func supportDirectory(fileManager: FileManager = .default) throws -> URL {
        let root = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return root.appendingPathComponent("Winodroll", isDirectory: true)
    }

    func load() -> (desk: Desk, warning: DeskWarning?) {
        if let desk = decode(box().data(forKey: DeskKey.snapshot)) {
            return (desk, nil)
        }
        if let desk = decode(read(fileURL)) {
            return (desk, nil)
        }
        if let desk = decode(box().data(forKey: DeskKey.backup)) {
            return (desk, .recoveredFromBackup)
        }
        if let desk = decode(read(backupURL)) {
            return (desk, .recoveredFromBackup)
        }
        let hadPayload = box().data(forKey: DeskKey.snapshot) != nil
            || fileManager.fileExists(atPath: fileURL.path)
        return (.empty, hadPayload ? .startedEmpty : nil)
    }

    func save(_ desk: Desk) throws {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try DeskDocument.encode(desk)
        let defaults = box()
        if let current = defaults.data(forKey: DeskKey.snapshot) {
            defaults.set(current, forKey: DeskKey.backup)
        }
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: backupURL)
            try? fileManager.copyItem(at: fileURL, to: backupURL)
        }
        defaults.set(data, forKey: DeskKey.snapshot)
        try data.write(to: fileURL, options: .atomic)
        excludeCacheIfPresent()
    }

    func wipe() throws {
        let defaults = box()
        defaults.removeObject(forKey: DeskKey.snapshot)
        defaults.removeObject(forKey: DeskKey.backup)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        if fileManager.fileExists(atPath: backupURL.path) {
            try fileManager.removeItem(at: backupURL)
        }
        if fileManager.fileExists(atPath: cacheURL.path) {
            try fileManager.removeItem(at: cacheURL)
        }
    }

    func demoPlanted() -> Bool {
        box().object(forKey: DeskKey.demo) != nil
    }

    func markDemoPlanted() {
        box().set(true, forKey: DeskKey.demo)
    }

    private func decode(_ data: Data?) -> Desk? {
        guard let data else { return nil }
        return try? DeskDocument.decode(data)
    }

    private func read(_ url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    private var fileURL: URL {
        directory.appendingPathComponent("desk.json", isDirectory: false)
    }

    private var backupURL: URL {
        directory.appendingPathComponent("desk.json.backup", isDirectory: false)
    }

    private var cacheURL: URL {
        directory.appendingPathComponent("net-cache.json", isDirectory: false)
    }

    private func excludeCacheIfPresent() {
        guard fileManager.fileExists(atPath: cacheURL.path) else { return }
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var url = cacheURL
        try? url.setResourceValues(values)
    }

    private func box() -> UserDefaults {
        if let suiteName {
            return UserDefaults(suiteName: suiteName) ?? UserDefaults()
        }
        return .standard
    }
}
