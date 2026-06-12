import Testing
import SwiftUI
@testable import MonkeToast

struct ToastPlacementTests {
    @Test func top_alignment_isTop() {
        #expect(ToastPlacement.top.alignment == .top)
    }

    @Test func bottom_alignment_isBottom() {
        #expect(ToastPlacement.bottom.alignment == .bottom)
    }

    @Test func top_transitionEdge_isTop() {
        #expect(ToastPlacement.top.transitionEdge == .top)
    }

    @Test func bottom_transitionEdge_isBottom() {
        #expect(ToastPlacement.bottom.transitionEdge == .bottom)
    }

    @Test func top_paddingEdge_isTop() {
        #expect(ToastPlacement.top.paddingEdge == .top)
    }

    @Test func bottom_paddingEdge_isBottom() {
        #expect(ToastPlacement.bottom.paddingEdge == .bottom)
    }

    @Test func placement_equality() {
        #expect(ToastPlacement.top == ToastPlacement.top)
        #expect(ToastPlacement.bottom == ToastPlacement.bottom)
        #expect(ToastPlacement.top != ToastPlacement.bottom)
    }
}

@MainActor
struct LoafNoToasterTests {
    @Test func loaf_rendersNothing_whenNoToasterInEnvironment() {
        let loaf = Loaf()
        #expect(loaf.key == .global)
        #expect(loaf.placement == .bottom)
    }

    @Test func loaf_withCustomKey() {
        let loaf = Loaf(key: ToastKey.screen("test"), placement: .top)
        #expect(loaf.key == ToastKey.screen("test"))
        #expect(loaf.placement == .top)
    }

    @Test func loaf_withCustomConfiguration() {
        let config = ToastViewConfiguration(minWidth: 300, showsDismissButton: false)
        let loaf = Loaf(configuration: config)
        #expect(loaf.configuration.minWidth == 300)
        #expect(loaf.configuration.showsDismissButton == false)
    }

    @Test func loaf_defaultKeyIsGlobal() {
        let loaf = Loaf()
        #expect(loaf.key == .global)
    }

    @Test func loaf_defaultPlacementIsBottom() {
        let loaf = Loaf()
        #expect(loaf.placement == .bottom)
    }

    @Test func loaf_defaultConfiguration() {
        let loaf = Loaf()
        #expect(loaf.configuration == ToastViewConfiguration())
    }

    @available(macOS 14.0, *)
    @MainActor
    @Test func loaf_loafModifier() {
        _ = Text("Test").loaf()
    }

    @available(macOS 14.0, *)
    @MainActor
    @Test func loaf_loafModifier_custom() {
        _ = Text("Content").loaf(.screen("test"), placement: .top)
    }

    @available(macOS 14.0, *)
    @MainActor
    @Test func loaf_loafModifier_withConfig() {
        let config = ToastViewConfiguration(cornerRadius: 20)
        _ = Text("Full").loaf(.main, placement: .top, configuration: config)
    }
}
