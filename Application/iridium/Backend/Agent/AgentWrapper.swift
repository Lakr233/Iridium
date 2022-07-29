//
//  AgentWrapper.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import AuxiliaryExecute
import Foundation
import MachO
import PropertyWrapper
import SPIndicator
import UIKit
import ZipArchive

private let binaryName = Bundle.main.executablePath!

class Agent {
    static let shared = Agent()

    public func generateAppList() -> [AppListElement] {
        #if targetEnvironment(macCatalyst)
            let base = URL(fileURLWithPath: "/Applications")
            return ((try? FileManager.default.contentsOfDirectory(atPath: base.path)) ?? [])
                .map { URL(fileURLWithPath: "/Applications/\($0)/Wrapper/") }
                .compactMap { container -> URL? in
                    guard let content = try? FileManager.default.contentsOfDirectory(atPath: container.path) else { return nil }
                    var found: URL?
                    for item in content where item.lowercased().hasSuffix(".app") {
                        guard found == nil else { return nil }
                        found = container.appendingPathComponent(item)
                    }
                    return found
                }
                .compactMap { Bundle(path: $0.path) }
                .compactMap { AppListElement(bundle: $0) }
                .filter { !$0.bundleIdentifier.hasPrefix("com.apple") }
        #else
            let base = URL(fileURLWithPath: "/var/containers/Bundle/Application")
            return ((try? FileManager.default.contentsOfDirectory(atPath: base.path)) ?? [])
                .map { URL(fileURLWithPath: "/var/containers/Bundle/Application/\($0)/") }
                .compactMap { container -> URL? in
                    guard let content = try? FileManager.default.contentsOfDirectory(atPath: container.path) else { return nil }
                    var found: URL?
                    for item in content where item.lowercased().hasSuffix(".app") {
                        guard found == nil else { return nil }
                        found = container.appendingPathComponent(item)
                    }
                    return found
                }
                .compactMap { Bundle(path: $0.path) }
                .compactMap { AppListElement(bundle: $0) }
                .filter { !$0.bundleIdentifier.hasPrefix("com.apple") }
        #endif
    }

    public func decryptApplication(with app: AppListElement, output: @escaping (String) -> Void) -> URL? {
        var targetDir: URL
        let targetAppDir: URL
        let targetZipLocation: URL
        let payloadDir: URL
        do {
            targetDir = documentsDirectory
                .appendingPathComponent("Temporary")
                .appendingPathComponent(UUID().uuidString)
            payloadDir = targetDir.appendingPathComponent("Payload")
            try FileManager.default.createDirectory(at: payloadDir, withIntermediateDirectories: true)
            targetAppDir = payloadDir.appendingPathComponent(app.bundleURL.lastPathComponent)
            try? FileManager.default.removeItem(at: targetAppDir)
            try FileManager.default.copyItem(at: app.bundleURL, to: targetAppDir)
            targetZipLocation = documentsDirectory
                .appendingPathComponent("Packages")
                .appendingPathComponent("\(app.bundleIdentifier).\(app.version).\(app.shortVersion)")
                .appendingPathExtension("ipa")
        } catch {
            output("[E] Error occurred: \(error.localizedDescription)\n")
            try? FileManager.default.removeItem(at: targetDir)
            return nil
        }

        let iter = FileManager.default.enumerator(atPath: targetAppDir.path)
        while let nextTarget = iter?.nextObject() as? String {
            let target = targetAppDir.appendingPathComponent(nextTarget)
            output("[*] processing \(nextTarget)\n")
            patchMachO(at: target) { print($0) }
        }

        output("\n\n[*] Emitting installer package...\n")
        print("zip \(payloadDir) -> \(targetZipLocation)")

        let zipDir = targetZipLocation.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: zipDir, withIntermediateDirectories: true)
        let zipSource = payloadDir.deletingLastPathComponent()

        let requiredDot = 25 // 4 percent each lol
        output("\n")
        output([String](repeating: ".", count: requiredDot).joined(separator: ""))
        var currentProgress = [String]()
        output(" [100%]\n")
        let result = SSZipArchive.createZipFile(
            atPath: targetZipLocation.path,
            withContentsOfDirectory: zipSource.path,
            keepParentDirectory: false,
            compressionLevel: 0,
            password: nil,
            aes: false
        ) { entryNumber, total in
            let percent = Double(entryNumber) / Double(total)
            let currentDot = Int(percent * Double(requiredDot))
            while currentDot > currentProgress.count {
                currentProgress.append("=")
                output("=")
            }
        }
        output(" ++++++\n")

        try? FileManager.default.removeItem(at: targetDir)

        output("\n")
        if result {
            output("[*] Installer package available at \(targetZipLocation.path)\n")
            output("[*] rootless/krwless version of iridium could not handle unaligned decryption memory, resulting non working package. KernInfra needs update.")

            return targetZipLocation
        } else {
            output("[*] Failed to create archive\n")
            return nil
        }
    }

    func clearDocuments() {
        let urls = [
            documentsDirectory
                .appendingPathComponent("Temporary"),
            documentsDirectory
                .appendingPathComponent("Packages"),
        ]
        for item in urls {
            try? FileManager.default.removeItem(at: item)
        }
        SPIndicator.present(
            title: "Packages Cleared",
            preset: .done,
            haptic: .success
        )
    }

    func patchMachO(at: URL, output: @escaping (String) -> Void) {
        do {
            try decryptFile(at: at, write: at)
        } catch {
            output("[E] \(error.localizedDescription)\n")
        }
//        AuxiliaryExecute.spawn(
//            command: Bundle.main.executablePath!,
//            args: [at.path, at.path],
//            environment: [:],
//            timeout: 0,
//            setPid: nil
//        )
//            { output($0) }
    }
}

private extension Data {
    typealias SizeType = UInt32
    var magic: SizeType? {
        guard count >= MemoryLayout<SizeType>.size else { return nil }
        return withUnsafeBytes { $0.load(as: SizeType.self) }
    }
}
