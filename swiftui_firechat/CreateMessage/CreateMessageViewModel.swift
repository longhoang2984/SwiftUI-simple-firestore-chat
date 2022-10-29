//
//  CreateMessageViewModel.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/7/21.
//

import Foundation

class CreateMessageViewModel: ObservableObject {
    @Published var users: [UserModel] = []
    @Published var msg: String = ""

    init() {
    }

    func fetchAllUsers(currentUid: String) {
        FirebaseManager.shared.firestore.collection("users")
            .whereField("uid", isNotEqualTo: currentUid)
            .getDocuments { snapshot, err in
                if let err = err {
                    print(err)
                    self.msg = err.localizedDescription
                    return
                }
                snapshot?.documents.forEach({ doc in
                    let json = doc.data()
                    guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                          let userInfo = try? UserInfoModel(data: data) else {
                              return
                          }
                    let user = UserModel(uid: userInfo.uid, info: userInfo)
                    self.users.append(user)
                })
            }
    }
}
