//
//  SetCell.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/18.
//

import Foundation
import UIKit

protocol SetCellDelegate: class {
    func handleSetTapped(_ cell: SetCell)
    func handleMessageTapped(_ cell: SetCell)
}

class SetCell: UICollectionViewCell {
    
    // MARK: - Properties
    
//    private let st: String
    
    var set: Sets? {
        didSet { configure() }
    }
    
    weak var delegate: SetCellDelegate?
    
    private let setLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Drag or select an app icon image "
        label.numberOfLines = 0
        return label
    }()
    
    lazy var pickButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSetTapped), for: .touchUpInside)
        return button
    }()
    
    private let pickLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.text = "1000"
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "（33.3％）"
        return label
    }()
    
    lazy var opinionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.addTarget(self, action: #selector(handleMessageTapped), for: .touchUpInside)
        return button
    }()
    
//    override var isSelected: Bool {
//        didSet {
//            backgroundColor = isSelected ? .picksetRed : .picksetRed.withAlphaComponent(0.2)
//        }
//    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 5
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.picksetRed.cgColor
        
        backgroundColor = .white

        addSubview(pickButton)
        pickButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 5, paddingRight: 3)
        
        addSubview(setLabel)
        setLabel.anchor(top: topAnchor, left: leftAnchor, right: pickButton.leftAnchor, paddingTop: 7, paddingLeft: 10, paddingRight: 7) //anchorで他のviewを入れる場合はそれが既に存在していないといけない。すなわち含めているviewの後にanchor指定を行う
        
//        let descriptionStack = UIStackView(arrangedSubviews: [setLabel, pickButton])
//        descriptionStack.spacing = 7
//        descriptionStack.alignment = .center
//        descriptionStack.distribution = .fillEqually
        
//        addSubview(descriptionStack)
//        descriptionStack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5)
        
        addSubview(opinionButton)
        opinionButton.anchor(bottom: bottomAnchor, paddingBottom: 5)
        opinionButton.centerX(inView: self)
        
        let stack = UIStackView(arrangedSubviews: [pickLabel, percentageLabel])
        stack.axis = .horizontal
        stack.spacing = 7
        
        addSubview(stack)
        stack.anchor(bottom: opinionButton.topAnchor, paddingBottom: 5)
        stack.centerX(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleSetTapped() {
        delegate?.handleSetTapped(self) //クソみたいな承継を続けたらいけたわwww
    }
    
    @objc func handleMessageTapped() {
        delegate?.handleMessageTapped(self)
        print("DEBUG: message tapped")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let set = set else { return }
        setLabel.text = set.setText
        pickLabel.text = String(set.votes)
        let viewModel = SetViewModel(set: set)
        pickButton.tintColor = viewModel.setButtonTintColor
        backgroundColor = viewModel.cellTintColor
        percentageLabel.attributedText = viewModel.percentageString
//        percentageLabel.text = "\(String(format: "%.1f", set.percentage)) %"
    }
}
