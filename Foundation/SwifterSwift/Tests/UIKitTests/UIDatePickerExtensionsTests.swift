//
//  UIDatePickerExtensionsTests.swift
//  SwifterSwift
//
//  Created by Omar Albeik on 12/9/17.
//  Copyright © 2017 SwifterSwift
//

@testable import SwifterSwift
import XCTest

#if canImport(UIKit) && os(iOS)
    import UIKit

    final class UIDatePickerExtensionsTests: XCTestCase {
        func testTextColor() {
            let datePicker = UIDatePicker()
            if let color = datePicker.textColor {
                XCTAssertNotEqual(color, .red)
            }

            datePicker.textColor = .red
            XCTAssertEqual(datePicker.textColor, .red)

            datePicker.textColor = .green
            XCTAssertEqual(datePicker.textColor, .green)

            datePicker.textColor = nil
            XCTAssertNil(datePicker.textColor)
        }
    }

#endif
