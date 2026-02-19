import SwiftUI

@main
struct FastGit_MenuApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.pull")
                if viewModel.prCount > 0 {
                    Text("\(viewModel.prCount)")
                        .font(.system(size: 11, weight: .medium))
                        .monospacedDigit()
                        .baselineOffset(-0.5)
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
