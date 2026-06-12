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
struct ToastStackNoToasterTests {
    @Test func stack_rendersNothing_whenNoToasterInEnvironment() {
        let stack = ToastStack()
        #expect(stack.key == .global)
        #expect(stack.placement == .bottom)
    }

    @Test func stack_withCustomKey() {
        let stack = ToastStack(key: ToastKey.screen("test"), placement: .top)
        #expect(stack.key == ToastKey.screen("test"))
        #expect(stack.placement == .top)
    }

    @Test func stack_withCustomConfiguration() {
        let config = ToastViewConfiguration(minWidth: 300, showsDismissButton: false)
        let stack = ToastStack(configuration: config)
        #expect(stack.configuration.minWidth == 300)
        #expect(stack.configuration.showsDismissButton == false)
    }

    @Test func stack_defaultKeyIsGlobal() {
        let stack = ToastStack()
        #expect(stack.key == .global)
    }

    @Test func stack_defaultPlacementIsBottom() {
        let stack = ToastStack()
        #expect(stack.placement == .bottom)
    }

    @Test func stack_defaultConfiguration() {
        let stack = ToastStack()
        #expect(stack.configuration == ToastViewConfiguration())
    }

    @available(macOS 14.0, *)
    @MainActor
    @Test func stack_toastStackModifier() {
        _ = Text("Test").toastStack()
    }

    @available(macOS 14.0, *)
    @MainActor
    @Test func stack_toastStackModifier_custom() {
        _ = Text("Content").toastStack(.screen("test"), placement: .top)
    }

    @available(macOS 14.0, *)
    @MainActor
    @Test func stack_toastStackModifier_withConfig() {
        let config = ToastViewConfiguration(cornerRadius: 20)
        _ = Text("Full").toastStack(.main, placement: .top, configuration: config)
    }
}
