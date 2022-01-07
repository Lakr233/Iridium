//
//  SCNMaterialExtensionsTests.swift
//  SwifterSwift
//
//  Created by Max Härtwig on 06.04.19.
//  Copyright © 2019 SwifterSwift
//

@testable import SwifterSwift
import XCTest

#if canImport(SceneKit)
    import SceneKit

    final class SCNMaterialExtensionsTests: XCTestCase {
        func testInitWithColor() {
            let color = Color.red
            let material = SCNMaterial(color: color)
            XCTAssertEqual(material.diffuse.contents as? Color, color)
        }
    }

#endif
