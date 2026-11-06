//
//  Results.swift
//  CineTools — Restyle v4 shared components
//
//  Result hero card, ring gauge, hero number and stat tiles.
//  These only DISPLAY values passed in by the screens; they never calculate them.
//

import SwiftUI

// MARK: - Result hero card

/// The "result first" card at the top of each calculator.
struct ResultHero<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.heroCard,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
                .stroke(Theme.Colors.separator, lineWidth: 1)
        )
    }
}

// MARK: - Hero number

/// Big Plex Mono figure with a smaller unit after it, e.g. "1.29 TB", "19.4 min".
struct HeroNumber: View {
    let value: String
    var unit: String? = nil
    var size: CGFloat = 84
    var valueColor: Color = Theme.Colors.textPrimary
    var unitColor: Color = Theme.Colors.rose

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value)
                .font(Theme.Fonts.mono(size))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
            if let unit {
                Text(unit)
                    .font(Theme.Fonts.archivo(size * 0.4, .semibold))
                    .foregroundStyle(unitColor)
            }
        }
        .animation(Theme.Motion.result, value: value)
    }
}

// MARK: - Ring gauge

/// Circular progress ring (Battery). `progress` is clamped to 0...1 and animates on change.
struct RingGauge<Center: View>: View {
    let progress: Double
    var diameter: CGFloat = Theme.Size.runtimeRing
    var lineWidth: CGFloat = Theme.Size.runtimeRingStroke
    var tint: Color = Theme.Colors.rose
    var trackColor: Color = Theme.Colors.tile
    private let center: Center

    init(progress: Double,
         diameter: CGFloat = Theme.Size.runtimeRing,
         lineWidth: CGFloat = Theme.Size.runtimeRingStroke,
         tint: Color = Theme.Colors.rose,
         trackColor: Color = Theme.Colors.tile,
         @ViewBuilder center: () -> Center) {
        self.progress = progress
        self.diameter = diameter
        self.lineWidth = lineWidth
        self.tint = tint
        self.trackColor = trackColor
        self.center = center()
    }

    private var clamped: Double {
        guard progress.isFinite else { return 0 }
        return min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            center
        }
        .frame(width: diameter, height: diameter)
        .animation(Theme.Motion.result, value: clamped)
    }
}

// MARK: - Stat tile

/// Small tile under the battery ring: "Draw 39.0 W", "Capacity 98 Wh", "Efficiency 90 %".
struct StatTile: View {
    let label: String
    let value: String
    var unit: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Theme.Fonts.subLabel)
                .foregroundStyle(Theme.Colors.textTertiary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(Theme.Fonts.stat)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let unit {
                    Text(unit)
                        .font(Theme.Fonts.mono(12))
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.card,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
