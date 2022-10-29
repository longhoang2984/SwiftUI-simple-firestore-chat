//
//  UserModel.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 12/6/21.
//

import Foundation

struct UserModel: Identifiable {
    var id: String { uid }
    var uid: String
    var info: UserInfoModel
}

struct UserInfoModel: Codable {
    var profileImage, name, email, uid: String
}

// MARK: UserModel convenience initializers and mutators

extension UserInfoModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserInfoModel.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        profileImage: String? = nil,
        name: String? = nil,
        email: String? = nil,
        uid: String? = nil
    ) -> UserInfoModel {
        return UserInfoModel(
            profileImage: profileImage ?? self.profileImage,
            name: name ?? self.name,
            email: email ?? self.email,
            uid: uid ?? self.uid
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
