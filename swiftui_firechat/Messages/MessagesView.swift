//
//  Messages.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/1/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessagesView: View {

    @ObservedObject var viewModel: MessagesViewModel = MessagesViewModel()
    @State private var isShowProfileView: Bool = false
    @State private var shouldShowNewMessageScreen: Bool = false
    @State private var shouldShowChatScreen: Bool = false
    @State private var chatUser: UserModel?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                customNavBar
                messagesListView
                newMessageView
            }
            .background(Color("purple"))
            .navigationBarHidden(true)
        }
        .navigationTitle("")
        .fullScreenCover(isPresented: $viewModel.isUserCurrentlyLoggedOut, onDismiss: nil) {
            AuthenticateView(didCompleteLoginProcess: {
                self.viewModel.isUserCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
            })
        }
    }

    private var newMessageView: some View {
        NavigationLink(isActive: $shouldShowChatScreen) {
            ChatView(currentUser: viewModel.user, friend: chatUser)
        } label: {

        }
    }
    
    private var customNavBar: some View {
        NavigationLink(isActive: $isShowProfileView) {
            if let user = viewModel.user {
                ProfileView(user: user, userUpdateCallback: {
                    self.viewModel.fetchCurrentUser()
                }, userLogOutCallback:  {
                    self.viewModel.handleSignOut()
                })
            }
        } label: {
            Button(action: {
                isShowProfileView.toggle();
            }) {
                HStack(spacing: 20) {
                    WebImage(url: URL(string: viewModel.currentUser?.profileImage ?? ""))
                        .placeholder(content: {
                            Image("ic_logo")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .scaledToFit()
                                .foregroundColor(.white)
                                .clipped()
                        })
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(40)
                        .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.white, lineWidth: 1))
                    VStack(alignment: .leading, spacing: 0) {
                        Text (viewModel.currentUser?.name ?? "")
                            .foregroundColor(.white)
                            .font(.title)
                        HStack {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 14, height: 14)
                            Text(
                                "Online"
                            )
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                    Spacer()
                    Button(action: {
                        shouldShowNewMessageScreen.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                .padding()
                .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
                    // dismiss
                } content: {
                    CreateMessageView(uid: viewModel.currentUser?.uid ?? "") { user in
                        self.chatUser = user
                        self.shouldShowChatScreen.toggle()
                    }
                }

            }
        }
    }

    private var messagesListView: some View {
        ScrollView {
            ForEach(viewModel.messages) { message in
                Button(action: {
                    guard let current = viewModel.currentUser else { return }
                    let chatUserId = current.uid == message.fromId ? message.toId : message.fromId

                    let chatUser = UserModel(uid: chatUserId, info: UserInfoModel(
                        profileImage: message.profileImage,
                        name: message.name,
                        email: message.name,
                        uid: chatUserId
                    ))
                    self.chatUser = chatUser
                    self.shouldShowChatScreen.toggle()
                }) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 14) {
                            WebImage(url: URL(string: message.profileImage))
                                .placeholder(content: {
                                    Image("ic_logo")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .clipped()
                                })
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(40)
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.white, lineWidth: 1))
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(
                                        message.name
                                    )
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    Spacer()
                                    Text("1m ago")
                                        .foregroundColor(.white)
                                        .font(.caption2)
                                }
                                Text(message.msg)
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                        Divider()
                    }
                    .padding()
                }
            }
        }
        .background(Color("bg_messages"))
    }
}

struct Messages_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
