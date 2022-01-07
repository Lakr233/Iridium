//
//  AppCell.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import AppListProto
import SnapKit
import UIKit

private let padding = 8

class AppCell: UITableViewCell {
    let icon = UIImageView()
    let title = UILabel()
    let subtitle = UILabel()
    let version = UILabel()
    let path = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bootstrap()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func bootstrap() {
        contentView.addSubview(icon)
        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(version)
        contentView.addSubview(path)
        icon.snp.makeConstraints { x in
            x.centerY.equalToSuperview()
            x.left.equalToSuperview().offset(padding)
            x.width.equalTo(38)
            x.height.equalTo(38)
        }
        title.snp.makeConstraints { x in
            x.left.equalTo(icon.snp.right).offset(padding)
            x.right.equalToSuperview().offset(-padding)
            x.top.equalToSuperview().offset(padding)
        }
        subtitle.snp.makeConstraints { x in
            x.left.equalTo(icon.snp.right).offset(padding)
            x.right.equalToSuperview().offset(-padding)
            x.top.equalTo(title.snp.bottom).offset(2)
        }
        version.snp.makeConstraints { x in
            x.left.equalTo(icon.snp.right).offset(padding)
            x.right.equalToSuperview().offset(-padding)
            x.top.equalTo(subtitle.snp.bottom).offset(2)
        }
        path.snp.makeConstraints { x in
            x.left.equalTo(icon.snp.right).offset(padding)
            x.right.equalToSuperview().offset(-padding)
            x.top.equalTo(version.snp.bottom).offset(2)
        }
        icon.layer.cornerRadius = 8
        icon.contentMode = .scaleAspectFit
        icon.clipsToBounds = true
        title.font = .systemFont(ofSize: 18, weight: .semibold)
        subtitle.font = .systemFont(ofSize: 14, weight: .semibold)
        version.font = .monospacedSystemFont(ofSize: 10, weight: .semibold)
        version.textColor = .gray
        path.font = .monospacedSystemFont(ofSize: 10, weight: .semibold)
        path.textColor = .gray
    }

    func clearStatus() {
        icon.image = nil
        title.text = nil
        subtitle.text = nil
        version.text = nil
        path.text = nil
    }

    func setApp(_ app: AppListElement) {
        if let data = Data(base64Encoded: app.primaryIconDataBase64),
           let image = UIImage(data: data)
        {
            icon.image = image
        } else {
            icon.image = UIImage(named: "appstore")
        }
        title.text = app.localizedName
        subtitle.text = app.bundleIdentifier
        version.text = "\(app.shortVersion) (\(app.version))"
        path.text = app.bundleURL.lastPathComponent
    }
}
