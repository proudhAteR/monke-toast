import Foundation
import Observation
import SwiftUI

/// A single toast presentation stored by ``Toaster``.
///
/// `ToastPresentation` is intentionally value-based. The toaster creates a fresh `id` every time a toast is
/// shown so SwiftUI can animate replacement cleanly, even when two toasts have the same message.
public struct ToastPresentation: Identifiable, Equatable {
    /// Stable identity for this specific presentation.
    public let id: UUID

    /// Semantic content and visual intent shown by the toast view.
    public let state: ToastState

    /// Duration policy requested by the caller.
    public let duration: ToastDuration

    /// Resolved auto-dismiss timeout in seconds.
    ///
    /// `nil` means this toast is persistent and must be cleared manually.
    public let timeout: TimeInterval?

    /// Whether this toast stays visible until explicitly cleared.
    public var isPersistent: Bool {
        timeout == nil
    }

    /// Creates a new toast presentation.
    public init(id: UUID, state: ToastState, duration: ToastDuration, timeout: TimeInterval?) {
        self.id = id
        self.state = state
        self.duration = duration
        self.timeout = timeout
    }
}

/// Coordinates toast state for the whole app.
///
/// `Toaster` is the app-wide toast coordinator. It is a port of Scale.io's keyed toast view model, with
/// dismissal scheduling kept inside the service so SwiftUI views only render the current state. The toaster
/// stores one toast per ``ToastKey``. Showing a new toast for the same key replaces the previous one and
/// cancels its pending dismissal.
///
/// Inject the shared instance near the app root so any feature can request feedback:
///
/// ```swift
/// WindowGroup {
///     ContentView()
///         .loaf()
///         .environment(Toaster.shared)
/// }
/// ```
///
/// Feature views can then request feedback without knowing where the toast is rendered:
///
/// ```swift
/// @Environment(Toaster.self) private var toaster
///
/// toaster.success("Saved")
/// toaster.loading("Uploading", duration: .persistent)
/// toaster.clear()
/// ```
///
/// `Toaster` is a singleton. Use ``shared`` everywhere the app needs to show, inspect, or clear toast
/// state.
@available(macOS 14.0, *)
@MainActor
@Observable
public final class Toaster {
    /// Toasts currently visible or waiting to finish their transition.
    private var storage: [ToastKey: ToastPresentation] = [:]

    /// Auto-dismiss tasks keyed by toast slot.
    @ObservationIgnored
    private var dismissalTasks: [ToastKey: Task<Void, Never>] = [:]

    /// Default timeout used by `.automatic` non-loading toasts.
    private let defaultTimeout: TimeInterval
    
    /// Shared observable toast coordinator used by the app.
    public static let shared = Toaster()

    /// Creates a toaster with the default automatic dismissal timeout.
    ///
    /// Use ``shared`` in production code. The initializer is ``internal`` so tests
    /// can create isolated instances via `@testable import`.
    init() {
        self.defaultTimeout = 3
    }

    /// Returns the active toast for a key.
    ///
    /// - Parameter key: Toast slot to inspect.
    /// - Returns: The current presentation for the key, or `nil` when no toast is visible.
    public func toast(for key: ToastKey = .global) -> ToastPresentation? {
        storage[key]
    }

    /// Returns the active toast for a string key.
    ///
    /// This overload keeps migration from string-based toast systems simple.
    ///
    /// - Parameter key: Raw toast slot to inspect.
    /// - Returns: The current presentation for the key, or `nil` when no toast is visible.
    public func toast(for key: String) -> ToastPresentation? {
        toast(for: ToastKey(key))
    }

    /// Stores a toast for a key.
    ///
    /// Public callers use semantic helpers such as ``success(_:for:duration:)`` and
    /// ``loading(_:for:duration:)`` so feature code describes the feedback it wants to show.
    private func show(
        _ state: ToastState,
        for key: ToastKey = .global,
        duration: ToastDuration = .automatic
    ) {
        cancelDismissal(for: key)

        let presentation = ToastPresentation(
            id: UUID(),
            state: state,
            duration: duration,
            timeout: duration.timeout(for: state, defaultTimeout: defaultTimeout)
        )

        storage[key] = presentation
        scheduleDismissalIfNeeded(for: key, presentation: presentation)
    }

    /// Shows in-progress feedback.
    ///
    /// Loading toasts shown with `.automatic` stay visible until cleared.
    public func loading(
        _ message: String,
        for key: ToastKey = .global,
        duration: ToastDuration = .automatic
    ) {
        show(.loading(message), for: key, duration: duration)
    }

    /// Shows in-progress feedback for a string key.
    public func loading(
        _ message: String,
        for key: String,
        duration: ToastDuration = .automatic
    ) {
        loading(message, for: ToastKey(key), duration: duration)
    }

    /// Shows failure feedback.
    public func error(
        _ message: String,
        for key: ToastKey = .global,
        duration: ToastDuration = .automatic
    ) {
        show(.error(message), for: key, duration: duration)
    }

    /// Shows failure feedback for a string key.
    public func error(
        _ message: String,
        for key: String,
        duration: ToastDuration = .automatic
    ) {
        error(message, for: ToastKey(key), duration: duration)
    }

    /// Shows success feedback.
    public func success(
        _ message: String,
        for key: ToastKey = .global,
        duration: ToastDuration = .automatic
    ) {
        show(.success(message), for: key, duration: duration)
    }

    /// Shows success feedback for a string key.
    public func success(
        _ message: String,
        for key: String,
        duration: ToastDuration = .automatic
    ) {
        success(message, for: ToastKey(key), duration: duration)
    }

    /// Shows neutral information feedback.
    public func info(
        _ message: String,
        for key: ToastKey = .global,
        duration: ToastDuration = .automatic
    ) {
        show(.info(message), for: key, duration: duration)
    }

    /// Shows neutral information feedback for a string key.
    public func info(
        _ message: String,
        for key: String,
        duration: ToastDuration = .automatic
    ) {
        info(message, for: ToastKey(key), duration: duration)
    }

    /// Shows warning feedback.
    public func warning(
        _ message: String,
        for key: ToastKey = .global,
        duration: ToastDuration = .automatic
    ) {
        show(.warning(message), for: key, duration: duration)
    }

    /// Shows warning feedback for a string key.
    public func warning(
        _ message: String,
        for key: String,
        duration: ToastDuration = .automatic
    ) {
        warning(message, for: ToastKey(key), duration: duration)
    }

    /// Shows custom feedback with an optional SF Symbol, tint, and progress indicator.
    public func custom(
        _ message: String,
        systemImage: String? = nil,
        tint: Color = .secondary,
        showsProgress: Bool = false,
        for key: ToastKey = .global,
        duration: ToastDuration = .automatic
    ) {
        show(
            .custom(
                message: message,
                systemImage: systemImage,
                tint: tint,
                showsProgress: showsProgress
            ),
            for: key,
            duration: duration
        )
    }

    /// Shows custom feedback for a string key.
    public func custom(
        _ message: String,
        systemImage: String? = nil,
        tint: Color = .secondary,
        showsProgress: Bool = false,
        for key: String,
        duration: ToastDuration = .automatic
    ) {
        custom(
            message,
            systemImage: systemImage,
            tint: tint,
            showsProgress: showsProgress,
            for: ToastKey(key),
            duration: duration
        )
    }

    /// Clears the toast for a key.
    ///
    /// - Parameter key: Toast slot to clear.
    public func clear(_ key: ToastKey = .global) {
        cancelDismissal(for: key)
        storage.removeValue(forKey: key)
    }

    /// Clears the toast for a string key.
    ///
    /// - Parameter key: Raw toast slot to clear.
    public func clear(_ key: String) {
        clear(ToastKey(key))
    }

    /// Clears every visible toast and cancels all pending dismissals.
    public func clearAll() {
        dismissalTasks.values.forEach { $0.cancel() }
        dismissalTasks.removeAll()
        storage.removeAll()
    }

    /// Clears a toast only if it still matches the expected presentation.
    ///
    /// This prevents an old dismissal task from removing a newer toast that reused the same key.
    ///
    /// - Parameters:
    ///   - key: Toast slot to clear.
    ///   - id: Presentation id that must still be active.
    private func clear(_ key: ToastKey, matching id: UUID) {
        guard storage[key]?.id == id else { return }
        clear(key)
    }

    /// Schedules automatic dismissal for non-persistent toasts.
    ///
    /// - Parameters:
    ///   - key: Toast slot to dismiss.
    ///   - presentation: Presentation being scheduled.
    private func scheduleDismissalIfNeeded(for key: ToastKey, presentation: ToastPresentation) {
        guard let timeout = presentation.timeout else { return }

        dismissalTasks[key] = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Self.nanoseconds(for: timeout))
            guard !Task.isCancelled else { return }
            self?.clear(key, matching: presentation.id)
        }
    }

    /// Cancels a pending dismissal for a key.
    ///
    /// - Parameter key: Toast slot whose task should be cancelled.
    private func cancelDismissal(for key: ToastKey) {
        dismissalTasks[key]?.cancel()
        dismissalTasks[key] = nil
    }

    /// Converts seconds to nanoseconds for `Task.sleep`.
    ///
    /// - Parameter seconds: Delay in seconds.
    /// - Returns: Delay clamped to the representable `UInt64` nanosecond range.
    private static func nanoseconds(for seconds: TimeInterval) -> UInt64 {
        let maxSeconds = TimeInterval(UInt64.max) / 1_000_000_000
        let clampedSeconds = min(max(seconds, 0), maxSeconds)

        return UInt64(clampedSeconds * 1_000_000_000)
    }
}
