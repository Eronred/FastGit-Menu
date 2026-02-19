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
    private var pollingTask: Task<Void, Never>?
    private var knownPRIds: Set<Int> = []
    private var hasCompletedInitialFetch = false
    private let pollingInterval: UInt64 = 30_000_000_000

    var hasToken: Bool { !token.isEmpty }
    var prCount: Int { pullRequests.count }

    func start() {
        guard pollingTask == nil else { return }
        NotificationManager.shared.requestPermission()
        guard hasToken else { return }
        startPolling()
    }

    func saveToken(_ newToken: String) {
        token = newToken.trimmingCharacters(in: .whitespacesAndNewlines)
        username = nil
        knownPRIds = []
        pullRequests = []
        errorMessage = nil
        hasCompletedInitialFetch = false

        guard hasToken else {
            stopPolling()
            return
        }

        startPolling()
    }

    func removeToken() {
        token = ""
        username = nil
        pullRequests = []
        knownPRIds = []
        errorMessage = nil
        hasCompletedInitialFetch = false
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
            if hasCompletedInitialFetch {
                for pr in newPRs {
                    NotificationManager.shared.sendNewPRNotification(pr)
                }
            }

            knownPRIds = Set(prs.map(\.id))
            pullRequests = prs
            hasCompletedInitialFetch = true
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
        pollingTask = Task {
            await fetchPullRequests()
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: pollingInterval)
                guard !Task.isCancelled else { break }
                await fetchPullRequests()
            }
        }
    }

    private func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}
