import SwiftUI

/// Visual configuration for a toast banner.
///
/// `ToastViewConfiguration` keeps layout and styling values in one place so `ToastView`, `ToastStack`, and
/// previews can share the same defaults without duplicating hard-coded padding, radius, or width values.
struct ToastViewConfiguration: Equatable {
    /// Minimum width of the toast card.
    ///
    /// This prevents short messages or narrow parent layouts from collapsing the card into a vertical pill.
    var minWidth: CGFloat = 260

    /// Maximum width of the toast card.
    var maxWidth: CGFloat = 560

    /// Horizontal spacing from the screen edge.
    var horizontalMargin: CGFloat = 16

    /// Spacing from the top or bottom safe-area edge, depending on placement.
    var edgeMargin: CGFloat = 12

    /// Padding inside the toast card.
    var contentPadding: CGFloat = 14

    /// Space between the leading indicator, message, and dismiss button.
    var spacing: CGFloat = 10

    /// Corner radius for the toast card.
    var cornerRadius: CGFloat = 14

    /// Whether the toast should include a manual dismiss button.
    var showsDismissButton: Bool = true
}

/// Renders a single toast presentation.
///
/// `ToastView` is intentionally stateless. It receives a ``ToastPresentation`` from ``Toaster`` and
/// renders the message, icon or loading spinner, and optional dismiss button. Timing and replacement logic
/// stay in the toaster so this view can remain focused on presentation.
struct ToastView: View {
    /// Toast presentation to render.
    let presentation: ToastPresentation

    /// Styling values for the toast card.
    var configuration = ToastViewConfiguration()

    /// Callback used when the user taps the dismiss button.
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: configuration.spacing) {
            leadingIndicator

            Text(presentation.state.message)
                .font(presentation.state.isLoading ? .footnote.weight(.semibold) : .footnote)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

            dismissButton
        }
        .padding(configuration.contentPadding)
        .frame(minWidth: configuration.minWidth, maxWidth: configuration.maxWidth, alignment: .leading)
        .toastSurface(configuration: configuration)
        .shadow(color: .black.opacity(0.14), radius: 18, x: 0, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(presentation.state.accessibilityLabel)
    }

    /// Leading spinner or SF Symbol for the toast state.
    @ViewBuilder
    private var leadingIndicator: some View {
        if presentation.state.showsProgress {
            ProgressView()
                .controlSize(.regular)
                .padding(.top, 1)
        } else if let systemImage = presentation.state.systemImage {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(presentation.state.tint)
                .padding(.top, 1)
                .accessibilityHidden(true)
        }
    }

    /// Optional manual dismiss button.
    @ViewBuilder
    private var dismissButton: some View {
        if configuration.showsDismissButton, let onDismiss {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
    }
}

private extension View {
    /// Applies the best available toast backing for the current platform version.
    @ViewBuilder
    func toastSurface(configuration: ToastViewConfiguration) -> some View {
        let shape = RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)

        #if os(iOS)
        if #available(iOS 26.0, *) {
            glassToastSurface(shape: shape)
        } else {
            materialToastSurface(shape: shape)
        }
        #else
        materialToastSurface(shape: shape)
        #endif
    }

    #if os(iOS)
    @available(iOS 26.0, *)
    private func glassToastSurface(shape: RoundedRectangle) -> some View {
        glassEffect(.regular, in: shape)
    }
    #endif

    private func materialToastSurface(shape: RoundedRectangle) -> some View {
        background(.regularMaterial, in: shape)
            .overlay {
                shape.stroke(toastSeparatorColor.opacity(0.32), lineWidth: 1)
            }
    }

    private var toastSeparatorColor: Color {
        #if os(macOS)
        Color(.separatorColor)
        #else
        Color(.separator)
        #endif
    }
}

#Preview("Toast States") {
    VStack(spacing: 12) {
        ToastView(presentation: .preview(.loading("Syncing your data")))
        ToastView(presentation: .preview(.success("Profile saved")))
        ToastView(presentation: .preview(.info("You are back online")))
        ToastView(presentation: .preview(.warning("Connection is unstable")))
        ToastView(presentation: .preview(.error("Could not save changes")))
        ToastView(
            presentation: .preview(
                .custom(
                    message: "Custom toast with its own icon.",
                    systemImage: "sparkles",
                    tint: .blue
                )
            )
        )
    }
    .padding()
}

private extension ToastPresentation {
    /// Creates a presentation for previews.
    ///
    /// - Parameter state: State to preview.
    /// - Returns: A persistent presentation suitable for static previews.
    static func preview(_ state: ToastState) -> ToastPresentation {
        ToastPresentation(
            id: UUID(),
            state: state,
            duration: .persistent,
            timeout: nil
        )
    }
}
