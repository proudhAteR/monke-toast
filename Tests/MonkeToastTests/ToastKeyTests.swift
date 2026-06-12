import Testing
@testable import MonkeToast

struct ToastKeyTests {
    // MARK: - Static Keys

    @Test func globalKey() {
        let key = ToastKey.global
        #expect(key.rawValue == "global:toasts")
    }

    @Test func mainKey() {
        let key = ToastKey.main
        #expect(key.rawValue == "main:toasts")
    }

    // MARK: - Screen Key

    @Test func screenKey_withName_returnsNamespacedKey() {
        let key = ToastKey.screen("profile")
        #expect(key.rawValue == "profile:toasts")
    }

    @Test func screenKey_withEmptyName() {
        let key = ToastKey.screen("")
        #expect(key.rawValue == ":toasts")
    }

    @Test func screenKey_withSpecialCharacters() {
        let key = ToastKey.screen("user-details/2")
        #expect(key.rawValue == "user-details/2:toasts")
    }

    // MARK: - Tab Key

    @Test func tabKey_withName_returnsNamespacedKey() {
        let key = ToastKey.tab("settings")
        #expect(key.rawValue == "settings:tab:toasts")
    }

    @Test func tabKey_withEmptyName() {
        let key = ToastKey.tab("")
        #expect(key.rawValue == ":tab:toasts")
    }

    // MARK: - RawRepresentable

    @Test func rawRepresentable_roundTrip() {
        let original = ToastKey(rawValue: "test:toasts")
        #expect(original.rawValue == "test:toasts")
        let reconstructed = ToastKey(rawValue: original.rawValue)
        #expect(reconstructed == original)
    }

    @Test func rawRepresentable_withEmptyValue() {
        let key = ToastKey(rawValue: "")
        #expect(key.rawValue == "")
    }

    // MARK: - String Literal

    @Test func stringLiteral_createsKey() {
        let key: ToastKey = "dashboard"
        #expect(key.rawValue == "dashboard")
    }

    @Test func stringLiteral_usedInShowCall() {
        let key = ToastKey("dashboard")
        #expect(key.rawValue == "dashboard")
    }

    // MARK: - Hashable

    @Test func keysWithSameRawValue_areEqual() {
        let a = ToastKey(rawValue: "test")
        let b = ToastKey(rawValue: "test")
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }

    @Test func keysWithDifferentRawValues_areNotEqual() {
        let a = ToastKey(rawValue: "alpha")
        let b = ToastKey(rawValue: "beta")
        #expect(a != b)
    }

    @Test func key_canBeUsedAsDictionaryKey() {
        var dict: [ToastKey: String] = [:]
        dict[.global] = "global-toast"
        dict[.main] = "main-toast"
        #expect(dict[.global] == "global-toast")
        #expect(dict[.main] == "main-toast")
        #expect(dict[ToastKey.screen("other")] == nil)
    }

    // MARK: - Sendable

    @Test func key_isSendable() {
        let key = ToastKey.global
        let value = key.rawValue
        #expect(value == "global:toasts")
    }

    // MARK: - CustomStringConvertible

    @Test func description_returnsRawValue() {
        let key = ToastKey.screen("profile")
        #expect(key.description == "profile:toasts")
    }

    @Test func description_global() {
        #expect(ToastKey.global.description == "global:toasts")
    }

    @Test func nested_screenAndTabAreDistinct() {
        let screen = ToastKey.screen("home")
        let tab = ToastKey.tab("home")
        #expect(screen != tab)
        #expect(screen.rawValue == "home:toasts")
        #expect(tab.rawValue == "home:tab:toasts")
    }
}
