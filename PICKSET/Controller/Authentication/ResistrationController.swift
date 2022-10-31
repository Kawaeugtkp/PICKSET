//
//  ResistrationController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import Firebase

class ResistrationController: UIViewController {
    
    //MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    private let PlusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white //tintcolorは例えばこのplus_photoなら元の画像は線とかが水色だけどこのコードの設定で白にできる
        button.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "ic_mail_outline_white_2x-1")!, textField: emailTextField)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "ic_lock_outline_white_2x")!, textField: passwordTextField)
        return view
    }()
    
    private lazy var fullnameContainerView: UIView = {
        let view = Utilities().inputContainerView(textField: fullnameTextField)
        return view
    }()
    
    private lazy var usernameContainerView: UIView = {
        let view = Utilities().inputContainerView(textField: usernameTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceHolder: "Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceHolder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let fullnameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceHolder: "Fullname")
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceHolder: "Username")
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Already have an account", " Log In")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    private let registrationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .picksetRed
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Selectors
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleAddProfilePhoto() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //編集を可能にする
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleRegistration() {
        guard let profileImage = profileImage else {
            print("DEBUG: Please select a profile image..")
            return
        }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        if email != "" && password != "" && fullname != "" && username != "" {
            AuthService.shared.registerUser(credentials: credentials) { (error, ref) in
                guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return } //ここは意味わからなくていい。多分
                guard let tab = window.rootViewController as? MainTabController else { return }
                tab.authenticateUserAndConfigureUI()

                self.dismiss(animated: true, completion: nil)
            }
        } else if email == "" {
            alert(title: "エラー", message: "メールアドレスを入力してください", actiontitle: "OK")
        } else if password == "" {
            alert(title: "エラー", message: "パスワードを入力してください", actiontitle: "OK")
        } else if fullname == "" {
            alert(title: "エラー", message: "名前を入力してください", actiontitle: "OK")
        } else {
            alert(title: "エラー", message: "ユーザーネームを入力してください", actiontitle: "OK")
        }
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .lightGray
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        view.addSubview(PlusPhotoButton)
        PlusPhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        PlusPhotoButton.setDimensions(width: 128, height: 128)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, fullnameContainerView, usernameContainerView, registrationButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: PlusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 40, paddingRight: 40)
    }
    
    func alert(title:String,message:String,actiontitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ResistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileimage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileimage
        
        PlusPhotoButton.layer.cornerRadius = 128/2
        PlusPhotoButton.layer.masksToBounds = true //これで多分、その角を丸くしたlayerに選択した画像を当てはめるのかどうかを決めさせている。だからtrueにすることで丸くなる
        PlusPhotoButton.imageView?.contentMode = .scaleAspectFill
        PlusPhotoButton.imageView?.clipsToBounds = true
        PlusPhotoButton.layer.borderColor = UIColor.white.cgColor
        PlusPhotoButton.layer.borderWidth = 3
        
        self.PlusPhotoButton.setImage(profileimage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil) //これでplusphotobutton押した後に"choose"と"cancel"を押す場面がいずれ出てくるけれども、それを押すことができるようになる
    } //allow us to access the selected media item whether it's a picture or a video
}
