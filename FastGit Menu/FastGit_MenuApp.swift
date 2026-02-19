import SwiftUI

@main
struct FastGit_MenuApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(viewModel: viewModel)
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "arrow.triangle.pull")
                if viewModel.prCount > 0 {
                    Text("\(viewModel.prCount)")
                        .font(.caption2)
                        .monospacedDigit()
                }
            }
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 360, height: 480)
    }

    init() {
        DispatchQueue.main.async {
            NSApplication.shared.setActivationPolicy(.accessory)
        }
    }
}
