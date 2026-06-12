import Testing
@testable import MonkeToast

struct ToastDurationTests {
    // MARK: - Automatic

    @Test func automatic_withNonLoadingState_returnsDefaultTimeout() {
        let duration = ToastDuration.automatic
        let timeout = duration.timeout(for: .success("OK"), defaultTimeout: 3)
        #expect(timeout == 3)
    }

    @Test func automatic_withNonLoadingState_usesCustomDefaultTimeout() {
        let duration = ToastDuration.automatic
        let timeout = duration.timeout(for: .error("Fail"), defaultTimeout: 5)
        #expect(timeout == 5)
    }

    @Test func automatic_withLoadingState_returnsNil() {
        let duration = ToastDuration.automatic
        let timeout = duration.timeout(for: .loading("Working..."), defaultTimeout: 3)
        #expect(timeout == nil)
    }

    @Test func automatic_withCustomShowsProgress_usesDefaultTimeout() {
        let duration = ToastDuration.automatic
        let state = ToastState.custom(message: "Working", showsProgress: true)
        let timeout = duration.timeout(for: state, defaultTimeout: 3)
        #expect(timeout == 3)
    }

    @Test func automatic_withCustomNoProgress_returnsDefaultTimeout() {
        let duration = ToastDuration.automatic
        let state = ToastState.custom(message: "Done", systemImage: "star", tint: .yellow)
        let timeout = duration.timeout(for: state, defaultTimeout: 4)
        #expect(timeout == 4)
    }

    // MARK: - Seconds

    @Test func seconds_withPositiveValue_returnsThatValue() {
        let duration = ToastDuration.seconds(5)
        let timeout = duration.timeout(for: .success("OK"), defaultTimeout: 3)
        #expect(timeout == 5)
    }

    @Test func seconds_withZero_returnsNil() {
        let duration = ToastDuration.seconds(0)
        let timeout = duration.timeout(for: .success("OK"), defaultTimeout: 3)
        #expect(timeout == nil)
    }

    @Test func seconds_withNegativeValue_returnsNil() {
        let duration = ToastDuration.seconds(-1)
        let timeout = duration.timeout(for: .success("OK"), defaultTimeout: 3)
        #expect(timeout == nil)
    }

    @Test func seconds_withFractionalValue_returnsThatValue() {
        let duration = ToastDuration.seconds(2.5)
        let timeout = duration.timeout(for: .success("OK"), defaultTimeout: 3)
        #expect(timeout == 2.5)
    }

    @Test func seconds_withVeryLargeValue_returnsValue() {
        let duration = ToastDuration.seconds(1_000_000)
        let timeout = duration.timeout(for: .success("OK"), defaultTimeout: 3)
        #expect(timeout == 1_000_000)
    }

    // MARK: - Persistent

    @Test func persistent_alwaysReturnsNil() {
        let duration = ToastDuration.persistent
        #expect(duration.timeout(for: .success("OK"), defaultTimeout: 3) == nil)
        #expect(duration.timeout(for: .loading("Working"), defaultTimeout: 3) == nil)
        #expect(duration.timeout(for: .error("Fail"), defaultTimeout: 3) == nil)
        #expect(duration.timeout(for: .info("Info"), defaultTimeout: 3) == nil)
        #expect(duration.timeout(for: .warning("Warn"), defaultTimeout: 3) == nil)
        #expect(duration.timeout(for: .custom(message: "Custom"), defaultTimeout: 3) == nil)
    }

    // MARK: - Equatable

    @Test func automatic_isEqualToAutomatic() {
        #expect(ToastDuration.automatic == ToastDuration.automatic)
    }

    @Test func automatic_isNotEqualToSeconds() {
        #expect(ToastDuration.automatic != ToastDuration.seconds(3))
    }

    @Test func seconds_withSameValue_areEqual() {
        #expect(ToastDuration.seconds(5) == ToastDuration.seconds(5))
    }

    @Test func seconds_withDifferentValues_areNotEqual() {
        #expect(ToastDuration.seconds(3) != ToastDuration.seconds(5))
    }

    @Test func persistent_isEqualToPersistent() {
        #expect(ToastDuration.persistent == ToastDuration.persistent)
    }
}
