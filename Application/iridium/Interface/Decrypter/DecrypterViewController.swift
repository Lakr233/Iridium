//
//  DecrypterViewController.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import DropDown
import SnapKit
import UIKit

class DecrypterViewController: UIViewController {
    var app: AppListElement?

    var decryptResult: URL?

    let padding = 15
    let textView = UITextView()
    let completeBox = UIView()
    let dropDownAnchor = UIView()
    var dispatchOnce: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        isModalInPresentation = true
        view.backgroundColor = .systemBackground
        title = "Console"

        textView.backgroundColor = .clear
        textView.clipsToBounds = false

        textView.font = .monospacedSystemFont(ofSize: 12, weight: .bold)

        textView.isEditable = false
        textView.isSelectable = true
        textView.textColor = .gray
        textView.contentInset = UIEdgeInsets(inset: 0)
        textView.textContainer.lineFragmentPadding = 0
        view.addSubview(textView)
        textView.snp.makeConstraints { x in
            x.top.equalTo(view.snp.top).offset(28)
            x.bottom.equalTo(view.snp.bottom).offset(-28)
            x.left.equalTo(view.snp.left)
            x.right.equalTo(view.snp.right)
        }

        if navigationController == nil {
            let bigTitle = UILabel()
            bigTitle.text = "Console"
            bigTitle.font = .systemFont(ofSize: 28, weight: .bold)
            view.addSubview(bigTitle)
            bigTitle.snp.makeConstraints { x in
                x.leading.equalToSuperview().offset(padding)
                x.trailing.equalToSuperview().offset(-padding)
                x.top.equalToSuperview().offset(20)
                x.height.equalTo(40)
            }
            textView.clipsToBounds = true
            textView.snp.remakeConstraints { x in
                x.top.equalTo(bigTitle.snp.bottom).offset(20)
                x.bottom.equalTo(view.snp.bottom).offset(-28)
                x.left.equalTo(view.snp.left).offset(padding)
                x.right.equalTo(view.snp.right).offset(-padding)
            }
        }

        textView.text = "Preparing operations...\n\n"

        let completeIcon = UIImageView()
        let completeButton = UIButton()
        view.addSubview(completeBox)
        view.addSubview(completeButton)

        completeBox.snp.makeConstraints { x in
            x.trailing.equalToSuperview().offset(-20)
            x.bottom.equalToSuperview().offset(-50)
            x.width.equalTo(60)
            x.height.equalTo(60)
        }
        completeBox.addSubview(completeIcon)
        completeIcon.tintColor = .white
        completeIcon.image = UIImage(named: "exit")
        completeIcon.snp.makeConstraints { x in
            x.center.equalToSuperview()
            x.width.equalTo(60)
            x.height.equalTo(60)
        }
        completeButton.snp.makeConstraints { x in
            x.edges.equalTo(completeBox)
        }

        completeBox.alpha = 0
        completeBox.isUserInteractionEnabled = false

        completeButton.addTarget(self, action: #selector(exitButtonClicked), for: .touchUpInside)

        view.addSubview(dropDownAnchor)
        dropDownAnchor.snp.makeConstraints { x in
            x.right.equalTo(completeBox)
            x.width.equalTo(280)
            x.height.equalTo(0)
            x.bottom.equalTo(completeBox)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if dispatchOnce { return }
        dispatchOnce = true
        DispatchQueue.global().async {
            if let app = self.app {
                self.decryptResult = Agent.shared.decryptApplication(with: app) { str in
                    self.appendLog(str: str)
                }
            } else {
                self.appendLog(str: "Malformed application datagram.\n")
                self.appendLog(str: "Missing parameter for bundle url when calling \(#function).\n")
            }
            self.appendLog(str: "\n\n\n\n\n\n")
            DispatchQueue.main.async {
                self.activeCompleteButton()
            }
        }
    }

    func appendLog(str: String) {
        DispatchQueue.main.async { [self] in
            textView.text += str
            let bottom = NSMakeRange(textView.text.count - 1, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }

    func activeCompleteButton() {
        UIView.animate(withDuration: 0.5) { [self] in
            completeBox.alpha = 1
            completeBox.isUserInteractionEnabled = true
        }
    }

    // MARK: - EXIT ACTION

    struct ExitAction {
        let text: String
        let available: () -> (Bool)
        let action: (UIViewController) -> Void
    }

    func buildActionList() -> [ExitAction] {
        [
            .init(text: "AirDrop",
                  available: {
                      self.decryptResult != nil
                  },
                  action: { sourceController in
                      guard let item = self.decryptResult else {
                          return
                      }
                      let activityViewController = UIActivityViewController(
                          activityItems: [item],
                          applicationActivities: nil
                      )
                      if let wppc = activityViewController.popoverPresentationController {
                          wppc.sourceView = sourceController.view
                      }
                      self.present(
                          activityViewController,
                          animated: true,
                          completion: nil
                      )
                  }),
            .init(text: "Open in Filza",
                  available: {
                      self.decryptResult != nil
                  },
                  action: { _ in
                      self.decryptResult?.openInFilza()
                  }),
            .init(text: "Exit",
                  available: {
                      true
                  },
                  action: { controller in
                      controller.dismiss(animated: true, completion: nil)
                  }),
        ]
        .filter { $0.available() }
    }

    @objc
    func exitButtonClicked() {
        let actions = buildActionList()
        let dropDown = DropDown(anchorView: dropDownAnchor)
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
