import SwiftUI

struct MenuContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()

            if !viewModel.hasToken {
                SettingsView(viewModel: viewModel)
            } else if viewModel.isLoading && viewModel.pullRequests.isEmpty {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.pullRequests.isEmpty {
                emptyView
            } else {
                prListView
            }

            Divider()
            footer
        }
        .frame(width: 360)
        .onAppear { viewModel.start() }
    }

    private var header: some View {
        HStack {
            Image(systemName: "arrow.triangle.pull")
                .font(.title3)
            Text("FastGit")
                .font(.headline)

            Spacer()

            if viewModel.hasToken {
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Button(action: viewModel.refresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.borderless)
                    .help("Refresh")
                }
            }
        }
        .padding(12)
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                ProgressView()
                Text("Fetching pull requests...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            Spacer()
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") { viewModel.refresh() }
                .controlSize(.small)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title)
                .foregroundStyle(.green)
            Text("No pending reviews")
                .font(.callout.bold())
            Text("You're all caught up!")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }

    private var prListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.pullRequests) { pr in
                    PRRowView(pr: pr) {
                        viewModel.openPR(pr)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)

                    if pr.id != viewModel.pullRequests.last?.id {
                        Divider().padding(.leading, 12)
                    }
                }
            }
        }
        .frame(maxHeight: 400)
    }

    private var footer: some View {
        HStack {
            if viewModel.hasToken {
                SettingsFooter(viewModel: viewModel)
            }
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
    }
}

private struct SettingsFooter: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showSettings = false

    var body: some View {
        Button {
            showSettings.toggle()
        } label: {
            Image(systemName: "gearshape")
                .font(.caption)
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $showSettings, arrowEdge: .bottom) {
            SettingsView(viewModel: viewModel)
        }
    }
}
