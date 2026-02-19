import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var tokenInput: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.hasToken {
                connectedView
            } else {
                tokenInputView
            }
        }
        .padding(12)
    }

    private var connectedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                if let username = viewModel.username {
                    Text("Connected as **\(username)**")
                        .font(.callout)
                } else {
                    Text("Connected")
                        .font(.callout)
                }
            }

            Button("Disconnect", role: .destructive) {
                viewModel.removeToken()
            }
            .controlSize(.small)
        }
    }

    private var tokenInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GitHub Personal Access Token")
                .font(.callout.bold())

            Text("Create a token with **repo** scope at\nGitHub → Settings → Developer settings → Tokens")
                .font(.caption)
                .foregroundStyle(.secondary)

            SecureField("ghp_xxxxxxxxxxxx", text: $tokenInput)
                .textFieldStyle(.roundedBorder)
                .controlSize(.regular)
                .onSubmit { save() }

            Button("Save Token") { save() }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(tokenInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func save() {
        viewModel.saveToken(tokenInput)
        tokenInput = ""
    }
}
