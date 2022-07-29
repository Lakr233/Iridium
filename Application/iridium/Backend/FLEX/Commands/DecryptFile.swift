//
//  DecryptFile.swift
//  Created on 6/30/20
//

import Foundation

func decryptFile(at: URL, write: URL) throws {
    let file = try MachOFile(url: at)
    let data = try file.sliceDataForHostArchitecture()
    try data.write(to: write)
    print("Wrote decrypted image to \(write.path)")
}
