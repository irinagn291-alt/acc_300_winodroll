import SwiftUI

/// Role: Desk. Empty hold: generated cutout, one headline, one line, full-width Stamp.
struct DeskBlank: View {
    let warning: DeskWarning?
    let writeFailed: Bool
    let onStamp: () -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let warning {
                banner(text: warningLine(warning), retry: false)
            }
            if writeFailed {
                banner(text: "The desk did not save.", retry: true)
            }
            CutoutArt(resource: "ctf_EmptyHome")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text("File a want.")
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(2))
            Text("The span starts.")
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(1))
                .padding(.bottom, DeskSpace.n(3))
            Button("Stamp", action: onStamp)
                .buttonStyle(StampPress())
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.bottom, DeskSpace.n(3))
                .accessibilityHint("File a priced want and stamp its hold ticket.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DeskColor.background)
    }

    private func warningLine(_ warning: DeskWarning) -> String {
        switch warning {
        case .recoveredFromBackup: return "Restored the last good desk."
        case .startedEmpty: return "The desk file was unreadable."
        }
    }

    private func banner(text: String, retry: Bool) -> some View {
        HStack(alignment: .center, spacing: DeskSpace.n(2)) {
            Text(text)
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            if retry {
                Button("Retry", action: onRetry)
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.accent)
                    .frame(minHeight: DeskSpace.n(6))
            }
        }
        .padding(.horizontal, DeskSpace.n(3))
        .padding(.vertical, DeskSpace.n(1))
    }
}
