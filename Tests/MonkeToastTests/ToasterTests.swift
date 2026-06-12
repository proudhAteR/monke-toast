import Testing
import SwiftUI
@testable import MonkeToast

@MainActor
struct ToasterTests {
    let toaster = Toaster()


    // MARK: - Show

    @Test func show_addsToastToGlobalSlot() {
        toaster.success("Saved")
        let toast = toaster.toast(for: .global)
        #expect(toast != nil)
        #expect(toast?.state == .success("Saved"))
    }

    @Test func show_withExplicitGlobalKey() {
        toaster.info("Hello", for: .global)
        let toast = toaster.toast(for: .global)
        #expect(toast?.state == .info("Hello"))
    }

    @Test func show_withNamedKey() {
        toaster.error("Fail", for: ToastKey.screen("login"))
        #expect(toaster.toast(for: .global) == nil)
        let toast = toaster.toast(for: ToastKey.screen("login"))
        #expect(toast?.state == .error("Fail"))
    }

    @Test func show_withStringKey() {
        toaster.warning("Careful", for: "dashboard")
        let toast = toaster.toast(for: "dashboard")
        #expect(toast?.state == .warning("Careful"))
    }

    // MARK: - Convenience Helpers

    @Test func convenienceHelpers_showStandardStates() {
        toaster.loading("Uploading")
        #expect(toaster.toast(for: .global)?.state == .loading("Uploading"))
        #expect(toaster.toast(for: .global)?.isPersistent == true)

        toaster.success("Saved")
        #expect(toaster.toast(for: .global)?.state == .success("Saved"))
        #expect(toaster.toast(for: .global)?.timeout == 3)

        toaster.error("Failed")
        #expect(toaster.toast(for: .global)?.state == .error("Failed"))

        toaster.info("Ready")
        #expect(toaster.toast(for: .global)?.state == .info("Ready"))

        toaster.warning("Careful")
        #expect(toaster.toast(for: .global)?.state == .warning("Careful"))
    }

    @Test func convenienceHelpers_respectKeysAndDurations() {
        toaster.error("Login failed", for: ToastKey.screen("login"), duration: .seconds(7))
        #expect(toaster.toast(for: ToastKey.screen("login"))?.state == .error("Login failed"))
        #expect(toaster.toast(for: ToastKey.screen("login"))?.timeout == 7)

        let dashboardKey = "dashboard"
        toaster.info("Ready", for: dashboardKey, duration: .persistent)
        #expect(toaster.toast(for: dashboardKey)?.state == .info("Ready"))
        #expect(toaster.toast(for: dashboardKey)?.isPersistent == true)
    }

    @Test func customConvenienceHelper_buildsCustomState() {
        toaster.custom(
            "Action completed",
            systemImage: "sparkles",
            tint: .purple,
            showsProgress: true,
            duration: .persistent
        )

        let toast = toaster.toast(for: .global)
        #expect(toast?.state == .custom(
            message: "Action completed",
            systemImage: "sparkles",
            tint: .purple,
            showsProgress: true
        ))
        #expect(toast?.state.systemImage == "sparkles")
        #expect(toast?.state.tint == .purple)
        #expect(toast?.state.showsProgress == true)
        #expect(toast?.isPersistent == true)
    }

    // MARK: - Replacement

    @Test func show_replacesExistingToastForSameKey() {
        toaster.success("First")
        let firstId = toaster.toast(for: .global)?.id

        toaster.success("Second")
        let secondId = toaster.toast(for: .global)?.id

        #expect(firstId != secondId)
        #expect(toaster.toast(for: .global)?.state == .success("Second"))
    }

    @Test func show_doesNotAffectOtherKeys() {
        toaster.success("Global", for: .global)
        toaster.info("Screen", for: ToastKey.screen("profile"))

        #expect(toaster.toast(for: .global)?.state == .success("Global"))
        #expect(toaster.toast(for: ToastKey.screen("profile"))?.state == .info("Screen"))
    }

    // MARK: - Duration Resolution

    @Test func show_withAutomatic_onNonLoading_setsTimeoutToDefault() {
        toaster.success("OK")
        #expect(toaster.toast(for: .global)?.timeout == 3)
        #expect(toaster.toast(for: .global)?.isPersistent == false)
    }

    @Test func show_withAutomatic_onLoading_noTimeout() {
        toaster.loading("Work", duration: .automatic)
        #expect(toaster.toast(for: .global)?.timeout == nil)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func show_withSeconds_setsSpecifiedTimeout() {
        toaster.success("OK", duration: .seconds(5))
        #expect(toaster.toast(for: .global)?.timeout == 5)
    }

    @Test func show_withPersistent_noTimeout() {
        toaster.success("OK", duration: .persistent)
        #expect(toaster.toast(for: .global)?.timeout == nil)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func show_withZeroSeconds_noTimeout() {
        toaster.error("Fail", duration: .seconds(0))
        #expect(toaster.toast(for: .global)?.timeout == nil)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func show_withNegativeSeconds_noTimeout() {
        toaster.info("Test", duration: .seconds(-3))
        #expect(toaster.toast(for: .global)?.timeout == nil)
    }

    // MARK: - Toast(for:) Inspections

    @Test func toastForKey_withNoToast_returnsNil() {
        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: "nonexistent") == nil)
    }

    @Test func toastForKey_withStringKey() {
        toaster.warning("Test", for: "alerts")
        let toast = toaster.toast(for: "alerts")
        #expect(toast?.state == .warning("Test"))
    }

    @Test func toastForKey_withDifferentKeys_returnsCorrect() {
        toaster.error("E1", for: .global)
        toaster.info("I1", for: ToastKey.screen("settings"))

        #expect(toaster.toast(for: .global)?.state == .error("E1"))
        #expect(toaster.toast(for: ToastKey.screen("settings"))?.state == .info("I1"))
    }

    // MARK: - Clear

    @Test func clear_removesGlobalToast() {
        toaster.success("Saved")
        toaster.clear()
        #expect(toaster.toast(for: .global) == nil)
    }

    @Test func clear_removesSpecificKey() {
        toaster.error("Fail", for: ToastKey.screen("login"))
        toaster.clear(ToastKey.screen("login"))
        #expect(toaster.toast(for: ToastKey.screen("login")) == nil)
    }

    @Test func clear_doesNotAffectOtherKeys() {
        toaster.success("A", for: .global)
        toaster.info("B", for: ToastKey.screen("other"))

        toaster.clear(.global)

        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: ToastKey.screen("other")) != nil)
    }

    @Test func clear_withStringKey() {
        toaster.warning("Warn", for: "alerts")
        toaster.clear("alerts")
        #expect(toaster.toast(for: "alerts") == nil)
    }

    @Test func clear_onEmptySlot_doesNothing() {
        toaster.clear()
        toaster.clear(ToastKey.screen("nonexistent"))
        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: ToastKey.screen("nonexistent")) == nil)
    }

    // MARK: - Clear All

    @Test func clearAll_removesAllToasts() {
        toaster.success("A", for: .global)
        toaster.info("B", for: ToastKey.screen("s1"))
        toaster.error("C", for: ToastKey.screen("s2"))

        toaster.clearAll()

        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: ToastKey.screen("s1")) == nil)
        #expect(toaster.toast(for: ToastKey.screen("s2")) == nil)
    }

    @Test func clearAll_afterSingleToast() {
        toaster.success("Only")
        toaster.clearAll()
        #expect(toaster.toast(for: .global) == nil)
    }

    @Test func clearAll_whenEmpty_doesNothing() {
        toaster.clearAll()
        toaster.clearAll()
        #expect(toaster.toast(for: .global) == nil)
    }

    // MARK: - Dismissal Cancellation on Replace

    @Test func replacingToast_cancelsPreviousDismissal() {
        toaster.success("First", duration: .seconds(0.1))
        let firstId = toaster.toast(for: .global)?.id

        toaster.success("Second", duration: .persistent)
        let secondId = toaster.toast(for: .global)?.id

        #expect(firstId != secondId)
        #expect(toaster.toast(for: .global)?.id == secondId)
    }

    @Test func showAndClear_resetsState() {
        toaster.success("Temp")
        toaster.clear()
        #expect(toaster.toast(for: .global) == nil)

        toaster.error("New")
        #expect(toaster.toast(for: .global)?.state == .error("New"))
    }

    // MARK: - ToastPresentation Properties

    @Test func presentation_id_isUnique() {
        toaster.success("A")
        let idA = toaster.toast(for: .global)?.id

        toaster.clear()
        toaster.success("B")
        let idB = toaster.toast(for: .global)?.id

        #expect(idA != idB)
    }

    @Test func presentation_isPersistent_whenTimeoutIsNil() {
        toaster.loading("Work", duration: .persistent)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func presentation_isNotPersistent_whenTimeoutIsSet() {
        toaster.success("Fast", duration: .seconds(2))
        #expect(toaster.toast(for: .global)?.isPersistent == false)
    }

    // MARK: - Simultaneous Independent Keys

    @Test func multipleKeys_canHoldDifferentStates() {
        toaster.loading("Upload", for: ToastKey.screen("upload"), duration: .persistent)
        toaster.success("Profile", for: ToastKey.screen("profile"))
        toaster.error("Network", for: ToastKey.screen("network"), duration: .seconds(8))

        #expect(toaster.toast(for: ToastKey.screen("upload"))?.state == .loading("Upload"))
        #expect(toaster.toast(for: ToastKey.screen("upload"))?.isPersistent == true)

        #expect(toaster.toast(for: ToastKey.screen("profile"))?.state == .success("Profile"))
        #expect(toaster.toast(for: ToastKey.screen("profile"))?.isPersistent == false)

        #expect(toaster.toast(for: ToastKey.screen("network"))?.state == .error("Network"))
        #expect(toaster.toast(for: ToastKey.screen("network"))?.timeout == 8)
    }

    // MARK: - Show-Clear-Show Cycle

    @Test func showClearShow_worksCorrectly() {
        toaster.success("First")
        #expect(toaster.toast(for: .global) != nil)

        toaster.clear()
        #expect(toaster.toast(for: .global) == nil)

        toaster.error("Second")
        #expect(toaster.toast(for: .global)?.state == .error("Second"))
    }

    @Test func multipleShowClearCycles() {
        for i in 1...5 {
            toaster.info("Cycle \(i)")
            #expect(toaster.toast(for: .global)?.state == .info("Cycle \(i)"))
            toaster.clear()
            #expect(toaster.toast(for: .global) == nil)
        }
    }

    // MARK: - Default Key

    @Test func show_withoutKey_usesGlobal() {
        toaster.warning("Default key")
        #expect(toaster.toast(for: .global)?.state == .warning("Default key"))
    }

    @Test func clear_withoutKey_clearsGlobal() {
        toaster.success("To clear")
        toaster.clear()
        #expect(toaster.toast(for: .global) == nil)
    }

    // MARK: - Integration: Full Lifecycle

    @Test func fullLifecycle_showReplaceClear() {
        toaster.loading("Saving...", for: ToastKey.screen("editor"), duration: .persistent)
        var toast = toaster.toast(for: ToastKey.screen("editor"))
        #expect(toast?.state == .loading("Saving..."))
        #expect(toast?.isPersistent == true)
        #expect(toast?.state.showsProgress == true)
        #expect(toast?.state.isLoading == true)
        #expect(toast?.state.systemImage == nil)

        toaster.success("Saved!", for: ToastKey.screen("editor"), duration: .automatic)
        toast = toaster.toast(for: ToastKey.screen("editor"))
        #expect(toast?.state == .success("Saved!"))
        #expect(toast?.isPersistent == false)
        #expect(toast?.timeout == 3)
        #expect(toast?.state.showsProgress == false)
        #expect(toast?.state.isLoading == false)
        #expect(toast?.state.systemImage == "checkmark.circle.fill")
        #expect(toast?.state.tint == .green)

        toaster.clear(ToastKey.screen("editor"))
        #expect(toaster.toast(for: ToastKey.screen("editor")) == nil)
    }

    @Test func multipleScreens_independentToasts() {
        toaster.info("Welcome", for: .global)
        toaster.loading("Fetching feed", for: ToastKey.screen("feed"), duration: .persistent)
        toaster.success("Profile loaded", for: ToastKey.screen("profile"))

        #expect(toaster.toast(for: .global)?.state == .info("Welcome"))
        #expect(toaster.toast(for: ToastKey.screen("feed"))?.state == .loading("Fetching feed"))
        #expect(toaster.toast(for: ToastKey.screen("profile"))?.state == .success("Profile loaded"))

        toaster.clear(ToastKey.screen("feed"))
        #expect(toaster.toast(for: ToastKey.screen("feed")) == nil)
        #expect(toaster.toast(for: .global) != nil)
        #expect(toaster.toast(for: ToastKey.screen("profile")) != nil)
    }

    @Test func tabAndScreen_isolation() {
        toaster.info("Tab update", for: .tab("home"))
        toaster.warning("Screen issue", for: .screen("details"))

        #expect(toaster.toast(for: .tab("home"))?.state == .info("Tab update"))
        #expect(toaster.toast(for: .screen("details"))?.state == .warning("Screen issue"))
        #expect(toaster.toast(for: .global) == nil)
    }

    @Test func persistentToast_survivesThroughAutomaticToastsOnOtherKeys() {
        toaster.loading("Background sync", for: .global, duration: .persistent)
        toaster.success("One-off task done", for: ToastKey.screen("task"), duration: .automatic)
        toaster.clear(ToastKey.screen("task"))

        #expect(toaster.toast(for: .global)?.state == .loading("Background sync"))
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func clearAll_resetsEntireApp() {
        toaster.success("A", for: .global)
        toaster.error("B", for: .screen("s1"))
        toaster.warning("C", for: .tab("t1"))

        toaster.clearAll()

        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: .screen("s1")) == nil)
        #expect(toaster.toast(for: .tab("t1")) == nil)
    }

    // MARK: - Integration: State Transitions

    @Test func stateTransition_loadingToError() {
        toaster.loading("Uploading photo", duration: .persistent)
        #expect(toaster.toast(for: .global)?.state.showsProgress == true)

        toaster.error("Upload failed", duration: .seconds(8))
        let errorToast = toaster.toast(for: .global)
        #expect(errorToast?.state == .error("Upload failed"))
        #expect(errorToast?.state.showsProgress == false)
        #expect(errorToast?.timeout == 8)
        #expect(errorToast?.state.tint == .red)
        #expect(errorToast?.state.systemImage == "xmark.octagon.fill")
    }

    @Test func stateTransition_loadingToSuccess() {
        toaster.loading("Processing", duration: .persistent)
        #expect(toaster.toast(for: .global)?.isPersistent == true)

        toaster.success("Done", duration: .automatic)
        let successToast = toaster.toast(for: .global)
        #expect(successToast?.state == .success("Done"))
        #expect(successToast?.isPersistent == false)
        #expect(successToast?.timeout == 3)
    }

    // MARK: - Integration: Accessibility

    @Test func accessibilityLabel_chain() {
        toaster.loading("Upload")
        #expect(toaster.toast(for: .global)?.state.accessibilityLabel == "Loading: Upload")

        toaster.error("Failed to connect")
        #expect(toaster.toast(for: .global)?.state.accessibilityLabel == "Error: Failed to connect")

        toaster.success("All good")
        #expect(toaster.toast(for: .global)?.state.accessibilityLabel == "Success: All good")
    }

    // MARK: - Integration: Edge Cases

    @Test func showEmptyMessage() {
        toaster.success("")
        #expect(toaster.toast(for: .global)?.state.message == "")
    }

    @Test func showVeryLongMessage() {
        let long = String(repeating: "A", count: 500)
        toaster.info(long)
        #expect(toaster.toast(for: .global)?.state.message == long)
    }

    @Test func clearNonexistentKey_thenShow() {
        toaster.clear(ToastKey.screen("never-shown"))
        toaster.success("Now visible")
        #expect(toaster.toast(for: .global)?.state == .success("Now visible"))
    }

    // MARK: - Integration: String Literal Keys

    @Test func showWithStringLiteral() {
        toaster.warning("Be careful", for: "warnings")
        #expect(toaster.toast(for: "warnings")?.state == .warning("Be careful"))
    }

    @Test func clearWithStringLiteral() {
        toaster.info("Temp", for: "temp-slot")
        toaster.clear("temp-slot")
        #expect(toaster.toast(for: "temp-slot") == nil)
    }

    // MARK: - Integration: Auto-Dismissal

    @Test func autoDismiss_removesToastAfterTimeout() async {
        toaster.success("Auto", duration: .seconds(0.05))
        #expect(toaster.toast(for: .global) != nil)
        try? await Task.sleep(nanoseconds: 150_000_000)
        #expect(toaster.toast(for: .global) == nil)
    }

    @Test func autoDismiss_multipleToasts_dismissIndependently() async {
        toaster.success("Fast", for: .global, duration: .seconds(0.05))
        toaster.info("Slow", for: ToastKey.screen("slow"), duration: .seconds(10))

        try? await Task.sleep(nanoseconds: 150_000_000)

        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: ToastKey.screen("slow")) != nil)
    }

    @Test func autoDismiss_replacedToast_doesNotDismissReplacement() async {
        toaster.success("First", duration: .seconds(0.1))
        try? await Task.sleep(nanoseconds: 50_000_000)
        toaster.success("Second", duration: .persistent)
        try? await Task.sleep(nanoseconds: 100_000_000)
        #expect(toaster.toast(for: .global)?.state == .success("Second"))
    }

    @Test func autoDismiss_loadingWithAutomatic_persists() async {
        toaster.loading("Working", duration: .automatic)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
        try? await Task.sleep(nanoseconds: 200_000_000)
        #expect(toaster.toast(for: .global) != nil)
    }
}
