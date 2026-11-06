//
//  Controls.swift
//  CineTools — Restyle v4 shared components
//
//  Buttons and the stepper pill. Controls use Paper / Stone, never rose.
//  The stepper takes closures so each screen keeps its own existing +/− logic and limits.
//

import SwiftUI

// MARK: - Buttons

/// Paper, fully rounded, 54pt — "Save to Kit Bag", "Request an addition".
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Fonts.button)
            .foregroundStyle(Theme.Colors.ink)
            .frame(maxWidth: .infinity, minHeight: Theme.Size.buttonHeight)
            .background(Theme.Colors.paper, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

/// Outline, fully rounded, 54pt — "+ Add camera", "+ New setup".
struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Fonts.button)
            .foregroundStyle(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity, minHeight: Theme.Size.buttonHeight)
            .background(
                Capsule()
                    .fill(configuration.isPressed ? Theme.Colors.card : Color.clear)
            )
            .overlay(Capsule().stroke(Theme.Colors.track, lineWidth: 1))
    }
}

/// Small Paper pill — "Open" on Kit Bag cards, active tab.
struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Fonts.archivo(17, .semibold))
            .foregroundStyle(Theme.Colors.ink)
            .padding(.horizontal, 20)
            .frame(minHeight: Theme.Size.tapTarget)
            .background(Theme.Colors.paper, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Convenience wrapper: `PrimaryButton("Save to Kit Bag") { ... }`
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(title, action: action).buttonStyle(PrimaryButtonStyle())
    }
}

/// Convenience wrapper: `OutlineButton("+ Add camera") { ... }`
struct OutlineButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(title, action: action).buttonStyle(OutlineButtonStyle())
    }
}

/// Quiet centred text link — "Missing kit? Request an addition".
struct TextLink: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.archivo(15))
                .foregroundStyle(Theme.Colors.textTertiary)
                .frame(maxWidth: .infinity, minHeight: Theme.Size.tapTarget)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stepper pill

/// − value + control. − is a `cardRaised` circle, + is a Paper circle.
/// The screen passes its existing increment / decrement code, so limits stay exactly as they are.
struct StepperPill: View {
    let value: Int
    var canDecrement: Bool = true
    var canIncrement: Bool = true
    let onDecrement: () -> Void
    let onIncrement: () -> Void
    var diameter: CGFloat = Theme.Size.tapTarget

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(width: diameter, height: diameter)
                    .background(Theme.Colors.cardRaised, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canDecrement)
            .opacity(canDecrement ? 1 : 0.4)
            .accessibilityLabel("Decrease")

            Text("\(value)")
                .font(Theme.Fonts.mono(20))
                .foregroundStyle(Theme.Colors.textPrimary)
                .frame(minWidth: 24)
                .contentTransition(.numericText())
                .animation(.snappy, value: value)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.Colors.ink)
                    .frame(width: diameter, height: diameter)
                    .background(Theme.Colors.paper, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canIncrement)
            .opacity(canIncrement ? 1 : 0.4)
            .accessibilityLabel("Increase")
        }
        .accessibilityElement(children: .contain)
        .accessibilityValue("\(value)")
    }
}

// MARK: - Native control tints

extension View {
    /// Paper slider fill, Stone toggle — never rose.
    func themedControlTint() -> some View {
        self.tint(Theme.Colors.textTertiary)
    }
}
