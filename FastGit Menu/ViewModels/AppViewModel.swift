import Foundation
import SwiftUI
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @AppStorage("githubToken") var token: String = ""
    @Published var pullRequests: [PullRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var username: String?

    private let gitHubService = GitHubService()
    private var pollingTimer: Timer?
    private var knownPRIds: Set<Int> = []
    private let pollingInterval: TimeInterval = 60

    var hasToken: Bool { !token.isEmpty }
    var prCount: Int { pullRequests.count }

    func start() {
        NotificationManager.shared.requestPermission()
        guard hasToken else { return }
        Task { await fetchPullRequests() }
        startPolling()
    }

    func saveToken(_ newToken: String) {
        token = newToken.trimmingCharacters(in: .whitespacesAndNewlines)
        username = nil
        knownPRIds = []
        pullRequests = []
        errorMessage = nil

        guard hasToken else {
            stopPolling()
            return
        }

        Task { await fetchPullRequests() }
        startPolling()
    }

    func removeToken() {
        token = ""
        username = nil
        pullRequests = []
        knownPRIds = []
        errorMessage = nil
        stopPolling()
    }

    func fetchPullRequests() async {
        guard hasToken else { return }
        isLoading = true
        errorMessage = nil

        do {
            if username == nil {
                let user = try await gitHubService.fetchCurrentUser(token: token)
                username = user.login
            }

            guard let username else { return }

            let prs = try await gitHubService.fetchReviewRequests(token: token, username: username)

            let newPRs = prs.filter { !knownPRIds.contains($0.id) }
            if !knownPRIds.isEmpty {
                for pr in newPRs {
                    NotificationManager.shared.sendNewPRNotification(pr)
                }
            }

            knownPRIds = Set(prs.map(\.id))
            pullRequests = prs
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func openPR(_ pr: PullRequest) {
        if let url = URL(string: pr.htmlURL) {
            NSWorkspace.shared.open(url)
        }
    }

    func refresh() {
        Task { await fetchPullRequests() }
    }

    private func startPolling() {
        stopPolling()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.fetchPullRequests()
            }
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
}
