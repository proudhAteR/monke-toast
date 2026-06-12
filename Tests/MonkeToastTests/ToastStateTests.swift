import Testing
import SwiftUI
@testable import MonkeToast

struct ToastStateTests {
    // MARK: - Message

    @Test func message_loading() {
        #expect(ToastState.loading("Syncing").message == "Syncing")
    }

    @Test func message_error() {
        #expect(ToastState.error("Failed").message == "Failed")
    }

    @Test func message_success() {
        #expect(ToastState.success("Done").message == "Done")
    }

    @Test func message_info() {
        #expect(ToastState.info("Hello").message == "Hello")
    }

    @Test func message_warning() {
        #expect(ToastState.warning("Careful").message == "Careful")
    }

    @Test func message_custom() {
        let state = ToastState.custom(message: "Custom msg", systemImage: "star", tint: .blue)
        #expect(state.message == "Custom msg")
    }

    @Test func message_customMinimum() {
        let state = ToastState.custom(message: "Minimal")
        #expect(state.message == "Minimal")
    }

    @Test func message_empty() {
        #expect(ToastState.success("").message == "")
    }

    // MARK: - System Image

    @Test func systemImage_loading_isNil() {
        #expect(ToastState.loading("Work").systemImage == nil)
    }

    @Test func systemImage_error() {
        #expect(ToastState.error("Fail").systemImage == "xmark.octagon.fill")
    }

    @Test func systemImage_success() {
        #expect(ToastState.success("OK").systemImage == "checkmark.circle.fill")
    }

    @Test func systemImage_info() {
        #expect(ToastState.info("Info").systemImage == "info.circle.fill")
    }

    @Test func systemImage_warning() {
        #expect(ToastState.warning("Warn").systemImage == "exclamationmark.triangle.fill")
    }

    @Test func systemImage_custom_withImage() {
        let state = ToastState.custom(message: "Custom", systemImage: "sparkles")
        #expect(state.systemImage == "sparkles")
    }

    @Test func systemImage_custom_withoutImage_isNil() {
        let state = ToastState.custom(message: "Custom")
        #expect(state.systemImage == nil)
    }

    @Test func systemImage_custom_withNilImage_explicitly() {
        let state = ToastState.custom(message: "Custom", systemImage: nil)
        #expect(state.systemImage == nil)
    }

    // MARK: - Tint Color

    @Test func tint_loading() {
        #expect(ToastState.loading("Work").tint == .secondary)
    }

    @Test func tint_error() {
        #expect(ToastState.error("Fail").tint == .red)
    }

    @Test func tint_success() {
        #expect(ToastState.success("OK").tint == .green)
    }

    @Test func tint_info() {
        #expect(ToastState.info("Info").tint == .secondary)
    }

    @Test func tint_warning() {
        #expect(ToastState.warning("Warn").tint == .orange)
    }

    @Test func tint_custom_withCustomColor() {
        let state = ToastState.custom(message: "Custom", systemImage: "star", tint: .purple)
        #expect(state.tint == .purple)
    }

    @Test func tint_custom_defaultIsSecondary() {
        let state = ToastState.custom(message: "Custom")
        #expect(state.tint == .secondary)
    }

    // MARK: - Shows Progress

    @Test func showsProgress_loading_isTrue() {
        #expect(ToastState.loading("Work").showsProgress == true)
    }

    @Test func showsProgress_error_isFalse() {
        #expect(ToastState.error("Fail").showsProgress == false)
    }

    @Test func showsProgress_success_isFalse() {
        #expect(ToastState.success("OK").showsProgress == false)
    }

    @Test func showsProgress_info_isFalse() {
        #expect(ToastState.info("Info").showsProgress == false)
    }

    @Test func showsProgress_warning_isFalse() {
        #expect(ToastState.warning("Warn").showsProgress == false)
    }

    @Test func showsProgress_custom_withProgress_isTrue() {
        let state = ToastState.custom(message: "Work", showsProgress: true)
        #expect(state.showsProgress == true)
    }

    @Test func showsProgress_custom_withoutProgress_isFalse() {
        let state = ToastState.custom(message: "Done", showsProgress: false)
        #expect(state.showsProgress == false)
    }

    @Test func showsProgress_custom_defaultIsFalse() {
        let state = ToastState.custom(message: "Default")
        #expect(state.showsProgress == false)
    }

    // MARK: - Is Loading

    @Test func isLoading_loading_isTrue() {
        #expect(ToastState.loading("Work").isLoading == true)
    }

    @Test func isLoading_error_isFalse() {
        #expect(ToastState.error("Fail").isLoading == false)
    }

    @Test func isLoading_success_isFalse() {
        #expect(ToastState.success("OK").isLoading == false)
    }

    @Test func isLoading_info_isFalse() {
        #expect(ToastState.info("Info").isLoading == false)
    }

    @Test func isLoading_warning_isFalse() {
        #expect(ToastState.warning("Warn").isLoading == false)
    }

    @Test func isLoading_customWithoutProgress_isFalse() {
        let state = ToastState.custom(message: "Custom")
        #expect(state.isLoading == false)
    }

    @Test func isLoading_customWithProgress_isFalse() {
        let state = ToastState.custom(message: "Custom", showsProgress: true)
        #expect(state.isLoading == false)
    }

    // MARK: - Accessibility Label

    @Test func accessibilityLabel_loading() {
        #expect(ToastState.loading("Fetching").accessibilityLabel == "Loading: Fetching")
    }

    @Test func accessibilityLabel_error() {
        #expect(ToastState.error("Timeout").accessibilityLabel == "Error: Timeout")
    }

    @Test func accessibilityLabel_success() {
        #expect(ToastState.success("Saved").accessibilityLabel == "Success: Saved")
    }

    @Test func accessibilityLabel_info() {
        #expect(ToastState.info("Online").accessibilityLabel == "Info: Online")
    }

    @Test func accessibilityLabel_warning() {
        #expect(ToastState.warning("Low").accessibilityLabel == "Warning: Low")
    }

    @Test func accessibilityLabel_custom() {
        let state = ToastState.custom(message: "Action done")
        #expect(state.accessibilityLabel == "Message: Action done")
    }

    // MARK: - Equatable

    @Test func sameLoadingStates_areEqual() {
        #expect(ToastState.loading("A") == ToastState.loading("A"))
    }

    @Test func sameErrorStates_areEqual() {
        #expect(ToastState.error("X") == ToastState.error("X"))
    }

    @Test func sameSuccessStates_areEqual() {
        #expect(ToastState.success("Y") == ToastState.success("Y"))
    }

    @Test func differentMessages_areNotEqual() {
        #expect(ToastState.success("A") != ToastState.success("B"))
    }

    @Test func differentCases_areNotEqual() {
        #expect(ToastState.success("Msg") != ToastState.error("Msg"))
    }

    @Test func customStates_withSameValues_areEqual() {
        let a = ToastState.custom(message: "Hi", systemImage: "star", tint: .blue, showsProgress: false)
        let b = ToastState.custom(message: "Hi", systemImage: "star", tint: .blue, showsProgress: false)
        #expect(a == b)
    }

    @Test func customStates_withDifferentTints_areNotEqual() {
        let a = ToastState.custom(message: "Hi", tint: .blue)
        let b = ToastState.custom(message: "Hi", tint: .red)
        #expect(a != b)
    }

    @Test func customStates_withDifferentProgress_areNotEqual() {
        let a = ToastState.custom(message: "Hi", showsProgress: true)
        let b = ToastState.custom(message: "Hi", showsProgress: false)
        #expect(a != b)
    }

    @Test func customStates_withDifferentImages_areNotEqual() {
        let a = ToastState.custom(message: "Hi", systemImage: "star")
        let b = ToastState.custom(message: "Hi", systemImage: "moon")
        #expect(a != b)
    }
}
