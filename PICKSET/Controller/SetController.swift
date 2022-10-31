//
//  SetController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/19.
//

import Foundation
import UIKit

class SetController: UIViewController {
    // MARK: - Properties
    
    var post: OPs? {
        didSet {
            configure()
        }
    }
    
    private let setLabel: UILabel = {
        let label = UILabel()
        label.text = "セットを入力しましょう"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    private let setTextView = SetTextView()
    
    private lazy var uploadSetButton: UIButton = {
        let button = UIButton()
        button.setTitle("セットを追加", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleUploadSet), for: .touchUpInside)
        button.backgroundColor = .picksetRed
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let recommendLabel: UILabel = {
        let label = UILabel()
        label.text = "セットは短く簡潔に設定するのがおすすめです"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .picksetRed
        return label
    }()
    
    private let wordCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "0/50"
        return label
    }()
    
    // MARK: - Lifecycle
    
    init(post: OPs) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setTextView.delegate = self
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - API
    
    // MARK: - Selectors
    
    @objc func handleUploadSet() {
//        guard let setText = setTextView.text else { return }
//        guard let post = post else { return }
//        SetService.shared.uploadSet(setText: setText, post: post) { (err, ref) in
//            if let error = err {
//                print("DEBUG: Failed to upload tweet with error \(error.localizedDescription)")
//                return
//            }
//            self.dismiss(animated: true, completion: nil)
//        }
        guard let setText = setTextView.text else { return }
        if setText == "" || setText.isOnly(structuredBy: " 　") {
            alert(title: "セットが入力されていません", message: "", actiontitle: "OK")
            return
        } else if setTextView.text.contains("\n") {
            alert(title: "セット内で改行が行われています", message: "セット内では改行できません", actiontitle: "OK")
            return
        } else {
            let alert = UIAlertController(title: "セットを追加しますか？", message: "追加されたセットは削除できません", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                guard let post = self.post else { return }
                SetService.shared.uploadSet(setText: setText, post: post) { (err, ref) in
                    if let error = err {
                        print("DEBUG: Failed to upload tweet with error \(error.localizedDescription)")
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    func configure() {
        
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(setLabel)
        setLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 100)
        setLabel.centerX(inView: view)
        
        setTextView.placeholderLabel.text = "追加するセットを入力してください"
        setTextView.layer.borderColor = UIColor.darkGray.cgColor
        setTextView.layer.borderWidth = 1.0
        setTextView.layer.cornerRadius = 10
        setTextView.layer.masksToBounds = true //これはいらなそうだが、他のはないといけなさそう（borderColor、borderWidth、cornerRadius）
        
        view.addSubview(setTextView)
        setTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        setTextView.anchor(top: setLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 10, paddingRight: 10)
        
        view.addSubview(wordCountLabel)
        wordCountLabel.anchor(top: setTextView.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 15)
        
        view.addSubview(recommendLabel)
        recommendLabel.anchor(top: wordCountLabel.bottomAnchor, paddingTop: 15)
        recommendLabel.centerX(inView: view)
        
        view.addSubview(uploadSetButton)
        uploadSetButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 200, width: 200, height: 50)
        uploadSetButton.centerX(inView: view)
    }
    
    func alert(title:String,message:String,actiontitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SetController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text != "\n") && (textView.text.count + (text.count - range.length) <= 50) {
            return true
        } else if text == "\n" {
            setTextView.resignFirstResponder() //キーボードを閉じる
            return false
        }
        return false
    } //文字数制限を同時にかける方法がわからないが、少なくとも改行ができない設定がこの段階ではできている
    
    func textViewDidChange(_ textView: UITextView) {
        wordCountLabel.text = "\(textView.text.count)/50"
    }
}
