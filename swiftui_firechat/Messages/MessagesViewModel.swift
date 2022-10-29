//
//  MessagesViewModel.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/2/21.
//

import Foundation

struct ChatUser {
    let uid, profileImage, email, name: String
}

class MessagesViewModel: ObservableObject {

    @Published var errMessage = ""
    @Published var currentUser: ChatUser?
    @Published var user: UserModel?
    @Published var isUserCurrentlyLoggedOut = false
    @Published var messages: [RecentMessage] = []

    init() {

        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }

        fetchCurrentUser()
        fetchRecentMessages()
    }

    func fetchCurrentUser() {
        FirebaseManager.shared.fetchCurrentUser { user in
            guard let user = user else { return }
            let chatUser = ChatUser(uid: user.uid, profileImage: user.info.profileImage, email: user.info.email, name: user.info.name)
            self.user = user
            self.currentUser = chatUser
        }
    }

    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .addSnapshotListener { snapShot, err in
                if let err = err {
                    self.errMessage = err.localizedDescription;
                    return
                }

                snapShot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID

                    if let index = self.messages.firstIndex(where: { $0.documentId == docId }) {
                        self.messages.remove(at: index)
                    }

                    self.messages.insert(RecentMessage(documentId: docId, data: change.document.data()), at: 0)
                })
            }
    }

    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
