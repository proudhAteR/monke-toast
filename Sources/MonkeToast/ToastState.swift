import SwiftUI

/// Describes the content and visual intent of a toast.
///
/// `ToastState` keeps feature code focused on the meaning of the message instead of the exact icon, color,
/// or loading indicator used by the UI. The default cases cover the feedback most apps need: loading,
/// success, information, warnings, and errors.
///
/// Show a standard state through ``Toaster``:
///
/// ```swift
/// toaster.show(.success("Profile saved"))
/// toaster.show(.loading("Uploading"), duration: .persistent)
/// ```
///
/// Use `.custom` when a feature needs a specific SF Symbol or tint color while still using the shared toast
/// rendering and dismissal behavior.
enum ToastState: Equatable {
    /// In-progress feedback shown with a spinner.
    case loading(String)

    /// Failure feedback shown with an error icon and red tint.
    case error(String)

    /// Success feedback shown with a confirmation icon and green tint.
    case success(String)

    /// Neutral feedback shown with an information icon.
    case info(String)

    /// Warning feedback shown with a warning icon and orange tint.
    case warning(String)

    /// Custom feedback with optional SF Symbol, tint, and progress indicator.
    case custom(
        message: String,
        systemImage: String? = nil,
        tint: Color = .secondary,
        showsProgress: Bool = false
    )

    /// Text displayed inside the toast.
    var message: String {
        switch self {
        case .loading(let message),
             .error(let message),
             .success(let message),
             .info(let message),
             .warning(let message):
            return message
        case .custom(let message, _, _, _):
            return message
        }
    }

    /// SF Symbol displayed before the message.
    ///
    /// Loading states return `nil` because they use a `ProgressView` instead of an icon.
    var systemImage: String? {
        switch self {
        case .loading:
            return nil
        case .error:
            return "xmark.octagon.fill"
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .custom(_, let systemImage, _, _):
            return systemImage
        }
    }

    /// Tint color applied to the leading icon.
    var tint: Color {
        switch self {
        case .loading:
            return .secondary
        case .error:
            return .red
        case .success:
            return .green
        case .info:
            return .secondary
        case .warning:
            return .orange
        case .custom(_, _, let tint, _):
            return tint
        }
    }

    /// Whether the toast should show a spinner instead of an icon.
    var showsProgress: Bool {
        switch self {
        case .loading:
            return true
        case .custom(_, _, _, let showsProgress):
            return showsProgress
        default:
            return false
        }
    }

    /// Whether this state represents work that is still in progress.
    var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    /// Accessibility label that combines the toast type and message.
    var accessibilityLabel: String {
        "\(accessibilityPrefix): \(message)"
    }

    /// Short label describing the kind of feedback being shown.
    private var accessibilityPrefix: String {
        switch self {
        case .loading:
            return "Loading"
        case .error:
            return "Error"
        case .success:
            return "Success"
        case .info:
            return "Info"
        case .warning:
            return "Warning"
        case .custom:
            return "Message"
        }
    }
}
