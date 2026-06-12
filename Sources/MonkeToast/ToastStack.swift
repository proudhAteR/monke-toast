import SwiftUI

/// Placement for a toast overlay.
///
/// Use `.bottom` for most feedback because it avoids the status bar and navigation title area. Use `.top`
/// when the current screen already has important bottom controls.
enum ToastPlacement: Equatable {
    /// Toast appears near the top safe-area edge.
    case top

    /// Toast appears near the bottom safe-area edge.
    case bottom

    /// SwiftUI overlay alignment for this placement.
    var alignment: Alignment {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }

    /// Transition edge used when the toast appears or disappears.
    var transitionEdge: Edge {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }

    /// Padding edge that receives the configured edge margin.
    var paddingEdge: Edge.Set {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
}

/// Displays the active toast for one key.
///
/// `ToastStack` mirrors the keyed approach from Scale.io: each stack listens to one ``ToastKey`` and renders
/// only that key's current presentation. Install a global stack at the app root, then add more stacks in
/// specific screens only when a feature needs an isolated toast area.
@available(macOS 14.0, *)
struct ToastStack: View {
    /// Shared toaster that owns toast state.
    ///
    /// The value is optional so previews and partially assembled root views do not crash if a toaster
    /// has not been injected yet. Without a toaster, the stack simply renders nothing.
    @Environment(Toaster.self) private var toaster: Toaster?

    /// Toast slot rendered by this stack.
    var key: ToastKey = .global

    /// Screen edge where the toast should appear.
    var placement: ToastPlacement = .bottom

    /// Styling values passed to the toast view.
    var configuration = ToastViewConfiguration()

    var body: some View {
        let presentation = toaster?.toast(for: key)

        Group {
            if let toaster, let presentation {
                ToastView(
                    presentation: presentation,
                    configuration: configuration,
                    onDismiss: {
                        toaster.clear(key)
                    }
                )
                .padding(.horizontal, configuration.horizontalMargin)
                .padding(placement.paddingEdge, configuration.edgeMargin)
                .transition(.move(edge: placement.transitionEdge).combined(with: .opacity))
                .id(presentation.id)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: presentation?.id)
    }
}

/// Convenience API for installing a toast stack over any view.
extension View {
    /// Adds a keyed toast overlay to the view.
    ///
    /// The view must have a ``Toaster`` in the environment. A common setup is to inject ``Toaster/shared``
    /// in the app entry point and call `.toastStack()` on the root content view. The modified view expands
    /// to the available container so the toast is positioned against the screen area instead of the root
    /// view's intrinsic content size.
    ///
    /// - Parameters:
    ///   - key: Toast slot to render.
    ///   - placement: Screen edge where the toast should appear.
    ///   - configuration: Styling values for the rendered toast.
    /// - Returns: A view with a toast overlay.
    @available(macOS 14.0, *)
    func toastStack(
        _ key: ToastKey = .global,
        placement: ToastPlacement = .bottom,
        configuration: ToastViewConfiguration = ToastViewConfiguration()
    ) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: placement.alignment) {
                ToastStack(
                    key: key,
                    placement: placement,
                    configuration: configuration
                )
            }
    }
}
