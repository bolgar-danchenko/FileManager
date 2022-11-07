//
//  SettingsTableViewCell.swift
//  SettingsExample
//
//  Created by Konstantin Bolgar-Danchenko on 28.10.2022.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    static let identifier = "SettingsTableViewCell"

    private let iconContaier: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContaier)
        iconContaier.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size: CGFloat = contentView.frame.size.height - 12

        iconContaier.frame = CGRect(x: 15, y: 6, width: size, height: size)

        let imageSize: CGFloat = size/1.5
        iconImageView.frame = CGRect(
            x: (size-imageSize)/2,
            y: (size-imageSize)/2,
            width: imageSize,
            height: imageSize
        )

        label.frame = CGRect(
            x: 25+iconContaier.frame.size.width,
            y: 0,
            width: contentView.frame.size.width-20-iconContaier.frame.size.width-10,
            height: contentView.frame.size.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContaier.backgroundColor = nil
    }

    public func configureSettingsCell(with model: SettingsOptions) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContaier.backgroundColor = model.iconBackgroundColor
    }
}
