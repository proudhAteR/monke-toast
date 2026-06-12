import Foundation

/// Controls how long a toast remains visible.
///
/// `ToastDuration` replaces the common pair of `persist` and `timeout` flags with one explicit policy. This
/// keeps call sites easier to read and prevents impossible combinations such as a persistent toast with a
/// non-zero timeout.
///
/// Use `.automatic` for normal user feedback:
///
/// ```swift
/// toaster.show(.success("Saved"))
/// ```
///
/// Use `.persistent` for progress or messages that must stay visible until the owning feature clears them:
///
/// ```swift
/// toaster.show(.loading("Syncing"), duration: .persistent)
/// ```
enum ToastDuration: Equatable {
    /// Uses the toaster's default timeout for finished states and persists loading states.
    case automatic

    /// Keeps the toast visible for a specific number of seconds.
    case seconds(TimeInterval)

    /// Keeps the toast visible until code explicitly clears it.
    case persistent

    /// Resolves this policy into an optional timeout.
    ///
    /// `nil` means the toast should persist until it is replaced or cleared.
    ///
    /// - Parameters:
    ///   - state: Toast state being shown.
    ///   - defaultTimeout: Default timeout used for `.automatic` non-loading states.
    /// - Returns: Number of seconds before dismissal, or `nil` for persistent toasts.
    func timeout(for state: ToastState, defaultTimeout: TimeInterval) -> TimeInterval? {
        switch self {
        case .automatic:
            return state.isLoading ? nil : defaultTimeout
        case .seconds(let seconds):
            return seconds > 0 ? seconds : nil
        case .persistent:
            return nil
        }
    }
}
