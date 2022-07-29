//
//  AppList.swift
//  iridium
//
//  Created by QAQ on 2022/12/11.
//

import Foundation

public struct AppListElement: Codable {
    public let bundleURL: URL
    public let bundleIdentifier: String
    public let primaryIconData: Data
    public let localizedName: String
    public let version: String
    public let shortVersion: String

    public init(
        bundleURL: URL,
        bundleIdentifier: String,
        primaryIconData: Data,
        localizedName: String,
        version: String,
        shortVersion: String
    ) {
        self.bundleURL = bundleURL
        self.bundleIdentifier = bundleIdentifier
        self.primaryIconData = primaryIconData
        self.localizedName = localizedName
        self.version = version
        self.shortVersion = shortVersion
    }

    public init?(bundle: Bundle) {
        guard let bundleIdentifier = bundle.bundleIdentifier else {
            return nil
        }
        let appDir = URL(fileURLWithPath: bundle.bundlePath)

        let localizedDisplayName = bundle
            .localizedInfoDictionary?["CFBundleDisplayName"] as? String
            ?? bundle
            .infoDictionary?["CFBundleDisplayName"] as? String
            ?? bundleIdentifier

        let version = bundle
            .infoDictionary?["CFBundleVersion"] as? String
            ?? "0"

        let shortVersion = bundle
            .infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "0"

        var iconData = Data()
        repeat {
            guard let contents = try? FileManager
                .default
                .contentsOfDirectory(atPath: appDir.path)
            else {
                break
            }

            var iconPrefix = "AppIcon"
            if let icons = bundle.infoDictionary?["CFBundleIcons"] as? [String: Any],
               let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
               let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
               let lastIcon = iconFiles.last
            {
                iconPrefix = lastIcon
            }

            let appIcon = contents
                .filter { $0.hasPrefix(iconPrefix) && $0.hasSuffix(".png") }
                .sorted { a, b in
                    let urlA = appDir.appendingPathComponent(a)
                    let urlB = appDir.appendingPathComponent(b)
                    return urlA.fileSize > urlB.fileSize
                }
                .first
            guard let appIcon else {
                break
            }
            let url = appDir.appendingPathComponent(appIcon)
            if let data = try? Data(contentsOf: url) {
                iconData = data
            }
        } while false

        self.init(
            bundleURL: bundle.bundleURL,
            bundleIdentifier: bundle.bundleIdentifier ?? "",
            primaryIconData: iconData,
            localizedName: localizedDisplayName,
            version: version,
            shortVersion: shortVersion
        )
    }
}

extension URL {
    var attributes: [FileAttributeKey: Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        attributes?[.creationDate] as? Date
    }
}
