import SwiftUI

@main
struct FastGit_MenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
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
            .onAppear { viewModel.start() }
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 360, height: 480)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}
