import Testing
@testable import MonkeToast

@MainActor
struct ToasterTests {
    let toaster = Toaster()


    // MARK: - Show

    @Test func show_addsToastToGlobalSlot() {
        toaster.show(.success("Saved"))
        let toast = toaster.toast(for: .global)
        #expect(toast != nil)
        #expect(toast?.state == .success("Saved"))
    }

    @Test func show_withExplicitGlobalKey() {
        toaster.show(.info("Hello"), for: .global)
        let toast = toaster.toast(for: .global)
        #expect(toast?.state == .info("Hello"))
    }

    @Test func show_withNamedKey() {
        toaster.show(.error("Fail"), for: ToastKey.screen("login"))
        #expect(toaster.toast(for: .global) == nil)
        let toast = toaster.toast(for: ToastKey.screen("login"))
        #expect(toast?.state == .error("Fail"))
    }

    @Test func show_withStringKey() {
        toaster.show(.warning("Careful"), for: "dashboard")
        let toast = toaster.toast(for: "dashboard")
        #expect(toast?.state == .warning("Careful"))
    }

    // MARK: - Replacement

    @Test func show_replacesExistingToastForSameKey() {
        toaster.show(.success("First"))
        let firstId = toaster.toast(for: .global)?.id

        toaster.show(.success("Second"))
        let secondId = toaster.toast(for: .global)?.id

        #expect(firstId != secondId)
        #expect(toaster.toast(for: .global)?.state == .success("Second"))
    }

    @Test func show_doesNotAffectOtherKeys() {
        toaster.show(.success("Global"), for: .global)
        toaster.show(.info("Screen"), for: ToastKey.screen("profile"))

        #expect(toaster.toast(for: .global)?.state == .success("Global"))
        #expect(toaster.toast(for: ToastKey.screen("profile"))?.state == .info("Screen"))
    }

    // MARK: - Duration Resolution

    @Test func show_withAutomatic_onNonLoading_setsTimeoutToDefault() {
        toaster.show(.success("OK"))
        #expect(toaster.toast(for: .global)?.timeout == 3)
        #expect(toaster.toast(for: .global)?.isPersistent == false)
    }

    @Test func show_withAutomatic_onLoading_noTimeout() {
        toaster.show(.loading("Work"), duration: .automatic)
        #expect(toaster.toast(for: .global)?.timeout == nil)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func show_withSeconds_setsSpecifiedTimeout() {
        toaster.show(.success("OK"), duration: .seconds(5))
        #expect(toaster.toast(for: .global)?.timeout == 5)
    }

    @Test func show_withPersistent_noTimeout() {
        toaster.show(.success("OK"), duration: .persistent)
        #expect(toaster.toast(for: .global)?.timeout == nil)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func show_withZeroSeconds_noTimeout() {
        toaster.show(.error("Fail"), duration: .seconds(0))
        #expect(toaster.toast(for: .global)?.timeout == nil)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func show_withNegativeSeconds_noTimeout() {
        toaster.show(.info("Test"), duration: .seconds(-3))
        #expect(toaster.toast(for: .global)?.timeout == nil)
    }

    // MARK: - Scale.io Compatibility Overload

    @Test func show_compatibilityPersistTrue() {
        toaster.show(.loading("Sync"), ToastKey.screen("files"), persist: true)
        #expect(toaster.toast(for: ToastKey.screen("files"))?.isPersistent == true)
    }

    @Test func show_compatibilityPersistFalse() {
        toaster.show(.success("Done"), ToastKey.screen("files"), persist: false, timeout: 4)
        let toast = toaster.toast(for: ToastKey.screen("files"))
        #expect(toast?.timeout == 4)
        #expect(toast?.isPersistent == false)
    }

    @Test func show_compatibilityStringKey() {
        toaster.show(.info("Test"), "legacy", persist: false, timeout: 2)
        let toast = toaster.toast(for: "legacy")
        #expect(toast?.timeout == 2)
    }

    // MARK: - Toast(for:) Inspections

    @Test func toastForKey_withNoToast_returnsNil() {
        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: "nonexistent") == nil)
    }

    @Test func toastForKey_withStringKey() {
        toaster.show(.warning("Test"), for: "alerts")
        let toast = toaster.toast(for: "alerts")
        #expect(toast?.state == .warning("Test"))
    }

    @Test func toastForKey_withDifferentKeys_returnsCorrect() {
        toaster.show(.error("E1"), for: .global)
        toaster.show(.info("I1"), for: ToastKey.screen("settings"))

        #expect(toaster.toast(for: .global)?.state == .error("E1"))
        #expect(toaster.toast(for: ToastKey.screen("settings"))?.state == .info("I1"))
    }

    // MARK: - Clear

    @Test func clear_removesGlobalToast() {
        toaster.show(.success("Saved"))
        toaster.clear()
        #expect(toaster.toast(for: .global) == nil)
    }

    @Test func clear_removesSpecificKey() {
        toaster.show(.error("Fail"), for: ToastKey.screen("login"))
        toaster.clear(ToastKey.screen("login"))
        #expect(toaster.toast(for: ToastKey.screen("login")) == nil)
    }

    @Test func clear_doesNotAffectOtherKeys() {
        toaster.show(.success("A"), for: .global)
        toaster.show(.info("B"), for: ToastKey.screen("other"))

        toaster.clear(.global)

        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: ToastKey.screen("other")) != nil)
    }

    @Test func clear_withStringKey() {
        toaster.show(.warning("Warn"), for: "alerts")
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
        toaster.show(.success("A"), for: .global)
        toaster.show(.info("B"), for: ToastKey.screen("s1"))
        toaster.show(.error("C"), for: ToastKey.screen("s2"))

        toaster.clearAll()

        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: ToastKey.screen("s1")) == nil)
        #expect(toaster.toast(for: ToastKey.screen("s2")) == nil)
    }

    @Test func clearAll_afterSingleToast() {
        toaster.show(.success("Only"))
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
        toaster.show(.success("First"), duration: .seconds(0.1))
        let firstId = toaster.toast(for: .global)?.id

        toaster.show(.success("Second"), duration: .persistent)
        let secondId = toaster.toast(for: .global)?.id

        #expect(firstId != secondId)
        #expect(toaster.toast(for: .global)?.id == secondId)
    }

    @Test func showAndClear_resetsState() {
        toaster.show(.success("Temp"))
        toaster.clear()
        #expect(toaster.toast(for: .global) == nil)

        toaster.show(.error("New"))
        #expect(toaster.toast(for: .global)?.state == .error("New"))
    }

    // MARK: - ToastPresentation Properties

    @Test func presentation_id_isUnique() {
        toaster.show(.success("A"))
        let idA = toaster.toast(for: .global)?.id

        toaster.clear()
        toaster.show(.success("B"))
        let idB = toaster.toast(for: .global)?.id

        #expect(idA != idB)
    }

    @Test func presentation_isPersistent_whenTimeoutIsNil() {
        toaster.show(.loading("Work"), duration: .persistent)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func presentation_isNotPersistent_whenTimeoutIsSet() {
        toaster.show(.success("Fast"), duration: .seconds(2))
        #expect(toaster.toast(for: .global)?.isPersistent == false)
    }

    // MARK: - Simultaneous Independent Keys

    @Test func multipleKeys_canHoldDifferentStates() {
        toaster.show(.loading("Upload"), for: ToastKey.screen("upload"), duration: .persistent)
        toaster.show(.success("Profile"), for: ToastKey.screen("profile"))
        toaster.show(.error("Network"), for: ToastKey.screen("network"), duration: .seconds(8))

        #expect(toaster.toast(for: ToastKey.screen("upload"))?.state == .loading("Upload"))
        #expect(toaster.toast(for: ToastKey.screen("upload"))?.isPersistent == true)

        #expect(toaster.toast(for: ToastKey.screen("profile"))?.state == .success("Profile"))
        #expect(toaster.toast(for: ToastKey.screen("profile"))?.isPersistent == false)

        #expect(toaster.toast(for: ToastKey.screen("network"))?.state == .error("Network"))
        #expect(toaster.toast(for: ToastKey.screen("network"))?.timeout == 8)
    }

    // MARK: - Show-Clear-Show Cycle

    @Test func showClearShow_worksCorrectly() {
        toaster.show(.success("First"))
        #expect(toaster.toast(for: .global) != nil)

        toaster.clear()
        #expect(toaster.toast(for: .global) == nil)

        toaster.show(.error("Second"))
        #expect(toaster.toast(for: .global)?.state == .error("Second"))
    }

    @Test func multipleShowClearCycles() {
        for i in 1...5 {
            toaster.show(.info("Cycle \(i)"))
            #expect(toaster.toast(for: .global)?.state == .info("Cycle \(i)"))
            toaster.clear()
            #expect(toaster.toast(for: .global) == nil)
        }
    }

    // MARK: - Default Key

    @Test func show_withoutKey_usesGlobal() {
        toaster.show(.warning("Default key"))
        #expect(toaster.toast(for: .global)?.state == .warning("Default key"))
    }

    @Test func clear_withoutKey_clearsGlobal() {
        toaster.show(.success("To clear"))
        toaster.clear()
        #expect(toaster.toast(for: .global) == nil)
    }

    // MARK: - Integration: Full Lifecycle

    @Test func fullLifecycle_showReplaceClear() {
        toaster.show(.loading("Saving..."), for: ToastKey.screen("editor"), duration: .persistent)
        var toast = toaster.toast(for: ToastKey.screen("editor"))
        #expect(toast?.state == .loading("Saving..."))
        #expect(toast?.isPersistent == true)
        #expect(toast?.state.showsProgress == true)
        #expect(toast?.state.isLoading == true)
        #expect(toast?.state.systemImage == nil)

        toaster.show(.success("Saved!"), for: ToastKey.screen("editor"), duration: .automatic)
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
        toaster.show(.info("Welcome"), for: .global)
        toaster.show(.loading("Fetching feed"), for: ToastKey.screen("feed"), duration: .persistent)
        toaster.show(.success("Profile loaded"), for: ToastKey.screen("profile"))

        #expect(toaster.toast(for: .global)?.state == .info("Welcome"))
        #expect(toaster.toast(for: ToastKey.screen("feed"))?.state == .loading("Fetching feed"))
        #expect(toaster.toast(for: ToastKey.screen("profile"))?.state == .success("Profile loaded"))

        toaster.clear(ToastKey.screen("feed"))
        #expect(toaster.toast(for: ToastKey.screen("feed")) == nil)
        #expect(toaster.toast(for: .global) != nil)
        #expect(toaster.toast(for: ToastKey.screen("profile")) != nil)
    }

    @Test func tabAndScreen_isolation() {
        toaster.show(.info("Tab update"), for: .tab("home"))
        toaster.show(.warning("Screen issue"), for: .screen("details"))

        #expect(toaster.toast(for: .tab("home"))?.state == .info("Tab update"))
        #expect(toaster.toast(for: .screen("details"))?.state == .warning("Screen issue"))
        #expect(toaster.toast(for: .global) == nil)
    }

    @Test func persistentToast_survivesThroughAutomaticToastsOnOtherKeys() {
        toaster.show(.loading("Background sync"), for: .global, duration: .persistent)
        toaster.show(.success("One-off task done"), for: ToastKey.screen("task"), duration: .automatic)
        toaster.clear(ToastKey.screen("task"))

        #expect(toaster.toast(for: .global)?.state == .loading("Background sync"))
        #expect(toaster.toast(for: .global)?.isPersistent == true)
    }

    @Test func clearAll_resetsEntireApp() {
        toaster.show(.success("A"), for: .global)
        toaster.show(.error("B"), for: .screen("s1"))
        toaster.show(.warning("C"), for: .tab("t1"))

        toaster.clearAll()

        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: .screen("s1")) == nil)
        #expect(toaster.toast(for: .tab("t1")) == nil)
    }

    // MARK: - Integration: State Transitions

    @Test func stateTransition_loadingToError() {
        toaster.show(.loading("Uploading photo"), duration: .persistent)
        #expect(toaster.toast(for: .global)?.state.showsProgress == true)

        toaster.show(.error("Upload failed"), duration: .seconds(8))
        let errorToast = toaster.toast(for: .global)
        #expect(errorToast?.state == .error("Upload failed"))
        #expect(errorToast?.state.showsProgress == false)
        #expect(errorToast?.timeout == 8)
        #expect(errorToast?.state.tint == .red)
        #expect(errorToast?.state.systemImage == "xmark.octagon.fill")
    }

    @Test func stateTransition_loadingToSuccess() {
        toaster.show(.loading("Processing"), duration: .persistent)
        #expect(toaster.toast(for: .global)?.isPersistent == true)

        toaster.show(.success("Done"), duration: .automatic)
        let successToast = toaster.toast(for: .global)
        #expect(successToast?.state == .success("Done"))
        #expect(successToast?.isPersistent == false)
        #expect(successToast?.timeout == 3)
    }

    // MARK: - Integration: Accessibility

    @Test func accessibilityLabel_chain() {
        toaster.show(.loading("Upload"))
        #expect(toaster.toast(for: .global)?.state.accessibilityLabel == "Loading: Upload")

        toaster.show(.error("Failed to connect"))
        #expect(toaster.toast(for: .global)?.state.accessibilityLabel == "Error: Failed to connect")

        toaster.show(.success("All good"))
        #expect(toaster.toast(for: .global)?.state.accessibilityLabel == "Success: All good")
    }

    // MARK: - Integration: Edge Cases

    @Test func showEmptyMessage() {
        toaster.show(.success(""))
        #expect(toaster.toast(for: .global)?.state.message == "")
    }

    @Test func showVeryLongMessage() {
        let long = String(repeating: "A", count: 500)
        toaster.show(.info(long))
        #expect(toaster.toast(for: .global)?.state.message == long)
    }

    @Test func clearNonexistentKey_thenShow() {
        toaster.clear(ToastKey.screen("never-shown"))
        toaster.show(.success("Now visible"))
        #expect(toaster.toast(for: .global)?.state == .success("Now visible"))
    }

    // MARK: - Integration: String Literal Keys

    @Test func showWithStringLiteral() {
        toaster.show(.warning("Be careful"), for: "warnings")
        #expect(toaster.toast(for: "warnings")?.state == .warning("Be careful"))
    }

    @Test func clearWithStringLiteral() {
        toaster.show(.info("Temp"), for: "temp-slot")
        toaster.clear("temp-slot")
        #expect(toaster.toast(for: "temp-slot") == nil)
    }

    // MARK: - Integration: Compatibility Overload

    @Test func compatibilityShow_inspectedWithModernAPI() {
        toaster.show(.error("Compat error"), ToastKey.screen("legacy"), persist: true)
        #expect(toaster.toast(for: ToastKey.screen("legacy"))?.state == .error("Compat error"))
        #expect(toaster.toast(for: ToastKey.screen("legacy"))?.isPersistent == true)
    }

    // MARK: - Integration: Auto-Dismissal

    @Test func autoDismiss_removesToastAfterTimeout() async {
        toaster.show(.success("Auto"), duration: .seconds(0.05))
        #expect(toaster.toast(for: .global) != nil)
        try? await Task.sleep(nanoseconds: 150_000_000)
        #expect(toaster.toast(for: .global) == nil)
    }

    @Test func autoDismiss_multipleToasts_dismissIndependently() async {
        toaster.show(.success("Fast"), for: .global, duration: .seconds(0.05))
        toaster.show(.info("Slow"), for: ToastKey.screen("slow"), duration: .seconds(10))

        try? await Task.sleep(nanoseconds: 150_000_000)

        #expect(toaster.toast(for: .global) == nil)
        #expect(toaster.toast(for: ToastKey.screen("slow")) != nil)
    }

    @Test func autoDismiss_replacedToast_doesNotDismissReplacement() async {
        toaster.show(.success("First"), duration: .seconds(0.1))
        try? await Task.sleep(nanoseconds: 50_000_000)
        toaster.show(.success("Second"), duration: .persistent)
        try? await Task.sleep(nanoseconds: 100_000_000)
        #expect(toaster.toast(for: .global)?.state == .success("Second"))
    }

    @Test func autoDismiss_loadingWithAutomatic_persists() async {
        toaster.show(.loading("Working"), duration: .automatic)
        #expect(toaster.toast(for: .global)?.isPersistent == true)
        try? await Task.sleep(nanoseconds: 200_000_000)
        #expect(toaster.toast(for: .global) != nil)
    }
}
