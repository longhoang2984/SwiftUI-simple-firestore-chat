//
//  ChatView.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/7/21.
//

import SwiftUI
import FloatingLabelTextFieldSwiftUI
import SDWebImageSwiftUI

struct ChatView: View {

    @State var text: String = ""
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode: Binding
    @State var shouldShowImagePicker: Bool = false
    @State var image: UIImage?

    init(currentUser: UserModel? = nil, friend: UserModel? = nil) {
        viewModel = ChatViewModel(currentUser: currentUser, friend: friend)
    }

    var navBar: some View {
        HStack(alignment: .center) {
            Button {
                viewModel.disposeListener()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image("ic_back")
            }

            Spacer()
            Text(
                viewModel.friend?.info.name ?? "Chat User"
            )
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
            Spacer()
        }
        .padding()
    }

    var body: some View {
        VStack(alignment: .leading) {
            navBar
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    ForEach(viewModel.chatMessages) { msg in
                        VStack {
                            if msg.isMyMessage {
                                myMessageView(msg: msg)
                            } else {
                                friendMessageView(msg: msg)
                            }
                        }
                    }
                    HStack{ Spacer() }
                                .id("Empty")
                                .onReceive(viewModel.$count) { _ in
                                            withAnimation(.easeOut(duration: 0.5)) {
                                                scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                                            }
                                        }
                }
            }
            ZStack(alignment: .top) {
                Color("violet").edgesIgnoringSafeArea(.bottom)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                HStack(alignment: .center, spacing: 20) {
                    Button {
                        shouldShowImagePicker.toggle()
                    } label: {
                        Image("ic_camera")
                    }

                    FloatingLabelTextField($text, placeholder: "Message", editingChanged: { (isChanged) in
                    }) {
                    }
                    .lineColor(.white)
                    .titleColor(.clear)
                    .textColor(.white)
                    .selectedLineColor(.white)
                    .selectedTextColor(.white)
                    .selectedTitleColor(.clear)
                    .enablePlaceholderOnFocus(false)
                    .keyboardType(.default)
                    .frame(height: 40)
                    Button {
                        guard !text.isEmpty else { return }
                        viewModel.handleSendMessage(text: text)
                        text = ""
                    } label: {
                        Text(
                            "Send"
                        )
                    }
                    .foregroundColor(text.isEmpty ? Color.gray : Color.white )


                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 10, trailing: 20))
            }
            .background(Color("violet"))
            .fixedSize(horizontal: false, vertical: true)
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            if let img = image {
                viewModel.handleSendPhoto(image: img)
                self.image = nil
            }
        } content: {
            ImagePicker(image: $image)
        }
        .frame(width: UIScreen.main.bounds.width)
        .background(Image("bg_chat")
                        .resizable()
                        .scaledToFill()
                        .clipped())
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.async {
                self.viewModel.count += 1
            }
        }
    }

    func myMessageView(msg: ChatMessage) -> some View {
        return HStack {
            Spacer()
            HStack {
                if msg.type == "text" {
                    Text(
                        msg.text
                    )
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    WebImage(url: URL(string: msg.text))
                    .placeholder(content: {
                        Image("ic_logo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .clipped()
                    })
                    .resizable()
                    .scaledToFill()
                    .padding()
                }
            }
            .background(Color("violet"))
            .cornerRadius(12.0, corners: [.topLeft, .bottomLeft, .bottomRight] )
            .padding(EdgeInsets(top: 5, leading: 50, bottom: 0, trailing: 15))
        }
    }

    func friendMessageView(msg: ChatMessage) -> some View {
        return HStack(alignment: .top)  {
            WebImage(url: URL(string: msg.senderImage))
                .placeholder(content: {
                    Image("ic_logo")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .scaledToFit()
                        .foregroundColor(.white)
                        .clipped()
                })
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipped()
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 1))
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 0))
            HStack {
                if msg.type == "text" {
                    Text(
                        msg.text
                    )
                        .multilineTextAlignment( .leading)
                        .lineLimit(nil)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    WebImage(url: URL(string: msg.text))
                    .placeholder(content: {
                        Image("ic_logo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .clipped()
                    })
                    .resizable()
                    .scaledToFill()
                    .padding()
                }

            }
            .background(Color("secondary"))
            .cornerRadius(12.0, corners: [.bottomLeft, .topRight, .bottomRight])
            .padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 50))
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
//        ChatView()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
