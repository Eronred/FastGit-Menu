import SwiftUI

struct PRRowView: View {
    let pr: PullRequest
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 4) {
                Text(pr.repoFullName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("#\(pr.number) \(pr.title)")
                    .font(.system(.body, weight: .medium))
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption2)
                    Text(pr.user.login)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(relativeTime(from: pr.createdAt))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func relativeTime(from isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoDate)
                ?? ISO8601DateFormatter().date(from: isoDate) else {
            return ""
        }

        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .abbreviated
        return relative.localizedString(for: date, relativeTo: Date())
    }
}
