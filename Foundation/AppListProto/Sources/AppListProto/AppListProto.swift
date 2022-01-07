import Foundation

public struct AppListElement: Codable {
    public let bundleURL: URL
    public let bundleIdentifier: String
    public let primaryIconDataBase64: String
    public let localizedName: String
    public let version: String
    public let shortVersion: String

    public init(
        bundleURL: URL,
        bundleIdentifier: String,
        primaryIconDataBase64: String,
        localizedName: String,
        version: String,
        shortVersion: String
    ) {
        self.bundleURL = bundleURL
        self.bundleIdentifier = bundleIdentifier
        self.primaryIconDataBase64 = primaryIconDataBase64
        self.localizedName = localizedName
        self.version = version
        self.shortVersion = shortVersion
    }
}

public struct AppListTransfer: Codable {
    public let applications: [AppListElement]

    public init(applications: [AppListElement]) {
        self.applications = applications
    }

    public static func decode(jsonString: String) -> Self? {
        let decoder = JSONDecoder()
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? decoder.decode(Self.self, from: data)
    }

    public func printJson() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self),
              let str = String(data: data, encoding: .utf8)
        else {
            return
        }
        print(str)
    }
}
