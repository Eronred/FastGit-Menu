import Foundation

struct GitHubUser: Codable {
    let login: String
    let id: Int
    let avatarURL: String
    let name: String?

    enum CodingKeys: String, CodingKey {
        case login, id, name
        case avatarURL = "avatar_url"
    }
}
