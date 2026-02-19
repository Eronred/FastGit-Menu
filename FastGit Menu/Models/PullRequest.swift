import Foundation

struct PullRequest: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    let htmlURL: String
    let number: Int
    let repositoryURL: String
    let user: PRUser
    let createdAt: String
    let updatedAt: String

    var repoFullName: String {
        repositoryURL
            .replacingOccurrences(of: "https://api.github.com/repos/", with: "")
    }

    enum CodingKeys: String, CodingKey {
        case id, title, number, user
        case htmlURL = "html_url"
        case repositoryURL = "repository_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PRUser: Codable, Equatable, Hashable {
    let login: String
    let avatarURL: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}

struct SearchResponse: Codable {
    let totalCount: Int
    let items: [PullRequest]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
