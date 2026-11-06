//
//  Theme.swift
//  CineTools — Restyle v4 design tokens
//
//  Visual tokens only. No calculation, data or navigation logic lives here.
//  Source: design_handoff_cinetools_restyle/README.md (Draft 04)
//

import SwiftUI
import UIKit

// MARK: - Colour

enum Theme {

    enum Colors {
        /// Screen background — Ink (never pure black)
        static let bg               = Color(hex: 0x1C1A16)
        /// Result hero card
        static let heroCard         = Color(hex: 0x211E1A)
        /// Grouped cards
        static let card             = Color(hex: 0x28241F)
        /// Data / Transfer home tiles
        static let tile             = Color(hex: 0x2E2A24)
        /// Stepper −, chips, sheet rows
        static let cardRaised       = Color(hex: 0x342F28)
        /// Row dividers (draw at 0.5pt)
        static let separator        = Color(hex: 0xEFE8D9, opacity: 0.10)
        /// Toggle off / slider track
        static let track            = Color(hex: 0x3D372F)
        /// Inactive bars
        static let trackInactive    = Color(hex: 0x4A443A)

        /// Paper
        static let textPrimary      = Color(hex: 0xEFE8D9)
        /// Sub-labels
        static let textSecondary    = Color(hex: 0xD3C9B2)
        /// Row values, section headers, chevrons
        static let textTertiary     = Color(hex: 0xA09679)
        /// Captions
        static let textQuaternary   = Color(hex: 0x8E8368)

        /// Signal Rose — use ONCE per screen, on the main result only
        static let rose             = Color(hex: 0xE02D5D)
        /// Rose for text smaller than 14pt on Ink
        static let roseSmallOnInk   = Color(hex: 0xF0567F)
        /// Text on rose fills
        static let onRose           = Color(hex: 0xFFF1F4)

        /// Paper is also the fill for primary buttons / active pills
        static let paper            = textPrimary
        /// Ink is also the text colour on Paper fills
        static let ink              = bg

        /// Data usage stacked-bar segment colours, in camera order
        static let cameraSegments: [Color] = [
            rose,
            textPrimary,
            textTertiary,
            Color(hex: 0x6F6656)
        ]
    }

    // MARK: - Shape

    enum Radius {
        static let hero: CGFloat        = 28
        static let homeTile: CGFloat    = 26
        static let card: CGFloat        = 20
        static let chip: CGFloat        = 18
        static let sheetTop: CGFloat    = 30
        static let appIcon: CGFloat     = 10
        /// Buttons are fully rounded (54pt high)
        static let button: CGFloat      = 27
    }

    // MARK: - Spacing / sizing

    enum Spacing {
        /// Side margin for cards
        static let cardMargin: CGFloat          = 16
        /// Side margin for screen titles
        static let titleMargin: CGFloat         = 20
        /// Leading inset of section headers
        static let sectionHeaderInset: CGFloat  = 36
        static let sectionHeaderTop: CGFloat    = 26
        static let sectionHeaderBottom: CGFloat = 8
        /// Horizontal padding inside a grouped-card row
        static let rowPadding: CGFloat          = 16
    }

    enum Size {
        static let rowMinHeight: CGFloat            = 52
        static let rowMinHeightWithSub: CGFloat     = 56
        static let tapTarget: CGFloat               = 44
        static let buttonHeight: CGFloat            = 54
        static let separator: CGFloat               = 0.5
        static let batteryTileMinHeight: CGFloat    = 168
        static let appIcon: CGFloat                 = 38
        static let supportPillHeight: CGFloat       = 34
        static let kitRing: CGFloat                 = 72
        static let kitRingStroke: CGFloat           = 2.5
        static let runtimeRing: CGFloat             = 224
        static let runtimeRingStroke: CGFloat       = 16
        static let sheetGrabber                     = CGSize(width: 36, height: 5)
    }

    // MARK: - Motion

    enum Motion {
        /// Ring / bar changes (~0.5–0.6s ease-out)
        static let result: Animation = .snappy(duration: 0.55)
        /// "Saved to Kit Bag" toast duration
        static let toastSeconds: Double = 1.8
    }
}

// MARK: - Typography

extension Theme {

    enum Fonts {

        // PostScript names of the bundled fonts (see UIAppFonts in CINETOOLS-App-Info.plist)
        private enum Name {
            static let archivoRegular   = "Archivo-Regular"
            static let archivoMedium    = "Archivo-Medium"
            static let archivoSemiBold  = "Archivo-SemiBold"
            static let archivoExtraBold = "Archivo-ExtraBold"
            static let plexRegular      = "IBMPlexMono-Regular"
            static let plexMedium       = "IBMPlexMono-Medium"
            static let plexSemiBold     = "IBMPlexMono-SemiBold"
        }

        enum Weight { case regular, medium, semibold, heavy }

        /// Archivo (falls back to Helvetica Neue if the font isn't bundled)
        static func archivo(_ size: CGFloat, _ weight: Weight = .regular) -> Font {
            let name: String
            let fallback: Font.Weight
            switch weight {
            case .regular:  name = Name.archivoRegular;   fallback = .regular
            case .medium:   name = Name.archivoMedium;    fallback = .medium
            case .semibold: name = Name.archivoSemiBold;  fallback = .semibold
            case .heavy:    name = Name.archivoExtraBold; fallback = .heavy
            }
            return custom(name, size: size, fallbackFamily: "Helvetica Neue", fallbackWeight: fallback)
        }

        /// IBM Plex Mono for every number (falls back to Menlo)
        static func mono(_ size: CGFloat, _ weight: Weight = .medium) -> Font {
            let name: String
            let fallback: Font.Weight
            switch weight {
            case .regular:          name = Name.plexRegular;  fallback = .regular
            case .medium:           name = Name.plexMedium;   fallback = .medium
            case .semibold, .heavy: name = Name.plexSemiBold; fallback = .semibold
            }
            return custom(name, size: size, fallbackFamily: "Menlo", fallbackWeight: fallback)
                .monospacedDigit()
        }

        private static func custom(_ name: String, size: CGFloat,
                                   fallbackFamily: String, fallbackWeight: Font.Weight) -> Font {
            if UIFont(name: name, size: size) != nil {
                return .custom(name, size: size)
            }
            #if DEBUG
            print("⚠️ Theme: font \(name) not found — using \(fallbackFamily)")
            #endif
            return .custom(fallbackFamily, size: size).weight(fallbackWeight)
        }

        // MARK: Named styles from the handoff

        /// Screen titles, e.g. "BATTERY RUNTIME" — Archivo 800, 30pt
        static let screenTitle      = archivo(30, .heavy)
        /// Large titles, e.g. "KIT BAG", "SUPPORT" — Archivo 800, 34pt
        static let largeTitle       = archivo(34, .heavy)
        /// Home battery tool card title — 24pt
        static let toolTitleLarge   = archivo(24, .heavy)
        /// Home data / transfer tool card titles — 20pt
        static let toolTitle        = archivo(20, .heavy)

        /// Body and row labels — 17pt
        static let body             = archivo(17)
        /// Sub-labels — 13pt
        static let subLabel         = archivo(13)
        /// Section headers — 13pt
        static let sectionHeader    = archivo(13, .medium)
        /// Buttons — 17pt semibold, sentence case
        static let button           = archivo(17, .semibold)

        /// Hero number inside the battery ring — 68pt
        static let heroRing         = mono(68)
        /// Hero number for Data / Transfer — 84pt
        static let heroLarge        = mono(84)
        /// Home battery card hours — 56pt
        static let homeBatteryValue = mono(56)
        /// Home Data / Transfer tile values — 36pt
        static let homeTileValue    = mono(36)
        /// Stat tiles — 18pt
        static let stat             = mono(18)
        /// Row values — 15–17pt
        static let rowValue         = mono(16)
        /// Micro-labels, e.g. "EST. RUNTIME" — Plex Mono 600, 11pt, uppercase
        static let microLabel       = mono(11, .semibold)
    }
}

// MARK: - Text style modifiers

extension View {
    /// Archivo 800, uppercase, tight tracking (−0.045em), tight leading (~0.95)
    func displayTitle(_ size: CGFloat = 30, color: Color = Theme.Colors.textPrimary) -> some View {
        self
            .font(Theme.Fonts.archivo(size, .heavy))
            .textCase(.uppercase)
            .tracking(-0.045 * size)
            .lineSpacing(-0.05 * size)
            .foregroundStyle(color)
    }

    /// Plex Mono 600, small, wide tracking (0.13em), uppercase — e.g. "EST. RUNTIME"
    func microLabel(_ size: CGFloat = 11, color: Color = Theme.Colors.textTertiary) -> some View {
        self
            .font(Theme.Fonts.mono(size, .semibold))
            .textCase(.uppercase)
            .tracking(0.13 * size)
            .foregroundStyle(color)
    }
}

// MARK: - Hex colour helper

extension Color {
    /// `Color(hex: 0x1C1A16)` or `Color(hex: 0xEFE8D9, opacity: 0.1)`
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Preview (token check — fonts load if these don't look like Helvetica / Menlo)

#Preview("Theme tokens") {
    ScrollView {
        VStack(alignment: .leading, spacing: 18) {
            Text("Battery Runtime").displayTitle(30)
            Text("Kit Bag").displayTitle(34)
            Text("Est. runtime").microLabel()
            Text("2.3").font(Theme.Fonts.heroRing).foregroundStyle(Theme.Colors.textPrimary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("1.29").font(Theme.Fonts.heroLarge).foregroundStyle(Theme.Colors.textPrimary)
                Text("TB").font(Theme.Fonts.archivo(34, .semibold)).foregroundStyle(Theme.Colors.rose)
            }
            Text("Body row label 17pt").font(Theme.Fonts.body).foregroundStyle(Theme.Colors.textPrimary)
            Text("Sub-label 13pt").font(Theme.Fonts.subLabel).foregroundStyle(Theme.Colors.textSecondary)
            Text("19.0 W").font(Theme.Fonts.rowValue).foregroundStyle(Theme.Colors.textTertiary)

            let swatches: [(String, Color)] = [
                ("bg", Theme.Colors.bg), ("heroCard", Theme.Colors.heroCard),
                ("card", Theme.Colors.card), ("tile", Theme.Colors.tile),
                ("cardRaised", Theme.Colors.cardRaised), ("track", Theme.Colors.track),
                ("paper", Theme.Colors.textPrimary), ("textTertiary", Theme.Colors.textTertiary),
                ("rose", Theme.Colors.rose)
            ]
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                ForEach(swatches, id: \.0) { name, color in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: Theme.Radius.chip)
                            .fill(color)
                            .frame(height: 56)
                            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.chip)
                                .stroke(Theme.Colors.separator, lineWidth: Theme.Size.separator))
                        Text(name).font(Theme.Fonts.subLabel).foregroundStyle(Theme.Colors.textQuaternary)
                    }
                }
            }

            Text("Save to Kit Bag")
                .font(Theme.Fonts.button)
                .foregroundStyle(Theme.Colors.ink)
                .frame(maxWidth: .infinity, minHeight: Theme.Size.buttonHeight)
                .background(Theme.Colors.paper, in: Capsule())
        }
        .padding(Theme.Spacing.titleMargin)
    }
    .background(Theme.Colors.bg)
    .preferredColorScheme(.dark)
}
