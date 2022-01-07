//
//  SettingView.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import DropDown
import SnapKit
import UIKit

class SettingView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    let padding = 18

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"

        view.addSubview(tableView)
        tableView.snp.makeConstraints { x in
            x.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.tintColor = .clear
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        20
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.row {
        case 1:
            let imageView = UIImageView(image: UIImage(named: "avatar"))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            cell.contentView.addSubview(imageView)
            imageView.snp.makeConstraints { x in
                x.left.equalToSuperview().offset(padding)
                x.width.equalTo(20)
                x.height.equalTo(20)
                x.centerY.equalToSuperview()
            }
            imageView.cornerRadius = 5
            let title = UILabel()
            title.text = "Iridium"
            title.font = .systemFont(ofSize: 18, weight: .semibold)
            cell.contentView.addSubview(title)
            title.snp.makeConstraints { x in
                x.left.equalTo(imageView.snp.right).offset(8)
                x.centerY.equalTo(imageView.snp.centerY)
            }
        case 2:
            let text = "Version \(UIApplication.shared.version ?? "0.0") Build \(UIApplication.shared.buildNumber ?? "0")"
            let view = makeTintTextView()
            view.text = text
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.edges.equalToSuperview().inset(
                    UIEdgeInsets(
                        top: 0,
                        left: CGFloat(padding),
                        bottom: 0,
                        right: CGFloat(padding)
                    ))
            }
        case 3:
            let view = makeLeftAligButton()
            view.setTitle("Open Packages In Filza", for: .normal)
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.left.equalToSuperview().offset(padding)
                x.top.equalToSuperview()
                x.bottom.equalToSuperview()
                x.width.equalTo(250)
            }
            view.addTarget(self, action: #selector(openArchive), for: .touchUpInside)
        case 4:
            let view = makeLeftAligButton()
            view.setTitle("Select KernInfra Backend", for: .normal)
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.left.equalToSuperview().offset(padding)
                x.top.equalToSuperview()
                x.bottom.equalToSuperview()
                x.width.equalTo(250)
            }
            view.addTarget(self, action: #selector(selectBackend), for: .touchUpInside)
        case 5:
            let view = makeLeftAligButton()
            view.setTitle("Clear Documents", for: .normal)
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.left.equalToSuperview().offset(padding)
                x.top.equalToSuperview()
                x.bottom.equalToSuperview()
                x.width.equalTo(250)
            }
            view.addTarget(self, action: #selector(clearDocuments), for: .touchUpInside)
        case 6:
            let view = makeTintTextView()
            view.text = """
            Iridium is powered by FoulDecrypt.

            FoulDecrypt supports iOS 13.5 and later, and has been tested on iOS 14.2, 14.3 and 13.5 (both arm64 and arm64e).

            Any code inside application binary will not be able to execute thanks to our full static decrypter.
            """
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.edges.equalToSuperview().inset(
                    UIEdgeInsets(
                        top: 0,
                        left: CGFloat(padding),
                        bottom: 0,
                        right: CGFloat(padding)
                    ))
            }
        case 7:
            let view = makeLeftAligButton()
            view.setTitle("Get Source: [Iridium]", for: .normal)
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.left.equalToSuperview().offset(padding)
                x.top.equalToSuperview()
                x.bottom.equalToSuperview()
                x.width.equalTo(250)
            }
            view.addTarget(self, action: #selector(openSourceIridium), for: .touchUpInside)
        case 8:
            let view = makeLeftAligButton()
            view.setTitle("Get Source: [FoulDecrypt]", for: .normal)
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.left.equalToSuperview().offset(padding)
                x.top.equalToSuperview()
                x.bottom.equalToSuperview()
                x.width.equalTo(250)
            }
            view.addTarget(self, action: #selector(openSourceFoul), for: .touchUpInside)
        case 9:
            let view = makeTintTextView()
            view.text = """
            Copyright © 2022 Lakr Aream All Rights Reserved
            """
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.edges.equalToSuperview().inset(
                    UIEdgeInsets(
                        top: 0,
                        left: CGFloat(padding),
                        bottom: 0,
                        right: CGFloat(padding)
                    ))
            }
        case 10:
            let view = makeLeftAligButton()
            view.setTitle("Twitter: @Lakr233", for: .normal)
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { x in
                x.left.equalToSuperview().offset(padding)
                x.top.equalToSuperview()
                x.bottom.equalToSuperview()
                x.width.equalTo(250)
            }
            view.addTarget(self, action: #selector(openTwitter), for: .touchUpInside)
        default:
            break
        }
        return cell
    }

    func makeTintTextView() -> UITextView {
        let view = UITextView()
        view.font = .systemFont(ofSize: 10, weight: .semibold)
        view.textColor = .gray
        view.contentInset = UIEdgeInsets(inset: 0)
        view.textContainer.lineFragmentPadding = 0
        return view
    }

    func makeLeftAligButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        button.setTitleColor(.orange, for: .focused)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return button
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 0
        case 1:
            return 40
        case 2:
            return 30
        case 3, 4, 5: // button
            return 25
        case 6: // text
            return 115
        case 7, 8: // button
            return 25
        case 9:
            return 30
        case 10:
            return 25
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @objc func openSourceIridium() {
        let url = URL(string: "https://github.com/Co2333/Iridium")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func openSourceFoul() {
        let url = URL(string: "https://github.com/NyaMisty/fouldecrypt")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func openTwitter() {
        let url = URL(string: "https://twitter.com/Lakr233")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func openArchive() {
        let archiveDir = documentsDirectory
            .appendingPathComponent("Packages")
        archiveDir.openInFilza()
    }

    struct SelectAction {
        let text: String
        let action: (UIViewController) -> Void
    }

    func buildActionList() -> [SelectAction] {
        [
            .init(text: "Auto Switch", action: { _ in
                Agent.shared.foulOption = .unspecified
            }),
            .init(text: "TFP0", action: { _ in
                Agent.shared.foulOption = .tfp0
            }),
            .init(text: "KRW - uncover", action: { _ in
                Agent.shared.foulOption = .krw
            }),
            .init(text: "KERNRW - taurine", action: { _ in
                Agent.shared.foulOption = .kernrw
            }),
            .init(text: "Cancel", action: { _ in }),
        ]
    }

    @objc func selectBackend(sender: UIButton) {
        let actions = buildActionList()
        let dropDown = DropDown(anchorView: sender)
        dropDown.dataSource = actions
            .map(\.text)
            .invisibleSpacePadding()
        dropDown.selectionAction = { [self] (index: Int, _: String) in
            guard index >= 0, index < actions.count else { return }
            let action = actions[index]
            action.action(self)
        }
        dropDown.show(onTopOf: view.window)
    }

    @objc func clearDocuments(sender: UIButton) {
        let actions: [SelectAction] = [
            .init(text: "Confirm", action: { _ in
                Agent.shared.clearDocuments()
            }),
            .init(text: "Cancel", action: { _ in }),
        ]
        let dropDown = DropDown(anchorView: sender)
        dropDown.dataSource = actions
            .map(\.text)
            .invisibleSpacePadding()
        dropDown.selectionAction = { [self] (index: Int, _: String) in
            guard index >= 0, index < actions.count else { return }
            let action = actions[index]
            action.action(self)
        }
        dropDown.show(onTopOf: view.window)
    }
}
