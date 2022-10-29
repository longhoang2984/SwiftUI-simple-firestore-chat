//
//  FirebaseManager.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/1/21.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

class FirebaseManager: NSObject {

    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    static let shared = FirebaseManager()
    var currentUser: UserModel?

    override init() {
        FirebaseApp.configure()
        auth = Auth.auth()
        firestore = Firestore.firestore()
        storage = Storage.storage()
        super.init()
    }

    func uploadImage(image: UIImage, completion: @escaping ((_ url: String) -> Void))  {
        let _: String = UUID().uuidString
        guard let uid = auth.currentUser?.uid,
        let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = storage.reference(withPath: uid)
        ref.putData(imageData, metadata: StorageMetadata(dictionary: [
            "contentType": "image/jpeg"
        ])) { data, err in
            if let err = err {
                print(err)
                completion(err.localizedDescription)
                return
            }

            ref.downloadURL { url, err in
                if let err = err {
                    print(err)
                    completion("")
                    return
                }
                completion(url?.absoluteString ?? "")
            }
        }
    }

    func fetchCurrentUser(_ completion: @escaping ((_ user: UserModel?) -> Void)) {
        guard let uid = auth.currentUser?.uid else { return }

        firestore.collection("users")
            .document(uid).getDocument { snapshot, err in
                if let err = err {
                    print(err)
                    completion(nil)
                    return
                }
                guard let json = snapshot?.data() else { return }

                do {
                    let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let user = try UserInfoModel(data: data)
                    self.currentUser = UserModel(uid: uid, info: user)
                    completion(self.currentUser)
                } catch {
                    completion(nil)
                }
            }
    }

}
