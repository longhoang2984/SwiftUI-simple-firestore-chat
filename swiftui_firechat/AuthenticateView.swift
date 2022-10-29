//
//  ContentView.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 11/30/21.
//

import SwiftUI
import CoreData
import FloatingLabelTextFieldSwiftUI

struct AuthenticateView: View {

    @State private var selection: Int = 0
    @State private var email: String = ""
    @State private var pw: String = ""
    var didCompleteLoginProcess: (() -> Void)?

    init(didCompleteLoginProcess: (() -> Void)?) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
    }

    var body: some View {
        ScrollView {
            Spacer(minLength: 40)
            Image(
                "ic_logo"
            )
            Spacer(minLength: 70)
            form
            .frame(maxWidth: .infinity, minHeight: 60.0)

        }
        .background {
            Image("bg_authenticate")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }

    var form: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    selection = 0
                }) {
                    ZStack {
                        SignInShape(percent: 100)
                            .fill(Color("primary").opacity(selection == 0 ? 1.0 : 0.35 ))
                            .padding(.horizontal)
                        Text("Sign In".uppercased())
                            .font(Font.system(size: 20))
                            .bold()
                            .foregroundColor(Color.white)
                    }
                }
                .zIndex(0)
                Button(action: {
                    selection = 1
                }) {
                    ZStack {
                        RegisterShape(percent: 100)
                            .fill(Color("primary").opacity(selection == 1 ? 1.0 : 0.35))
                            .padding(.horizontal)
                        Text("Register".uppercased())
                            .font(Font.system(size: 20))
                            .bold()
                            .foregroundColor(Color.white)
                    }
                }
                .zIndex(2)
            }
            .frame(minHeight: 60)
            VStack {
                FloatingLabelTextField($email, placeholder: "Email", editingChanged: { (isChanged) in

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
                FloatingLabelTextField($pw, placeholder: "Password", editingChanged: { (isChanged) in

                        }) {

                        }
                        .lineColor(.white)
                        .titleColor(.white)
                        .textColor(.white)
                        .selectedLineColor(.white)
                        .selectedTextColor(.white)
                        .selectedTitleColor(.white)
                        .isSecureTextEntry(true)
                        .keyboardType(.emailAddress)
                        .frame(height: 75)
                        .padding(.horizontal)
                Spacer(minLength: 20)

                Button(action: {
                    selection == 0 ? signIn() : register()
                }) {
                    Text(
                        selection == 0 ? "Sign in" : "Register"
                    )
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, minHeight: 60)
                }
                .background {
                    LinearGradient(colors: [Color("secondary"), Color("violet")], startPoint: .leading, endPoint: .trailing)
                }
                .cornerRadius(30)
                .padding()
                if selection == 1 {
                    Text(
                        "By clicking Sign in, you agree to the Terms & Conditions & Privacy Policy"
                    )
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color.white)
                        .font(.caption)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                Spacer(minLength: 20)
            }
            .background(Color("primary"))
            .padding(.horizontal)
        }

    }

    private func register() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: pw) { result, err in
            if let err = err {
                print(err)
                return
            }
            storeUserInfo()
        }
    }

    private func signIn() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: pw) { result, err in
            if let err = err {
                print(err)
                return
            }
            self.didCompleteLoginProcess?()
        }
    }

    private func storeUserInfo() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [
            "email": self.email,
            "uid": uid,
            "profileImage": "",
            "name": String(self.email.split(separator: "@").first ?? "")
        ]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    return
                }
                self.didCompleteLoginProcess?()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticateView(didCompleteLoginProcess: nil).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct SignInShape: Shape {
    let radius: CGFloat = 6
    @State var percent: Double
    func path(in rect: CGRect) -> Path {
        let edge = rect.width
        var path = Path()

        let tle = CGPoint(x: rect.maxX - edge + radius, y: rect.minY + radius)
        let tls = CGPoint(x: rect.maxX - edge, y: rect.minY)
        let trs = CGPoint(x: rect.maxX + 15, y: rect.minY + radius)
        let tre = CGPoint(x: rect.maxX + 15 - radius, y: rect.minY + radius)
        let bl = CGPoint(x: rect.maxX - edge, y: rect.maxY)
        let br = CGPoint(x: rect.maxX + 35, y: rect.maxY )

        path.move(to: br)
        path.addLine(to: bl)
        path.addLine(to: tls)
        path.addRelativeArc(center: tle, radius: radius,
                            startAngle: Angle.degrees(180), delta: Angle.degrees(90))
        //    path.addLine(to: tle)
//        path.addLine(to: tre)
        path.addRelativeArc(center: tre, radius: radius,
                            startAngle: Angle.degrees(270), delta: Angle.degrees(45))
        path.addLine(to: trs)
        return path
    }
}

struct RegisterShape: Shape {
    let radius: CGFloat = 6
    @State var percent: Double
    func path(in rect: CGRect) -> Path {
        let edge = rect.width
        var path = Path()

        let tl = CGPoint(x: rect.maxX - edge - 15 - radius, y: rect.minY + radius)
        let tle = CGPoint(x: rect.maxX - edge - 15, y: rect.minY + radius)
        let tr = CGPoint(x: rect.maxX - radius, y: rect.minY )
        let tre = CGPoint(x: rect.maxX - radius, y: rect.minY + radius)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bl = CGPoint(x: rect.maxX - edge - 35, y: rect.maxY)

        path.move(to: br)
        path.addLine(to: bl)
        path.addLine(to: tl)
        path.addRelativeArc(center: tle, radius: radius,
                            startAngle: Angle.degrees(180), delta: Angle.degrees(90))

        path.addLine(to: tr)
        path.addRelativeArc(center: tre, radius: radius,
                            startAngle: Angle.degrees(180), delta: Angle.degrees(180))
        return path
    }
}
