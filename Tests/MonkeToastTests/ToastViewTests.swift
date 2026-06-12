import Testing
import SwiftUI
@testable import MonkeToast

struct ToastViewConfigurationTests {
    // MARK: - Defaults

    @Test func defaultConfiguration_hasExpectedValues() {
        let config = ToastViewConfiguration()
        #expect(config.minWidth == 260)
        #expect(config.maxWidth == 560)
        #expect(config.horizontalMargin == 16)
        #expect(config.edgeMargin == 12)
        #expect(config.contentPadding == 14)
        #expect(config.spacing == 10)
        #expect(config.cornerRadius == 14)
        #expect(config.showsDismissButton == true)
    }

    // MARK: - Custom Configuration

    @Test func customConfiguration() {
        let config = ToastViewConfiguration(
            minWidth: 200,
            maxWidth: 400,
            horizontalMargin: 20,
            edgeMargin: 8,
            contentPadding: 12,
            spacing: 8,
            cornerRadius: 10,
            showsDismissButton: false
        )
        #expect(config.minWidth == 200)
        #expect(config.maxWidth == 400)
        #expect(config.horizontalMargin == 20)
        #expect(config.edgeMargin == 8)
        #expect(config.contentPadding == 12)
        #expect(config.spacing == 8)
        #expect(config.cornerRadius == 10)
        #expect(config.showsDismissButton == false)
    }

    @Test func configuration_withZeroValues() {
        let config = ToastViewConfiguration(
            minWidth: 0,
            maxWidth: 0,
            horizontalMargin: 0,
            edgeMargin: 0,
            contentPadding: 0,
            spacing: 0,
            cornerRadius: 0
        )
        #expect(config.minWidth == 0)
        #expect(config.maxWidth == 0)
        #expect(config.spacing == 0)
        #expect(config.cornerRadius == 0)
    }

    @Test func configuration_withNegativeValues() {
        let config = ToastViewConfiguration(minWidth: -10, cornerRadius: -5)
        #expect(config.minWidth == -10)
        #expect(config.cornerRadius == -5)
    }

    // MARK: - Equatable

    @Test func defaultConfigurations_areEqual() {
        #expect(ToastViewConfiguration() == ToastViewConfiguration())
    }

    @Test func configurations_withDifferentValues_areNotEqual() {
        let defaultConfig = ToastViewConfiguration()
        let modified = ToastViewConfiguration(minWidth: 300)
        #expect(defaultConfig != modified)
    }
}

// MARK: - ToastPresentation Model Tests

struct ToastPresentationModelTests {
    @Test func presentation_equality_withSameIdButDifferentProperties_notEqual() {
        let id = UUID()
        let a = ToastPresentation(id: id, state: .success("A"), duration: .automatic, timeout: 3)
        let b = ToastPresentation(id: id, state: .success("B"), duration: .persistent, timeout: nil)
        #expect(a != b)
    }

    @Test func presentation_equality_allPropertiesSame() {
        let id = UUID()
        let a = ToastPresentation(id: id, state: .success("X"), duration: .seconds(5), timeout: 5)
        let b = ToastPresentation(id: id, state: .success("X"), duration: .seconds(5), timeout: 5)
        #expect(a == b)
    }

    @Test func presentation_equality_differentIds() {
        let a = ToastPresentation(id: UUID(), state: .success("X"), duration: .automatic, timeout: 3)
        let b = ToastPresentation(id: UUID(), state: .success("X"), duration: .automatic, timeout: 3)
        #expect(a != b)
    }

    @Test func presentation_isPersistent_whenTimeoutNil() {
        let p = ToastPresentation(id: UUID(), state: .success("OK"), duration: .persistent, timeout: nil)
        #expect(p.isPersistent == true)
    }

    @Test func presentation_isNotPersistent_whenTimeoutNotNil() {
        let p = ToastPresentation(id: UUID(), state: .success("OK"), duration: .seconds(3), timeout: 3)
        #expect(p.isPersistent == false)
    }

    @Test func presentation_identifiable() {
        let id = UUID()
        let p = ToastPresentation(id: id, state: .success("X"), duration: .automatic, timeout: nil)
        #expect(p.id == id)
    }
}
