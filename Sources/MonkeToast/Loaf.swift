import SwiftUI

/// Placement for a toast overlay.
///
/// Use `.bottom` for most feedback because it avoids the status bar and navigation title area. Use `.top`
/// when the current screen already has important bottom controls.
public enum ToastPlacement: Equatable {
    /// Drag distance needed to dismiss a toast directly.
    static let dragDismissalThreshold: CGFloat = 44

    /// Predicted drag distance needed to dismiss a toast with momentum.
    static let predictedDragDismissalThreshold: CGFloat = 80

    /// Toast appears near the top safe-area edge.
    case top

    /// Toast appears near the bottom safe-area edge.
    case bottom

    /// SwiftUI overlay alignment for this placement.
    public var alignment: Alignment {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }

    /// Transition edge used when the toast appears or disappears.
    public var transitionEdge: Edge {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }

    /// Padding edge that receives the configured edge margin.
    public var paddingEdge: Edge.Set {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }

    /// Vertical offset to apply while the user drags the toast toward its dismissal edge.
    func dragOffset(for translation: CGSize) -> CGFloat {
        switch self {
        case .top:
            return min(translation.height, 0)
        case .bottom:
            return max(translation.height, 0)
        }
    }

    /// Whether a completed drag should dismiss the toast.
    func dismissesToast(translation: CGSize, predictedEndTranslation: CGSize) -> Bool {
        switch self {
        case .top:
            return translation.height < -Self.dragDismissalThreshold
                || predictedEndTranslation.height < -Self.predictedDragDismissalThreshold
        case .bottom:
            return translation.height > Self.dragDismissalThreshold
                || predictedEndTranslation.height > Self.predictedDragDismissalThreshold
        }
    }
}

/// A SwiftUI host that gives popped toast somewhere to appear.
///
/// `Loaf` is the bread-side counterpart to ``Toaster``. The toaster owns the state, timing, replacement,
/// and dismissal work: it is the thing that makes toast "pop." A loaf is the view-side holder you place in
/// the SwiftUI hierarchy so the currently popped slice can be rendered on screen.
///
/// Each loaf listens to one ``ToastKey`` and renders only that key's current presentation. Install a global
/// loaf at the app root for app-wide feedback, then add feature-specific loaves only when a screen, tab, or
/// flow needs its own isolated toast area.
@available(macOS 14.0, *)
public struct Loaf: View {
    /// Shared toaster that owns toast state.
    ///
    /// The value is optional so previews and partially assembled root views do not crash if a toaster
    /// has not been injected yet. Without a toaster, the loaf simply renders nothing.
    @Environment(Toaster.self) private var toaster: Toaster?

    /// Toast slot rendered by this loaf.
    var key: ToastKey = .global

    /// Screen edge where the toast should appear.
    var placement: ToastPlacement = .bottom

    /// Styling values passed to the toast view.
    var configuration = ToastViewConfiguration()

    /// Current drag translation while the user swipes a toast toward its dismissal edge.
    @GestureState private var dragTranslation: CGSize = .zero

    /// Creates a loaf for one toast slot.
    ///
    /// - Parameters:
    ///   - key: Toast slot to render.
    ///   - placement: Screen edge where the toast should appear.
    ///   - configuration: Styling values for the rendered toast.
    public init(
        key: ToastKey = .global,
        placement: ToastPlacement = .bottom,
        configuration: ToastViewConfiguration = ToastViewConfiguration()
    ) {
        self.key = key
        self.placement = placement
        self.configuration = configuration
    }

    public var body: some View {
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
                .contentShape(Rectangle())
                .offset(y: placement.dragOffset(for: dragTranslation))
                .simultaneousGesture(dismissGesture(toaster: toaster, key: key))
                .transition(.move(edge: placement.transitionEdge).combined(with: .opacity))
                .id(presentation.id)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: presentation?.id)
        .animation(.interactiveSpring(response: 0.24, dampingFraction: 0.86), value: dragTranslation)
    }

    /// Drag gesture that clears the toast when it is swiped toward its placement edge.
    private func dismissGesture(toaster: Toaster, key: ToastKey) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($dragTranslation) { value, state, _ in
                state = CGSize(width: 0, height: placement.dragOffset(for: value.translation))
            }
            .onEnded { value in
                if placement.dismissesToast(
                    translation: value.translation,
                    predictedEndTranslation: value.predictedEndTranslation
                ) {
                    toaster.clear(key)
                }
            }
    }
}

/// Convenience API for installing a loaf over any view.
extension View {
    /// Adds a keyed loaf overlay to the view.
    ///
    /// The view must have a ``Toaster`` in the environment. A common setup is to inject ``Toaster/shared``
    /// in the app entry point and call `.loaf()` on the root content view. The modified view expands
    /// to the available container so the toast is positioned against the screen area instead of the root
    /// view's intrinsic content size.
    ///
    /// - Parameters:
    ///   - key: Toast slot to render.
    ///   - placement: Screen edge where the toast should appear.
    ///   - configuration: Styling values for the rendered toast.
    /// - Returns: A view with a toast overlay.
    @available(macOS 14.0, *)
    public func loaf(
        _ key: ToastKey = .global,
        placement: ToastPlacement = .bottom,
        configuration: ToastViewConfiguration = ToastViewConfiguration()
    ) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: placement.alignment) {
                Loaf(
                    key: key,
                    placement: placement,
                    configuration: configuration
                )
            }
    }
}
