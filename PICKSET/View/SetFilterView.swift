//
//  SetFilterView.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/18.
//

import Foundation
import UIKit

private let reuseIdentifier = "SetCell"

protocol SetFilterViewDelegate: class {
    func picksetTapped(_ cell: SetCell)
    func handleMessageTapped(_ cell: SetCell)
    func selectSet(_ cell: SetCell)
//    func filterView(_ view: SetFilterView, didSelect index: Int)
}

class SetFilterView: UIView {

    // MARK: - Properties

    var post: OPs? {
        didSet {
            fetchSets()
            fetchSetVotes()
        }
    }
    
    weak var delegate: SetFilterViewDelegate?

    private var sets = [Sets]() {
        didSet { collectionView.reloadData() } //ワンチャンこれが機能しない可能性あり
    }

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)

        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemPurple

        collectionView.register(SetCell.self, forCellWithReuseIdentifier: reuseIdentifier)

//        let selectedIndexPath = IndexPath(row: 0, section: 0)
//        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .left) //この行と1行上をおそらくprofileのやつを真似して書いていたがそれがどうやらいらなかったみたいだ。下に「奇跡起きたああああああ！！！！！！」って書いたところに書いたら本当に奇跡起きた
//        collectionView(collectionView, didSelectItemAt: selectedIndexPath)

        addSubview(collectionView)
        collectionView.addConstraintsToFillView(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    func fetchSets() {
        guard let post = post else { return }
        SetService.shared.fetchSets(post: post) { sets in
            self.sets = sets.sorted(by: { set1, set2 in
                return set1.votes > set2.votes
            })
//            self.tweets = tweets.sorted(by: { tweet1, tweet2 in
//                return tweet1.timestamp > tweet2.timestamp
//            })
//            self.fetchSetVotes()
            self.chechIfUserPickedAndSelected()
        }
//        collectionView.reloadData()
    }
    
    func fetchSetVotes() {
        guard let post = post else { return }
        self.sets.forEach { onSet in
            SetService.shared.fetchSetVotes(post: post, setID: onSet.setID) { setVotes in
//                print("DEBUG: setvotes are \(setVotes)")
                if let index = self.sets.firstIndex(where: { $0.setID == onSet.setID }) {
                    self.sets[index].votes = setVotes
                    let vote = post.vote
                    var percentage = Double(setVotes) * 100
                    if vote != 0 {
                        percentage /= Double(vote)
                        self.sets[index].percentage = percentage
                    } else {
                        self.sets[index].percentage = 0
                    }
                }
            }
        }
    }
    
    func chechIfUserPickedAndSelected() {
        guard let post = post else { return }
        self.sets.forEach { onSet in
            SetService.shared.chechIfUserPicked(post: post, setID: onSet.setID) { didPick in
                guard didPick == true else { return }
                
                if let index = self.sets.firstIndex(where: { $0.setID == onSet.setID }) {
                    self.sets[index].didPick = true
                }
            }
            SetService.shared.chechIfUserSelected(post: post, setID: onSet.setID) { didSelect in
                guard didSelect == true else { return }
                
                if let index = self.sets.firstIndex(where: { $0.setID == onSet.setID }) {
                    self.sets[index].didSelect = true
                }
            }
        }
    }
}

extension SetFilterView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SetCell
        cell.set = sets[indexPath.row]
//        if indexPath.row == 0 {
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left) //奇跡起きたああああああ！！！！！！！！
//        }
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sets.count
    }
}

extension SetFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension SetFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SetCell
        
        delegate?.selectSet(cell)

//        delegate?.filterView(self, didSelect: indexPath.row)
    }
}

// MARK: - SetCellDelegate

extension SetFilterView: SetCellDelegate {
    func handleMessageTapped(_ cell: SetCell) {
        delegate?.handleMessageTapped(cell)
    }
    
    func handleSetTapped(_ cell: SetCell) {
        delegate?.picksetTapped(cell)
    }
}
