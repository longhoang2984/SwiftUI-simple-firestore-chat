//
//  ProfileViewModel.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/6/21.
//

import Foundation
import UIKit

struct UpdateStatus: Identifiable {
    var id: String { msg }
    let msg: String
}

class ProfileViewModel: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var msg: UpdateStatus?

    init() {
        getCurrentUser()
    }

    private func getCurrentUser() {
        FirebaseManager.shared.fetchCurrentUser { user in
            self.currentUser = user
        }
    }

    func updateProfile(name: String, image: UIImage?) {
        guard let user = currentUser else { return }
        var updateUser = user
        updateUser.info.name = name
        if let img = image {
            FirebaseManager.shared.uploadImage(image: img) { url in
                if !url.isEmpty {
                    updateUser.info.profileImage = url
                    let userData = [
                        "email": updateUser.info.email,
                        "uid": user.uid,
                        "profileImage": url,
                        "name": name
                    ]
                    FirebaseManager.shared.firestore.collection("users")
                        .document(user.uid).setData(userData) { err in
                            if let err = err {
                                self.msg = UpdateStatus(msg: err.localizedDescription)
                                return
                            }
                            self.msg = UpdateStatus(msg: "Updated successfully!!!")
                        }

                } else {
                    self.msg = UpdateStatus(msg: "Something went wrong!!!")
                }
            }
        } else {
            let userData = [
                "email": updateUser.info.email,
                "uid": user.uid,
                "profileImage": updateUser.info.profileImage,
                "name": name
            ]
            FirebaseManager.shared.firestore.collection("users")
                .document(user.uid).setData(userData) { err in
                    if let err = err {
                        self.msg = UpdateStatus(msg: err.localizedDescription)
                        return
                    }
                    self.msg = UpdateStatus(msg: "Updated successfully!!!")
                }
        }
    }
}
