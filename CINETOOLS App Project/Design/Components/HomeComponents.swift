//
//  HomeComponents.swift
//  CineTools — Restyle v4 shared components
//
//  Home tool cards and Kit Bag "story" rings. Display only.
//

import SwiftUI

// MARK: - Tool card

/// Home bento card. `.hero` = full-width rose Battery card; `.tile` = Data / Transfer tiles.
/// `value` is optional — Transfer shows a plain summary line instead of a live figure.
struct ToolCard: View {
    enum Style { case hero, tile }

    let code: String            // "BAT.01 · BATTERY"
    let title: String           // "RUNTIME"
    var value: String? = nil    // "2.3"
    var unit: String? = nil     // "hrs"
    var summary: String? = nil  // "2 cams · 2 hrs"
    /// Right-aligned detail lines on the hero card, e.g. ["FX6", "39.0 W draw"]
    var detail: [String] = []
    var style: Style = .tile

    private var isHero: Bool { style == .hero }
    private var textColor: Color { isHero ? Theme.Colors.onRose : Theme.Colors.textPrimary }
    private var subColor: Color { isHero ? Theme.Colors.onRose.opacity(0.85) : Theme.Colors.textSecondary }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(code)
                        .microLabel(isHero ? 12 : 11,
                                    color: isHero ? Theme.Colors.onRose : Theme.Colors.textTertiary)
                    Text(title)
                        .displayTitle(isHero ? 24 : 20, color: textColor)
                }
                Spacer(minLength: 8)
                if isHero {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.Colors.onRose)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.18), in: Circle())
                }
            }

            Spacer(minLength: isHero ? 28 : 24)

            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    if let value {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(value)
                                .font(isHero ? Theme.Fonts.homeBatteryValue : Theme.Fonts.homeTileValue)
                                .foregroundStyle(textColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            if let unit {
                                Text(unit)
                                    .font(Theme.Fonts.archivo(isHero ? 20 : 16, .medium))
                                    .foregroundStyle(textColor)
                            }
                        }
                    }
                    if let summary {
                        Text(summary)
                            .font(Theme.Fonts.archivo(isHero ? 15 : 14))
                            .foregroundStyle(subColor)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 8)
                if isHero && !detail.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        ForEach(detail, id: \.self) { line in
                            Text(line)
                                .font(Theme.Fonts.archivo(15))
                                .foregroundStyle(subColor)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(isHero ? 22 : 18)
        .frame(maxWidth: .infinity,
               minHeight: isHero ? Theme.Size.batteryTileMinHeight : 150,
               alignment: .topLeading)
        .background(isHero ? Theme.Colors.rose : Theme.Colors.tile,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.homeTile, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.homeTile, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Kit story ring

/// Kit Bag ring: model tag inside a Paper ring with the setup name below,
/// or a dashed "+ New" ring.
struct KitStoryRing: View {
    enum Kind { case setup(tag: String), new }

    let kind: Kind
    var name: String? = nil
    var diameter: CGFloat = Theme.Size.kitRing
    var showsName: Bool = true

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                switch kind {
                case .setup(let tag):
                    Circle()
                        .fill(Theme.Colors.bg)
                        .padding(Theme.Size.kitRingStroke + 3)
                    Circle()
                        .stroke(Theme.Colors.paper, lineWidth: Theme.Size.kitRingStroke)
                    Text(tag)
                        .font(Theme.Fonts.archivo(diameter * 0.2, .semibold))
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 8)
                case .new:
                    Circle()
                        .stroke(Theme.Colors.textQuaternary,
                                style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    Image(systemName: "plus")
                        .font(.system(size: diameter * 0.28, weight: .light))
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
            }
            .frame(width: diameter, height: diameter)

            if showsName {
                Text(displayName)
                    .font(Theme.Fonts.archivo(13))
                    .foregroundStyle(isNew ? Theme.Colors.textTertiary : Theme.Colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: diameter + 14)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var isNew: Bool {
        if case .new = kind { return true }
        return false
    }

    private var displayName: String {
        if let name { return name }
        return isNew ? "New" : ""
    }
}
