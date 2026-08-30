# AGENTS.md

Guidance for coding agents working in this repository.

## Project Overview

TimeOnTask, also called Ember in parts of the codebase, is a native macOS SwiftUI menu-bar focus timer. The path contains `ios`, but the Xcode project targets macOS (`SDKROOT = macosx`).

The app has a main window and a `MenuBarExtra` popover. Both are driven by the same shared timer model.

## Commands

Build:

```bash
xcodebuild -scheme TimeOnTask -project TimeOnTask.xcodeproj build
```

Run all tests:

```bash
xcodebuild -scheme TimeOnTask -project TimeOnTask.xcodeproj test
```

Run a single Swift Testing test:

```bash
xcodebuild -scheme TimeOnTask -project TimeOnTask.xcodeproj test -only-testing:TimeOnTaskTests/TimeOnTaskTests/presetChangesRemainingWhileIdle
```

Run only UI tests:

```bash
xcodebuild -scheme TimeOnTask -project TimeOnTask.xcodeproj test -only-testing:TimeOnTaskUITests
```

This is a plain Xcode project. There is no `Package.swift` and no separate lint configuration.

## Architecture

- `TimeOnTask/AppCore/App/TimeOnTaskApp.swift` creates one `@StateObject` `TimerEngine` and injects it into platform-specific scenes with `.environmentObject`.
- `TimeOnTask/AppCore/Core/TimerEngine.swift` is the single source of truth for timer state and behavior. Keep timer logic out of views.
- `TimeOnTask/AppCore` contains code shared by the macOS and iPadOS/iOS app surfaces.
- `TimeOnTask/Mac` contains macOS-specific views, including the main window and menu bar UI.
- `TimeOnTask/iPadOS-iOS` contains iPhone and iPad-specific views.
- `TimerPhase` follows `idle -> running <-> paused -> complete -> idle`.
- Running timers use wall-clock time through `endDate`, while a repeating `Timer` only refreshes display state. Avoid replacing this with tick-counting logic.
- `TimeOnTask/AppCore/Services/NotificationManager.swift` owns notification and sound side effects.
- `TimeOnTask/AppCore/DesignSystem/EmberStyle.swift` centralizes colors and button styles. Prefer existing design-system types over ad hoc styling.
- SwiftUI previews should use `TimerEngine` preview helpers instead of creating view-owned timer state.

## Implementation Notes

- Preserve the shared-engine model between platform-specific app views and the macOS menu bar UI.
- Keep views mostly declarative: read from `engine`, bind simple editable values, and call engine methods.
- If adding timer states or controls, update `MacTimerView`, `IOSTimerView`, and `MenuBarContentView` unless the behavior is intentionally scene-specific.
- Keep state mutations for `TimerEngine` on the main actor.
- Keep variable declarations for UI elements at the bottom of the scope so the main view flow stays easy to scan.
- Add comments for every declared variable, function, and enum, including UI properties, helper methods, enum types, and enum cases. Use Swift doc comments (`///`) for functions and enums. Start each function docstring with a short summary sentence, then add a blank doc-comment line before any structured details. For functions with parameters, include a `- Parameters:` section with one indented bullet per parameter that explains its role. For functions that return a value, include a `- Returns:` section that describes what comes back. Omit sections that do not apply.
- Avoid broad refactors unless they directly support the requested change.

## Testing Notes

The tests in `TimeOnTaskTests.swift` may currently be out of sync with the app defaults: some assertions expect a 25-minute timer, while `TimerEngine.defaultDuration` is 30 minutes and presets are 15, 30, 45, and 60 minutes. Account for that existing mismatch when running or updating tests.

## Git Hygiene

- The worktree may contain user edits. Do not revert changes you did not make.
- Keep edits scoped to the requested task.
- Avoid committing unless the user explicitly asks for a commit.

## Swift Documentation Comments

When documenting Swift functions, methods, and initializers, use Swift documentation comments (`///`) with Swift Markdown documentation syntax.

Follow these formatting rules:

- Begin with a concise summary sentence.
- Add a blank documentation line (`///`) before documentation fields.
- Group documentation under semantic fields such as `- Parameters:`, `- Returns:`, `- Throws:`, `- Precondition:`, and similar sections.
- When a field contains multiple items, indent each item beneath its field.
- Nested items must be visually tabbed/indented under the field they belong to.
- Never place multiple parameter, return, or error descriptions at the same indentation level as the field heading.
- Use consistent indentation of two spaces after `///` for nested documentation items.

Example:

/// Calculates pricing information for an order.
///
/// - Parameters:
///   - price: The price before tax.
///   - taxRate: The tax rate as a decimal.
///   - discountRate: The discount rate as a decimal.
/// - Returns:
///   - subtotal: The price after applying the discount.
///   - total: The final price including tax.
/// - Throws:
///   - PricingError.invalidPrice: If the supplied price is negative.
///   - PricingError.invalidTaxRate: If the tax rate is invalid.
func calculateTotal(
    price: Double,
    taxRate: Double,
    discountRate: Double
) throws -> (subtotal: Double, total: Double) {
    // ...
}
