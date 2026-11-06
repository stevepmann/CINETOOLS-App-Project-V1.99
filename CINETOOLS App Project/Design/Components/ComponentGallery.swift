//
//  ComponentGallery.swift
//  CineTools — Restyle v4
//
//  Preview-only gallery of the shared components, with sample values.
//  Not used by the app itself — open the canvas on this file to review Step 2.
//

import SwiftUI

#if DEBUG
private struct ComponentGallery: View {
    @State private var count = 1
    @State private var advanced = true
    @State private var temp = 20.0
    @State private var showSheet = false
    @State private var selectedBrand = 1
    @State private var picked: Set<Int> = [0]

    private let brands = [
        PickerOption(id: 0, title: "ARRI", subtitle: "2 models"),
        PickerOption(id: 1, title: "Sony", subtitle: "3 models"),
        PickerOption(id: 2, title: "RED", subtitle: "1 model")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ThemedBackButton { }
                    .padding(.horizontal, Theme.Spacing.titleMargin)
                ScreenTitle(text: "Battery Runtime")

                // Result hero
                ResultHero {
                    HStack {
                        Spacer()
                        RingGauge(progress: 0.23) {
                            VStack(spacing: 4) {
                                Text("Est. runtime").microLabel()
                                Text("2.3")
                                    .font(Theme.Fonts.heroRing)
                                    .foregroundStyle(Theme.Colors.textPrimary)
                                Text("hours · 136 min")
                                    .font(Theme.Fonts.archivo(15))
                                    .foregroundStyle(Theme.Colors.textSecondary)
                            }
                        }
                        Spacer()
                    }
                    Text("Ring shows share of a 10-hour day")
                        .font(Theme.Fonts.subLabel)
                        .foregroundStyle(Theme.Colors.textQuaternary)
                        .frame(maxWidth: .infinity)
                    HStack(spacing: 8) {
                        StatTile(label: "Draw", value: "39.0", unit: "W")
                        StatTile(label: "Capacity", value: "98", unit: "Wh")
                        StatTile(label: "Efficiency", value: "90", unit: "%")
                    }
                }
                .padding(.top, 12)

                ThemedSectionHeader(title: "1 · Camera")
                GroupedCard {
                    SettingRow("Brand", value: "Sony", chevron: true) { showSheet = true }
                    RowDivider()
                    SettingRow("Model", value: "FX6", chevron: true) { }
                    RowDivider()
                    SettingRow("Power draw", value: "19.0 W", mono: true, valueColor: Theme.Colors.textPrimary)
                }

                ThemedSectionHeader(title: "3 · Power")
                GroupedCard {
                    SettingRow("Number of batteries") {
                        StepperPill(value: count,
                                    canDecrement: count > 1,
                                    onDecrement: { count -= 1 },
                                    onIncrement: { count += 1 })
                    }
                    RowDivider()
                    SettingRow("Temp & battery age", subLabel: "Base calculation uses 90% efficiency") {
                        Toggle("", isOn: $advanced).labelsHidden().themedControlTint()
                    }
                    if advanced {
                        RowDivider()
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Ambient temperature")
                                    .font(Theme.Fonts.body)
                                    .foregroundStyle(Theme.Colors.textPrimary)
                                Spacer()
                                Text("\(Int(temp))°C · 100%")
                                    .font(Theme.Fonts.rowValue)
                                    .foregroundStyle(Theme.Colors.textTertiary)
                            }
                            Slider(value: $temp, in: -20...50, step: 1)
                                .tint(Theme.Colors.paper)
                        }
                        .padding(Theme.Spacing.rowPadding)
                    }
                }

                ThemedSectionHeader(title: "Camera 1", dotColor: Theme.Colors.rose,
                                    actionTitle: "Remove", action: { })
                GroupedCard {
                    SettingRow("Codec", value: "XAVC-I 4K 25p", chevron: true) { }
                }

                VStack(spacing: 12) {
                    PrimaryButton("Save to Kit Bag") { }
                    OutlineButton("+ Add camera") { }
                    TextLink("Missing kit? Request an addition") { }
                }
                .padding(.top, 24)

                // Home
                ThemedSectionHeader(title: "Home")
                ToolCard(code: "BAT.01 · Battery", title: "Runtime",
                         value: "2.3", unit: "hrs",
                         detail: ["FX6", "39.0 W draw"], style: .hero)
                HStack(spacing: 12) {
                    ToolCard(code: "DAT.01 · Data", title: "Storage",
                             value: "1.29", unit: "TB", summary: "2 cams · 2 hrs")
                    ToolCard(code: "TRF.01 · Transfer", title: "Offload",
                             summary: "Drive to drive offload times")
                }
                .padding(.top, 12)

                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        KitStoryRing(kind: .setup(tag: "FX6"), name: "FX6 Doc")
                        KitStoryRing(kind: .setup(tag: "MINI"), name: "Mini Interview")
                        KitStoryRing(kind: .new)
                    }
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, Theme.Spacing.cardMargin)
            .padding(.bottom, 40)
        }
        .themedScreen()
        .sheet(isPresented: $showSheet) {
            SheetScaffold(title: "Brand", onDone: { showSheet = false }) {
                VStack(spacing: 16) {
                    SelectionList(options: brands, selectedID: selectedBrand) { selectedBrand = $0 }
                    MultiSelectList(options: brands,
                                    isSelected: { picked.contains($0) },
                                    onToggle: { id in
                                        if picked.contains(id) { picked.remove(id) } else { picked.insert(id) }
                                    }) { id in
                        if picked.contains(id) {
                            HStack {
                                Text("Quantity")
                                    .font(Theme.Fonts.subLabel)
                                    .foregroundStyle(Theme.Colors.textTertiary)
                                Spacer()
                                StepperPill(value: 1, onDecrement: { }, onIncrement: { }, diameter: 34)
                            }
                            .padding(.horizontal, Theme.Spacing.rowPadding)
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
            .themedSheet()
        }
    }
}

#Preview("v4 components") {
    ComponentGallery()
        .preferredColorScheme(.dark)
}
#endif
