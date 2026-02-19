import Foundation

actor GitHubService {
    private let baseURL = "https://api.github.com"
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "application/vnd.github.v3+json"
        ]
        self.session = URLSession(configuration: config)
    }

    func fetchCurrentUser(token: String) async throws -> GitHubUser {
        let url = URL(string: "\(baseURL)/user")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try JSONDecoder().decode(GitHubUser.self, from: data)
    }

    func fetchReviewRequests(token: String, username: String) async throws -> [PullRequest] {
        let query = "type:pr+state:open+review-requested:\(username)"
        let urlString = "\(baseURL)/search/issues?q=\(query)&sort=updated&order=desc&per_page=50"
        let url = URL(string: urlString)!

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse.items
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw GitHubError.unauthorized
        case 403:
            throw GitHubError.rateLimited
        case 404:
            throw GitHubError.notFound
        default:
            throw GitHubError.httpError(httpResponse.statusCode)
        }
    }
}

enum GitHubError: LocalizedError {
    case invalidResponse
    case unauthorized
    case rateLimited
    case notFound
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from GitHub"
        case .unauthorized:
            return "Invalid or expired token. Please check your GitHub token."
        case .rateLimited:
            return "GitHub API rate limit exceeded. Please wait a moment."
        case .notFound:
            return "Resource not found"
        case .httpError(let code):
            return "GitHub API error (HTTP \(code))"
        }
    }
}
