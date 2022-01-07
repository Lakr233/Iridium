//
//  main.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import UIKit

if getuid() == 0 {
    setuid(501)
    setgid(501)
}

private let availableDirectories = FileManager
    .default
    .urls(for: .documentDirectory, in: .userDomainMask)
public let documentsDirectory = availableDirectories[0]
    .appendingPathComponent("wiki.qaq.iridium")
if documentsDirectory.path.count < 2 {
    fatalError("malformed system resources")
}

try? FileManager.default.createDirectory(
    at: documentsDirectory,
    withIntermediateDirectories: true,
    attributes: nil
)

FileManager.default.changeCurrentDirectoryPath(documentsDirectory.path)

_ = Agent.shared

try? FileManager
    .default
    .removeItem(at: documentsDirectory.appendingPathComponent("Temporary"))

private let application = UIApplication.shared
private let delegate = AppDelegate()
application.delegate = delegate

_ = UIApplicationMain(CommandLine.argc,
                      CommandLine.unsafeArgv,
                      nil,
                      NSStringFromClass(AppDelegate.self))
