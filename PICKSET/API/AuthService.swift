//
//  AuthService.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    } //この関数は結構怪しい。少なくとも動画とは違う。動画ではcompletionの引数は"AuthDataCallback?"だけどなぜかそれが存在しない
    
    func registerUser(credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void) {
        
        let email = credentials.email
        let password = credentials.password
        let fullname = credentials.fullname
        let username = credentials.username
        
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                        if let error = error {
                            print("DEBUG: Error is \(error.localizedDescription)")
                        } //errorはいわゆるエラーが発生したときにだけ発現するものだから、このif文が成立する
                        
                        guard let uid = result?.user.uid else { return }
                        
                        let values = ["email": email, "fullname": fullname, "username": username, "profileImageUrl": profileImageUrl]
                        
                        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion) //completionというのは処理が達成（conmplete）されたときに何かするかという話であって、多くの場合nilなのはそれがいらないから。ただ。registraionの場合だとそれを実行したいからclosureを作って色々処理を実行している
                        let userinfo = [username: uid]
                        REF_USER_USERNAMES.updateChildValues(userinfo)
                    })
                }
            }
        }
    }
}
