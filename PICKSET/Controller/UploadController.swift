//
//  UploadController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/09.
//

import Foundation
import UIKit

class UploadController: UIViewController {
    
    // MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
        
    private let titleTextView = TextViewSeries2()
    
    private let descriptionTextView = TextViewSeries()
    
    private let guideLine1 = UIView()
    private let guideLine2 = UIView()
    
    private var selectedCategory: String?
    
    private let categoriesTextField = categoryTextField()
    
    private let categoryPicker = UIPickerView()
    
    private let categoryItems = ["ニュース", "スポーツ", "エンタメ", "コロナ", "経済", "ネット・IT", "ファッション", "暮らし", "グルメ", "おでかけ", "カルチャー", "アニメ・ゲーム", "おもしろ", "恋愛"]
    
    private let topicLabel: UILabel = {
        let label = UILabel()
        label.text = "トピック"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .picksetRed
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "カテゴリ"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .picksetRed
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "トピックの説明"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .picksetRed
        return label
    }()
    
    private lazy var actionButton: UIButton = { //ここがprivate let actionButton: UIButtonの時はうまくいかなかった
        let button = UIButton(type: .system)
        button.backgroundColor = .picksetRed
        button.setTitle("Post", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32) //ここで、x,yが0でいいのは、多分だけどrightbarbuttonitemの動ける範囲が決まっていて、その中であれば左上の角がx,yが0でもいい感じに設定できているということだと思う
        button.layer.cornerRadius = 32 / 2
        
        button.addTarget(self, action: #selector(handleUploadPost), for: .touchUpInside)
        return button
    }()
    
    private let wordCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "0/50"
        return label
    }()
    
//    private let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 35))
    
//    private let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))

    private lazy var addImageButton: UIButton = {
        let button = UIButton(type: .system)
//        button.setTitle("+ 画像を追加", for: .normal)
//        button.layer.borderColor = UIColor.twitterBlue.cgColor
//        button.layer.borderWidth = 1.25
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(handleAddImage), for: .touchUpInside)
        return button
    }()
    
    private var cursorPosition = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextView.delegate = self
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        self.categoriesTextField.inputView = categoryPicker
//        self.categoriesTextField.inputAccessoryView = toolbar
//        toolbar.setItems([doneItem], animated: true)
        categoriesTextField.text = "カテゴリを選択してください"
        categoriesTextField.textColor = .darkGray
        view.backgroundColor = .white
        configureUI()
        configureNavigationBar()
    }
    
    // MARK: - Selectors
    
    @objc func handleUploadPost() {
        guard let topic = titleTextView.text else { return }
        guard let description = descriptionTextView.text else { return }
        guard let category = categoriesTextField.text else { return }
        if topic == "" || topic.isOnly(structuredBy: " 　") {
            alert(title: "トピックが入力されていません", message: "", actiontitle: "OK")
            return
        } else if titleTextView.text.contains("\n") {
            alert(title: "トピック内で改行が行われています", message: "トピック内では改行できません", actiontitle: "OK")
            return
        } else if category == "カテゴリを選択してください" {
            alert(title: "カテゴリが選択されていません", message: "", actiontitle: "OK")
            return
        } else {
            OPsService.shared.uploadPost(topic: topic, description: description, category: category) { (err, ref) in
                if let error = err {
                    print("DEBUG: Failed to upload tweet with error \(error.localizedDescription)")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAddImage() {
//        //PhotoLibraryから画像を選択
//        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//        //デリゲートを設定する
//        imagePicker.delegate = self
//        //現れるピッカーNavigationBarの文字色を設定する
//        imagePicker.navigationBar.tintColor = UIColor.white
//        //現れるピッカーNavigationBarの背景色を設定する
//        imagePicker.navigationBar.barTintColor = UIColor.gray
//        //ピッカーを表示する
//        present(imagePicker, animated: true, completion: nil)
//        if let selectedRange = descriptionTextView.selectedTextRange {
//
//            cursorPosition = descriptionTextView.offset(from: descriptionTextView.beginningOfDocument, to: selectedRange.start)
//
//            print("DEBUG: \(cursorPosition)")
//        }
    }
    
//    @objc func handleDone() {
//        categoriesTextField.endEditing(true)
//    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.addSubview(topicLabel)
        topicLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 5, paddingLeft: 15)
        
        titleTextView.layer.borderColor = UIColor.darkGray.cgColor
        titleTextView.layer.borderWidth = 1.0
        titleTextView.layer.cornerRadius = 10
        titleTextView.layer.masksToBounds = true
        
        titleTextView.placeholderLabel.text = "トピックを入力しましょう"
        view.addSubview(titleTextView)
        titleTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        titleTextView.anchor(top: topicLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 10, paddingRight: 10)
        
        view.addSubview(wordCountLabel)
        wordCountLabel.anchor(top: titleTextView.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 15)
        
        view.addSubview(categoryLabel)
        categoryLabel.anchor(top: wordCountLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15)
        
        categoriesTextField.layer.borderColor = UIColor.darkGray.cgColor
        categoriesTextField.layer.borderWidth = 1.0
        categoriesTextField.layer.cornerRadius = 5
        categoriesTextField.layer.masksToBounds = true
        
        view.addSubview(categoriesTextField)
        categoriesTextField.anchor(top: categoryLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 10, width: 250)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: categoriesTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15)
        
//        view.addSubview(addImageButton)
//        addImageButton.centerY(inView: descriptionLabel)
//        addImageButton.setDimensions(width: 30, height: 30)
//        addImageButton.layer.cornerRadius = 2
//        addImageButton.anchor(right: view.rightAnchor, paddingRight: 15)
        
        view.addSubview(addImageButton)
        addImageButton.setDimensions(width: 30, height: 30)
        addImageButton.layer.cornerRadius = 2
        addImageButton.anchor(top: descriptionLabel.bottomAnchor, right: view.rightAnchor, paddingTop: 8, paddingRight: 15)
        
        descriptionTextView.layer.borderColor = UIColor.darkGray.cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.masksToBounds = true
        
        descriptionTextView.placeholderLabel.text = "トピックの説明を入力しましょう"
        view.addSubview(descriptionTextView)
        descriptionTextView.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: addImageButton.leftAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 100, paddingRight: 10)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
    func alert(title:String,message:String,actiontitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDataSource

extension UploadController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryItems.count
    }
}

// MARK: - UIPickerViewDelagate

extension UploadController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryItems[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoriesTextField.text = categoryItems[row]
        categoriesTextField.textColor = .black
    }
}

// MARK: - UITextViewDelegate

extension UploadController: UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
////        return titleTextView.text.count <= maxWordcount &&
//            if text == "\n" && titleTextView.text.count > maxWordcount {
//                textView.resignFirstResponder() //キーボードを閉じる
//                return false
//            }
//            return true
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        self.wordCountLabel.text = "\(maxWordcount - textView.text.count)"
//    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text != "\n") && (textView.text.count + (text.count - range.length) <= 50) {
            return true
        } else if text == "\n" {
            titleTextView.resignFirstResponder() //キーボードを閉じる
            return false
        }
        return false
    } //文字数制限を同時にかける方法がわからないが、少なくとも改行ができない設定がこの段階ではできている
    
    func textViewDidChange(_ textView: UITextView) {
        wordCountLabel.text = "\(textView.text.count)/50"
    }
}

//extension UploadController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    //MARK:-メモに画像を貼り付ける処理
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[.originalImage] as? UIImage {
//
//            let fullString = NSMutableAttributedString(string: descriptionTextView.text)
//
//            let imageWidth = image.size.width
//            // 画像の幅を調整したい場合paddingなどをframeから引く
//            let padding: CGFloat = 100
//            let scaleFactor = imageWidth / (descriptionTextView.frame.size.width - padding)
//            let imageAttachment = NSTextAttachment()
//            imageAttachment.image = UIImage(cgImage: image.cgImage!, scale: scaleFactor, orientation: .up)
//            let imageString = NSAttributedString(attachment: imageAttachment)
//            fullString.insert(imageString, at: cursorPosition)
//            // TextViewに画像を含んだテキストをセット
//            descriptionTextView.attributedText = fullString
//        }
//        dismiss(animated: true, completion: nil)
//    }
//}
