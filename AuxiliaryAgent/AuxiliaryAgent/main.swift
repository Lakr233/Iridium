//
//  main.swift
//  AuxiliaryAgent
//
//  Created by Lakr Aream on 2022/1/7.
//

import AppListProto
import UIKit

if CommandLine.arguments[1] == "exec" {
    // MARK: - EXEC

    root_check()
    root_me()
    root_exec(CommandLine.argc, CommandLine.unsafeArgv)
    exit(EX_UNAVAILABLE)

} else if CommandLine.arguments[1] == "list" {
    // MARK: - APPLIST

    root_check()
    root_me()

    var codingElements = [AppListElement]()

    let base = URL(fileURLWithPath: "/var/containers/Bundle/Application")
    let applications = (
        try? FileManager
            .default
            .contentsOfDirectory(atPath: base.path)
    ) ?? []
    for uuid in applications {
        let prefix = base.appendingPathComponent(uuid)
        guard let items = try? FileManager
            .default
            .contentsOfDirectory(atPath: prefix.path)
        else {
            continue
        }
        let dirs = items
            .filter { $0.hasSuffix(".app") }
        guard dirs.count == 1 else { continue }
        let appDir = prefix.appendingPathComponent(dirs[0])
        guard let bundle = Bundle(path: appDir.path),
              let bundleIdentifier = bundle.bundleIdentifier
        else {
            continue
        }
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

        var iconBase64Str = ""
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
            guard let appIcon = appIcon else {
                break
            }
            let url = appDir.appendingPathComponent(appIcon)
            guard let image = UIImage(contentsOfFile: url.path),
                  let data = image.pngData()
            else {
                break
            }
            iconBase64Str = data.base64EncodedString()
        } while false

        let element = AppListElement(
            bundleURL: bundle.bundleURL,
            bundleIdentifier: bundle.bundleIdentifier ?? "",
            primaryIconDataBase64: iconBase64Str,
            localizedName: localizedDisplayName,
            version: version,
            shortVersion: shortVersion
        )

        codingElements.append(element)
    }

    let transfer = AppListTransfer(applications: codingElements)
    transfer.printJson()

    exit(0)

} else if CommandLine.arguments[1] == "copy" {
    // MARK: - COPY FILE

    root_check()
    root_me()

    let from = URL(fileURLWithPath: CommandLine.arguments[2])
    let dest = URL(fileURLWithPath: CommandLine.arguments[3])
    try FileManager.default.copyItem(at: from, to: dest)

    exit(0)

} else if CommandLine.arguments[1] == "delete" {
    // MARK: - DELETE FILE

    root_check()
    root_me()

    try FileManager.default.removeItem(atPath: CommandLine.arguments[2])

    exit(0)

} else {
    // MARK: - WHO ARE YOU?

    exit(EX_UNAVAILABLE)
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
