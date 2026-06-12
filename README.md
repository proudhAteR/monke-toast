# 🐒 MonkeToast

MonkeToast is a keyed toast system for SwiftUI apps. It gives every screen, tab, or feature its own isolated toast slot so feedback never collides. Built with `@Observable`, Swift concurrency, and zero external dependencies.

Each toast slot holds one presentation at a time — showing a new toast for the same key replaces the previous one and cancels its pending dismissal.

## Requirements

- Swift 6.0+
- macOS 14.0+ / iOS 17.0+
- Swift Package Manager

## Quick Start

1. Add `MonkeToast` to your project via SPM.
2. Inject `Toaster.shared` at the app root.
3. Install a `ToastStack` overlay.
4. Show toasts from anywhere using the environment.

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .toastStack()
                .environment(Toaster.shared)
        }
    }
}
```

```swift
struct ContentView: View {
    @Environment(Toaster.self) private var toaster

    var body: some View {
        Button("Save") {
            toaster.show(.success("Profile saved"))
        }
    }
}
```

## Toast States

MonkeToast provides six semantic states that encode both the message and the visual intent:

```swift
toaster.show(.loading("Uploading"), duration: .persistent)
toaster.show(.success("Profile saved"))
toaster.show(.error("Upload failed"), duration: .seconds(5))
toaster.show(.info("You are back online"))
toaster.show(.warning("Connection is unstable"))
toaster.show(.custom(
    message: "Action completed",
    systemImage: "sparkles",
    tint: .blue
))
```


## Toast Durations

`ToastDuration` replaces the common `persist`/`timeout` flag pair with an explicit policy:

```swift
case automatic    // Dismiss non-loading toasts after 3 s; persists loading toasts
case seconds(5)   // Custom timeout in seconds
case persistent   // Stays visible until cleared
```

```swift
toaster.show(.loading("Syncing"), duration: .persistent)

// Later, when the work finishes:
toaster.clear()
```

## Keyed Toast Slots

Each toast is scoped to a `ToastKey`. By default toasts are shown on the `.global` slot, but you can isolate feedback per screen, tab, or feature:

```swift
// Feature-scoped slot
let profileSlot = ToastKey.screen("profile")

toaster.show(.error("Could not update profile"), for: profileSlot)
```

Built-in keys:

```swift
ToastKey.global                    // Default app-wide slot
ToastKey.main                      // Common root-view slot
ToastKey.screen("profile")         // Feature-scoped slot
ToastKey.tab("settings")           // Tab-scoped slot
```

Using string keys is also supported for migration convenience:

```swift
toaster.show(.info("Ready"), for: "dashboard")
```

## Multiple Toast Stacks

Install more than one stack when a screen needs its own toast lane:

```swift
ZStack {
    TabView {
        ProfileView()
            .toastStack(.screen("profile"), placement: .top)
        SettingsView()
    }
}
.toastStack()  // Global slot
```

## Configuration

Customize the visual appearance with `ToastViewConfiguration`:

```swift
.toastStack(configuration: ToastViewConfiguration(
    minWidth: 300,
    maxWidth: 500,
    showsDismissButton: false
))
```

| Property | Default |
|---|---|
| `minWidth` | `260` |
| `maxWidth` | `560` |
| `horizontalMargin` | `16` |
| `edgeMargin` | `12` |
| `contentPadding` | `14` |
| `spacing` | `10` |
| `cornerRadius` | `14` |
| `showsDismissButton` | `true` |

## Placement

Toasts can appear at the top or bottom of the screen:

```swift
.toastStack(placement: .top)
.toastStack(placement: .bottom)  // default
```

## Clear Behavior

```swift
toaster.clear()                  // Clears .global slot
toaster.clear(.screen("login"))  // Clears a specific slot
toaster.clearAll()               // Clears every slot
```

When a new toast is shown for the same key, it replaces the existing one and cancels any pending auto-dismiss timer. This prevents stale dismissal tasks from removing the new toast.

## Platform Adaptations

- On **iOS 26.0+**, toasts render with a native glass material (`glassEffect`).
- On **earlier iOS versions and macOS**, toasts use `regularMaterial` with a subtle separator stroke.
