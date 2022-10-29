//
//  ChatViewModel.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/8/21.
//

import Foundation
import Firebase
import UIKit
import FirebaseStorage

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let msg = "msg"
    static let type = "type"
    static let senderImage = "senderImage"
    static let users = "users"
    static let messages = "messages"
    static let recentMessages = "recent_messages"
    static let name = "name"
    static let profileImage = "profileImage"
    static let timeStamp = "timestamp"
    static let mediaInfo = "mediaInfo"
    static let width = "width"
    static let height = "height"
}

struct MediaInfo {
    var width: CGFloat = 0
    var height: CGFloat = 0

    init(json: [String: Any]) {
        width = json[FirebaseConstants.width] as? CGFloat ?? 0
        height = json[FirebaseConstants.height] as? CGFloat ?? 0
    }
}

struct ChatMessage: Identifiable {

    var id: String { documentId }

    let documentId: String
    var fromId, toId, text, type, senderImage: String
    var mediaInfo: MediaInfo = MediaInfo(json: [:])

    var isMyMessage: Bool {
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return false }
        return uid == fromId
    }

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.msg] as? String ?? ""
        self.type = data[FirebaseConstants.type] as? String ?? ""
        self.senderImage = data[FirebaseConstants.senderImage] as? String ?? ""
        if let mediaInfo = data[FirebaseConstants.mediaInfo] as? [String: Any] {
            self.mediaInfo = MediaInfo(json: mediaInfo)
        }
    }
}

struct RecentMessage: Identifiable {
    var id: String { documentId }

    let documentId: String
    var fromId, toId, msg, profileImage, name: String

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.msg = data[FirebaseConstants.msg] as? String ?? ""
        self.name = data[FirebaseConstants.name] as? String ?? ""
        self.profileImage = data[FirebaseConstants.profileImage] as? String ?? ""
    }
}

class ChatViewModel: ObservableObject {

    var currentUser: UserModel?
    var friend: UserModel?
    @Published var errMsg: String = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var count: Int = 0
    @Published var image: UIImage?

    init(currentUser: UserModel?, friend: UserModel?) {
        self.currentUser = currentUser
        self.friend = friend
        fetchMessages()
    }

    func handleSendMessage(text: String, type: String = "text", mediaInfo: MediaInfo? = nil) {
        guard let current = currentUser,
        let friend = self.friend else { return }
        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(current.uid)
            .collection(friend.uid)
            .document()

        var messageData: [String: Any] = [
            FirebaseConstants.fromId: current.uid,
            FirebaseConstants.toId: friend.uid,
            FirebaseConstants.msg: text,
            FirebaseConstants.type: type,
            FirebaseConstants.senderImage: current.info.profileImage,
            FirebaseConstants.timeStamp: Timestamp()
        ]
        if let mediaInfo = mediaInfo {
            messageData[FirebaseConstants.mediaInfo] = [
                FirebaseConstants.width: mediaInfo.width,
                FirebaseConstants.height: mediaInfo.height
            ]
        }

        document.setData(messageData) { err in
            if let err = err {
                print(err)
                self.errMsg = err.localizedDescription
                return
            }
            self.count += 1
            self.persistRecentMessage(isImage: type == "photo", text: text)
        }

        let receiverDocument = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(friend.uid)
            .collection(current.uid)
            .document()

        receiverDocument.setData(messageData) { err in
            if let err = err {
                print(err)
                self.errMsg = err.localizedDescription
                return
            }
        }
    }

    func handleSendPhoto(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let mediaInfo = MediaInfo(json: [
            FirebaseConstants.width: image.size.width,
            FirebaseConstants.height: image.size.height
        ])
        let ref = FirebaseManager.shared.storage.reference(withPath: FirebaseConstants.messages)
        
        ref.putData(imageData, metadata: StorageMetadata(dictionary: [
            "contentType": "image/jpeg"
        ])) { data, err in
            if let err = err {
                print(err)
                self.errMsg = err.localizedDescription
                return
            }

            ref.downloadURL { url, err in
                if let err = err {
                    print(err)
                    self.errMsg = err.localizedDescription
                    return
                }
                self.handleSendMessage(text: url?.absoluteString ?? "", type: "photo", mediaInfo: mediaInfo)
            }
        }
    }

    var listener: ListenerRegistration?

    func fetchMessages() {
        guard let current = currentUser,
        let friend = self.friend else { return }
            listener = FirebaseManager.shared.firestore
                .collection("messages")
                .document(current.uid)
                .collection(friend.uid)
                .order(by: "timestamp")
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        self.errMsg = "Failed to listen for messages: \(error)"
                        print(error)
                        return
                    }

                    querySnapshot?.documentChanges.forEach({ change in
                        if change.type == .added {
                            let data = change.document.data()
                            self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                        }
                    })

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.count += 1
                    }
                }
        }

    func disposeListener() {
        listener?.remove()
    }

    func persistRecentMessage(isImage: Bool = false, text: String) {
        guard let current = currentUser,
        let friend = self.friend else { return }
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(current.uid)
            .collection(FirebaseConstants.messages)
            .document(friend.uid)

        var data: [String: Any] = [
            FirebaseConstants.timeStamp: Timestamp(),
            FirebaseConstants.msg: isImage ? "You sent a photo" : text,
            FirebaseConstants.fromId: current.uid,
            FirebaseConstants.toId: friend.uid,
            FirebaseConstants.profileImage: friend.info.profileImage,
            FirebaseConstants.name: friend.info.name,
        ]
        document.setData(data) { err in
            if let err = err {
                print(err)
                return
            }
        }

        let friendDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(friend.uid)
            .collection(FirebaseConstants.messages)
            .document(current.uid)

        data[FirebaseConstants.msg] = isImage ? "\(current.info.name) sent you a photo" : text
        data[FirebaseConstants.profileImage] = current.info.profileImage
        data[FirebaseConstants.name] = current.info.name
        friendDocument.setData(data) { err in
            if let err = err {
                print(err)
                return
            }
        }
    }
}
