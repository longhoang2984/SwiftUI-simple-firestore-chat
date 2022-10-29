//
//  ProfileView.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/2/21.
//

import SwiftUI
import FloatingLabelTextFieldSwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {

    @State var name: String = ""
    @State var imageStr: String = ""
    @State var shouldShowImagePicker: Bool = false
    @State var image: UIImage?
    @ObservedObject var viewModel: ProfileViewModel = ProfileViewModel()
    @Environment(\.presentationMode)
    var presentationMode: Binding
    var userLoggout: (() -> Void)?
    var userUpdated: (() -> Void)?

    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(.white)
        }
    }

    init(user: UserModel, userUpdateCallback: (() -> Void)? = nil, userLogOutCallback: (() -> Void)? = nil ) {
        viewModel.currentUser = user
        _name = State(initialValue: user.info.name)
        _imageStr = State(initialValue: user.info.profileImage)
        userLoggout = userLogOutCallback
        userUpdated = userUpdateCallback
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ScrollView {
                    HStack {
                        VStack {
                            Button {
                                shouldShowImagePicker.toggle()
                            } label: {
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 128, height: 128)
                                        .clipped()
                                        .cornerRadius(128)
                                        .overlay(RoundedRectangle(cornerRadius: 128)
                                                    .stroke(Color.white, lineWidth: 2)
                                        )
                                } else {
                                    WebImage(url: URL(string: imageStr))
                                        .placeholder(content: {
                                            Image("ic_logo")
                                                .resizable()
                                                .frame(width: 60, height: 60)
                                                .scaledToFit()
                                                .foregroundColor(.white)
                                                .clipped()
                                        })
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .clipped()
                                        .cornerRadius(128)
                                        .overlay(RoundedRectangle(cornerRadius: 128).stroke(Color.white, lineWidth: 1))
                                }
                            }
                            FloatingLabelTextField($name, placeholder: "Name", editingChanged: { (isChanged) in

                            }) {

                            }
                            .lineColor(.white)
                            .titleColor(.white)
                            .textColor(.white)
                            .selectedLineColor(.white)
                            .selectedTextColor(.white)
                            .selectedTitleColor(.white)
                            .keyboardType(.emailAddress)
                            .frame(height: 75)
                            .padding(.horizontal)
                            Button(action: {
                                viewModel.updateProfile(name: name, image: image)
                                userUpdated?()
                            }) {
                                Text("Update")
                                    .frame(maxWidth: .infinity , minHeight: 60)
                                    .foregroundColor(.white)
                            }
                            .background(LinearGradient(colors: [Color("secondary"), Color("violet")], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(30)
                            .padding()
                        }
                        .padding()
                    }
                }
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    userLoggout?()
                }) {
                    Text("Sign out")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity , minHeight: 60)
                        .foregroundColor(.red)
                }
                .background(LinearGradient(colors: [Color("secondary"), Color("violet")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(30)
                .padding()
            }
            .background(Color("purple"))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .alert(item: $viewModel.msg, content: { info in
            Alert(title: Text(info.msg), message: Text(""), dismissButton: .default(Text("Ok"), action: {
                viewModel.msg = nil
            }))
        })
//        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .fullScreenCover(isPresented: $shouldShowImagePicker) {

        } content: {
            ImagePicker(image: $image)
        }

    }

    private func getImage() -> Image {
        if let image = self.image {
            return Image(uiImage: image)
        }

        return Image("ic_logo")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: UserModel(uid: "", info: UserInfoModel(profileImage: "", name: "", email: "", uid: "")))
    }
}

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?

    private let controller = UIImagePickerController()

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

    }

    func makeUIViewController(context: Context) -> some UIViewController {
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }

}
