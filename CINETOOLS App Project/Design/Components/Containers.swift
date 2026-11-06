//
//  Containers.swift
//  CineTools — Restyle v4 shared components
//
//  Cards, rows, section headers and screen titles.
//  Pure presentation: no calculation or data logic.
//

import SwiftUI

// MARK: - Screen background

extension View {
    /// Ink background behind the whole screen.
    func themedScreen() -> some View {
        self.background(Theme.Colors.bg.ignoresSafeArea())
    }
}

// MARK: - Screen title

/// Big uppercase Archivo title, e.g. "BATTERY RUNTIME" (30pt) or "KIT BAG" (34pt),
/// with an optional small eyebrow line above ("Saved setups").
struct ScreenTitle: View {
    let text: String
    var eyebrow: String? = nil
    var size: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let eyebrow {
                Text(eyebrow)
                    .font(Theme.Fonts.archivo(15))
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
            Text(text)
                .displayTitle(size)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.titleMargin)
        .accessibilityAddTraits(.isHeader)
    }
}

/// "‹ Tools" style back button for pushed screens.
/// The screen supplies the action, so any existing dismiss logic is kept.
struct ThemedBackButton: View {
    var title: String = "Tools"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .font(Theme.Fonts.body)
            }
            .foregroundStyle(Theme.Colors.textSecondary)
            .frame(minHeight: Theme.Size.tapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back to \(title)")
    }
}

// MARK: - Section header

/// "1 · CAMERA" style header that sits above a GroupedCard.
/// Assumes it's inside a container already padded by `Theme.Spacing.cardMargin`.
struct ThemedSectionHeader: View {
    let title: String
    /// Optional coloured dot (Data: per-camera colour)
    var dotColor: Color? = nil
    /// Optional trailing text action (Data: "Remove")
    var actionTitle: String? = nil
    var actionColor: Color = Theme.Colors.roseSmallOnInk
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let dotColor {
                Circle().fill(dotColor).frame(width: 8, height: 8)
            }
            Text(title)
                .font(Theme.Fonts.sectionHeader)
                .textCase(.uppercase)
                .foregroundStyle(Theme.Colors.textTertiary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(Theme.Fonts.archivo(15))
                    .foregroundStyle(actionColor)
                    .buttonStyle(.plain)
            }
        }
        .padding(.leading, Theme.Spacing.sectionHeaderInset - Theme.Spacing.cardMargin)
        .padding(.trailing, Theme.Spacing.rowPadding)
        .padding(.top, Theme.Spacing.sectionHeaderTop)
        .padding(.bottom, Theme.Spacing.sectionHeaderBottom)
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Grouped card

/// Rounded `card` container for a stack of rows. Put `RowDivider()` between rows.
struct GroupedCard<Content: View>: View {
    var fill: Color = Theme.Colors.card
    var radius: CGFloat = Theme.Radius.card
    private let content: Content

    init(fill: Color = Theme.Colors.card,
         radius: CGFloat = Theme.Radius.card,
         @ViewBuilder content: () -> Content) {
        self.fill = fill
        self.radius = radius
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity)
        .background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// 0.5pt divider between rows, inset to the row text.
struct RowDivider: View {
    var inset: CGFloat = Theme.Spacing.rowPadding

    var body: some View {
        Rectangle()
            .fill(Theme.Colors.separator)
            .frame(height: Theme.Size.separator)
            .padding(.leading, inset)
    }
}

// MARK: - Setting row

/// A row inside a GroupedCard: label (+ optional sub-label) on the left, any trailing view on the right.
/// Pass `action` to make the whole row tappable (e.g. to open a picker sheet).
struct SettingRow<Trailing: View>: View {
    let label: String
    var subLabel: String? = nil
    var action: (() -> Void)? = nil
    private let trailing: Trailing

    init(_ label: String,
         subLabel: String? = nil,
         action: (() -> Void)? = nil,
         @ViewBuilder trailing: () -> Trailing) {
        self.label = label
        self.subLabel = subLabel
        self.action = action
        self.trailing = trailing()
    }

    var body: some View {
        if let action {
            Button(action: action) { rowContent }
                .buttonStyle(RowButtonStyle())
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textPrimary)
                if let subLabel {
                    Text(subLabel)
                        .font(Theme.Fonts.subLabel)
                        .foregroundStyle(Theme.Colors.textTertiary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 8)
            trailing
        }
        .padding(.horizontal, Theme.Spacing.rowPadding)
        .padding(.vertical, 10)
        .frame(minHeight: subLabel == nil ? Theme.Size.rowMinHeight : Theme.Size.rowMinHeightWithSub)
        .contentShape(Rectangle())
    }
}

/// Standard trailing value for a SettingRow: text (Archivo or Plex Mono) + optional chevron.
struct RowValue: View {
    let text: String
    var mono: Bool = false
    var chevron: Bool = false
    var color: Color = Theme.Colors.textTertiary

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(mono ? Theme.Fonts.rowValue : Theme.Fonts.body)
                .foregroundStyle(color)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
        }
    }
}

extension SettingRow where Trailing == RowValue {
    /// Convenience: `SettingRow("Brand", value: "Sony", chevron: true) { showBrandSheet = true }`
    init(_ label: String,
         subLabel: String? = nil,
         value: String,
         mono: Bool = false,
         chevron: Bool = false,
         valueColor: Color = Theme.Colors.textTertiary,
         action: (() -> Void)? = nil) {
        self.init(label, subLabel: subLabel, action: action) {
            RowValue(text: value, mono: mono, chevron: chevron, color: valueColor)
        }
    }
}

/// Subtle pressed state for tappable rows.
struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Theme.Colors.cardRaised : Color.clear)
    }
}
