//
//  AppDelegate.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import DropDown
import SPIndicator
import UIKit
import ZipArchive

class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        super.init()

        do {
            DropDown.startListeningToKeyboard()

            let appearance = DropDown.appearance()
            appearance.textColor = UIColor(light: .black,
                                           dark: .white)
            appearance.selectedTextColor = UIColor.white
            appearance.textFont = .systemFont(ofSize: 18, weight: .semibold)
            appearance.backgroundColor = UIColor(light: .white,
                                                 dark: .init(hex: 0x2C2C2E)!)
            appearance.shadowColor = .black
            appearance.setupShadowOpacity(0.1)
            appearance.selectionBackgroundColor = UIColor(hex: 0x93D5DC)!
            appearance.layer.shadowOpacity = 0.1
            appearance.cellHeight = 60
        }

        if !Agent.shared.agentPermissionValidate() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if Agent.shared.binaryLocation == nil {
                    SPIndicator.present(
                        title: "Auxiliary Agent Missing",
                        preset: .error,
                        haptic: .error
                    )
                } else {
                    SPIndicator.present(
                        title: "Agent Error Permit",
                        preset: .error,
                        haptic: .error
                    )
                }
            }
        }
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
