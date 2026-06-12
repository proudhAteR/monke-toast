import SwiftUI

/// Leading visual shown before a toast message.
public enum ToastIndicator: Equatable {
    /// Shows no leading visual before the message.
    case none

    /// Shows a spinner before the message.
    case progress

    /// Shows an emoji before the message.
    case emoji(String)

    /// Shows an SF Symbol before the message.
    case systemImage(String, tint: Color)
}

/// Describes the content and visual intent of a toast.
///
/// `ToastState` keeps feature code focused on the meaning of the message instead of the exact icon, color,
/// or loading indicator used by the UI. The default cases cover the feedback most apps need: loading,
/// success, information, warnings, and errors.
///
/// Show a standard state through ``Toaster``:
///
/// ```swift
/// toaster.success("Profile saved")
/// toaster.loading("Uploading", duration: .persistent)
/// toaster.custom("Toast is ready", emoji: "🍞")
/// ```
///
/// Use `.custom` when a feature needs an explicit progress spinner, emoji, or SF Symbol while still using
/// the shared toast rendering and dismissal behavior.
public enum ToastState: Equatable {
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

    /// Custom feedback with an explicit leading indicator.
    case custom(
        message: String,
        indicator: ToastIndicator
    )

    /// Text displayed inside the toast.
    public var message: String {
        switch self {
        case .loading(let message),
             .error(let message),
             .success(let message),
             .info(let message),
             .warning(let message):
            return message
        case .custom(let message, _):
            return message
        }
    }

    /// Leading visual displayed before the message.
    public var indicator: ToastIndicator {
        switch self {
        case .loading:
            return .progress
        case .error:
            return .systemImage("xmark.octagon.fill", tint: .red)
        case .success:
            return .systemImage("checkmark.circle.fill", tint: .green)
        case .info:
            return .systemImage("info.circle.fill", tint: .secondary)
        case .warning:
            return .systemImage("exclamationmark.triangle.fill", tint: .orange)
        case .custom(_, let indicator):
            return indicator
        }
    }

    /// SF Symbol displayed before the message.
    ///
    /// Loading states return `nil` because they use a `ProgressView` instead of an icon.
    public var systemImage: String? {
        if case .systemImage(let systemImage, _) = indicator {
            return systemImage
        }

        return nil
    }

    /// Emoji displayed before the message.
    public var emoji: String? {
        if case .emoji(let emoji) = indicator {
            return emoji
        }

        return nil
    }

    /// Tint color applied to the leading icon.
    public var tint: Color {
        if case .systemImage(_, let tint) = indicator {
            return tint
        }

        return .secondary
    }

    /// Whether the toast should show a spinner instead of an icon.
    public var showsProgress: Bool {
        if case .progress = indicator {
            return true
        }

        return false
    }

    /// Whether this state represents work that is still in progress.
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    /// Accessibility label that combines the toast type and message.
    public var accessibilityLabel: String {
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
