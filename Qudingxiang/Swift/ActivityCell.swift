//
//  ActivityCell.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXActTableViewCell：活动卡片，活动列表页 / 价格页共用
//  视觉：封面大图 + 状态徽标 + 标题 + 地址 + 价格
//

import UIKit
import SnapKit
import SDWebImage

final class ActivityCell: UITableViewCell {
    static let reuseID = "ActivityCell"

    private let cardView    = UIView()
    private let coverView   = UIImageView()
    private let statusBadge = UILabel()
    private let titleLabel  = UILabel()
    private let addressLabel = UILabel()
    private let timeLabel   = UILabel()
    private let priceLabel  = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        coverView.contentMode = .scaleAspectFill
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 12
        coverView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.addSubview(coverView)
        coverView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(180)
        }

        statusBadge.font = QDXFont.medium(20)
        statusBadge.textColor = .white
        statusBadge.backgroundColor = QDXColor.accent
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 4
        statusBadge.layer.masksToBounds = true
        coverView.addSubview(statusBadge)
        statusBadge.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(12)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(44)
        }

        titleLabel.font = QDXFont.semibold(32)
        titleLabel.textColor = QDXColor.black
        titleLabel.numberOfLines = 1
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(coverView.snp.bottom).offset(10)
        }

        addressLabel.font = QDXFont.regular(24)
        addressLabel.textColor = QDXColor.gray
        addressLabel.numberOfLines = 1
        cardView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }

        timeLabel.font = QDXFont.regular(22)
        timeLabel.textColor = QDXColor.lightGray
        cardView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(addressLabel.snp.bottom).offset(4)
        }

        priceLabel.font = QDXFont.bold(34)
        priceLabel.textColor = QDXColor.accent
        cardView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with g: Goods) {
        titleLabel.text  = g.cn
        addressLabel.text = g.address
        timeLabel.text   = g.time
        statusBadge.text = g.statusCn ?? "进行中"
        if let price = g.price { priceLabel.text = "¥ \(price)" }
        if let urlString = g.url, let url = URL(string: APIHost.oldBase + urlString) {
            coverView.sd_setImage(with: url, placeholderImage: UIImage(named: "banner_cell"))
        } else {
            coverView.image = UIImage(named: "banner_cell")
        }
    }
}
