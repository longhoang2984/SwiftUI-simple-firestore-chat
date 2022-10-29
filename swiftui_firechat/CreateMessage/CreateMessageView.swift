//
//  CreateMessageView.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/7/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreateMessageView: View {

    @Environment(\.presentationMode) var presentationMode: Binding
    @ObservedObject var viewModel = CreateMessageViewModel()
    var didSelectUser: ((_ user: UserModel) -> Void)? = nil

    init(uid: String, didSelectUser: ((_ user: UserModel) -> Void)? = nil) {
        viewModel.fetchAllUsers(currentUid: uid)
        self.didSelectUser = didSelectUser
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading ,spacing: 20) {
                HStack {
                    Text("New Message")
                        .foregroundColor(.white)
                        .font(.title)
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.white)
                    }

                }
                .padding()
                ScrollView {
                    ForEach(viewModel.users) { user in
                        Button {
                            didSelectUser?(user)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 10, content: {
                                HStack(spacing: 20) {
                                    WebImage(url: URL(string: user.info.profileImage))
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
                                    Text(user.info.name)
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .bold))
                                }
                                .padding(.horizontal)
                                Divider()
                            })
                            .frame(maxWidth: .infinity)
                        }

                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color("purple"))
            .navigationTitle("New message")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
        }
    }
}

struct CreateMessageView_Previews: PreviewProvider {
    static var previews: some View {
//        CreateMessageView()
        MessagesView()
    }
}
