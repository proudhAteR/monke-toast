import Foundation

/// Identifies the screen, flow, or feature area that owns a toast presentation.
///
/// `ToastKey` lets the app keep separate toast slots without creating separate toast managers. For example,
/// a login screen can show a toast under `.screen("login")` while the main shell keeps its own `.global`
/// toast. Showing a new toast for the same key replaces the previous toast for that key.
///
/// Use the built-in keys for app-wide feedback:
///
/// ```swift
/// toaster.success("Saved", for: .global)
/// ```
///
/// Use named keys when a feature needs isolated feedback:
///
/// ```swift
/// let profileToasts = ToastKey.screen("profile")
/// toaster.error("Could not update profile", for: profileToasts)
/// ```
public struct ToastKey: Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible, Sendable {
    /// Raw dictionary key used by ``Toaster``.
    public let rawValue: String

    /// Creates a key from a raw string value.
    ///
    /// - Parameter rawValue: Stable identifier for the toast slot.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a key from a raw string value.
    ///
    /// This convenience initializer keeps call sites short when a custom key is needed.
    ///
    /// - Parameter rawValue: Stable identifier for the toast slot.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a key from a string literal.
    ///
    /// This makes APIs such as `toaster.info("Ready", for: "settings")` possible while still
    /// storing strongly typed keys internally.
    ///
    /// - Parameter value: String literal used as the key.
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    /// Default app-wide toast slot.
    nonisolated public static let global = ToastKey("global:toasts")

    /// Common root-view toast slot.
    nonisolated public static let main = ToastKey("main:toasts")

    /// Creates a feature-scoped toast slot.
    ///
    /// - Parameter name: Screen, feature, or flow name.
    /// - Returns: A key namespaced for screen-level toasts.
    public static func screen(_ name: String) -> ToastKey {
        ToastKey("\(name):toasts")
    }

    /// Creates a tab-scoped toast slot.
    ///
    /// - Parameter rawValue: Stable tab identifier.
    /// - Returns: A key namespaced for tab-level toasts.
    public static func tab(_ rawValue: String) -> ToastKey {
        ToastKey("\(rawValue):tab:toasts")
    }

    /// Human-readable key value used in logs and debug output.
    public var description: String {
        rawValue
    }
}
