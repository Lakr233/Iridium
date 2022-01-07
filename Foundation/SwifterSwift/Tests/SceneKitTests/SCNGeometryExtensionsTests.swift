//
//  SCNGeometryExtensionsTests.swift
//  SwifterSwift
//
//  Created by Max Härtwig on 06.04.19.
//  Copyright © 2019 SwifterSwift
//

@testable import SwifterSwift
import XCTest

#if canImport(SceneKit)
    import SceneKit

    final class SCNGeometryExtensionsTests: XCTestCase {
        func testBoundingSize() {
            let box = SCNBox(width: 10, height: 20, length: 30, chamferRadius: 0)
            XCTAssertEqual(box.boundingSize, SCNVector3(10, 20, 30))
        }
    }

#endif
