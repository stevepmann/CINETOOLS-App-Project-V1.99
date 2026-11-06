//
//  HomePageView.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//  Restyle v4: bento Home (Battery hero card, Data / Transfer tiles, Kit Bag rings).
//

import SwiftUI

struct HomePageView: View {
    /// Owned by MainTabView and shared with every tab
    @EnvironmentObject var settings: UserSettings
    /// Switches tabs when hosted in MainTabView (nil in previews)
    @Environment(\.selectTab) private var selectTab

    /// Set when a Kit Bag ring is tapped: loads that setup, then opens Battery
    @State private var openBatteryFromKit = false

    /// Last battery / count used on the Battery screen (saved there)
    @AppStorage(BatteryCalculatorView.lastBatteryKey) private var lastBatteryIndex = 0
    @AppStorage(BatteryCalculatorView.lastBatteryQuantityKey) private var lastBatteryQuantity = 1

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    topBar
                        .padding(.bottom, 8)

                    // Battery
                    NavigationLink {
                        BatteryCalculatorView()
                            .environmentObject(settings)
                    } label: {
                        ToolCard(code: "BAT.01 · Battery",
                                 title: "Camera Runtime",
                                 value: batteryRuntime.map { String(format: "%.1f", $0) },
                                 unit: batteryRuntime == nil ? nil : "hrs",
                                 summary: batterySummary,
                                 detail: batteryDetail,
                                 style: .hero)
                    }
                    .buttonStyle(.plain)

                    // Data + Transfer
                    HStack(alignment: .top, spacing: 12) {
                        NavigationLink {
                            DataCalculatorView()
                                .environmentObject(settings)
                        } label: {
                            ToolCard(code: "DAT.01 · Data",
                                     title: "Storage",
                                     value: storageValue?.value,
                                     unit: storageValue?.unit,
                                     summary: storageSummary)
                                .frame(maxHeight: .infinity)
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            DataTransferView()
                        } label: {
                            ToolCard(code: "TRF.01 · Transfer",
                                     title: "Offload",
                                     summary: "Offload times by drive and connection")
                                .frame(maxHeight: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    kitBagRow
                        .padding(.top, 20)
                }
                .padding(.horizontal, Theme.Spacing.cardMargin)
                .padding(.top, 8)
                .padding(.bottom, 120) // room for the floating tab bar
            }
            .scrollIndicators(.hidden)
            .themedScreen()
            .countsAsTabRoot()
            .navigationDestination(isPresented: $openBatteryFromKit) {
                BatteryCalculatorView()
                    .environmentObject(settings)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .environmentObject(settings)
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack {
            Image("CineToolsIcon")
                .resizable()
                .scaledToFill()
                .frame(width: Theme.Size.appIcon, height: Theme.Size.appIcon)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.appIcon, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.appIcon, style: .continuous)
                        .stroke(Theme.Colors.separator, lineWidth: 1)
                )
                .accessibilityLabel("CineTools")

            Spacer()

            tabOrPushLink(.support) {
                SupportPageView()
            } label: {
                Text("Support")
                    .font(Theme.Fonts.archivo(15, .medium))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .padding(.horizontal, 16)
                    .frame(height: Theme.Size.supportPillHeight)
                    .background(Theme.Colors.card, in: Capsule())
                    .frame(minHeight: Theme.Size.tapTarget)
            }
        }
    }

    // MARK: Tab-or-push link

    /// Switches to `tab` when hosted in the tab bar; otherwise pushes `destination`.
    @ViewBuilder
    private func tabOrPushLink<Destination: View, Label: View>(
        _ tab: AppTab,
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: () -> Label
    ) -> some View {
        if let selectTab {
            Button { selectTab(tab) } label: { label() }
                .buttonStyle(.plain)
        } else {
            NavigationLink(destination: destination, label: label)
                .buttonStyle(.plain)
        }
    }

    // MARK: Kit Bag rings

    private var kitBagRow: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Kit Bag")
                    .font(Theme.Fonts.archivo(22, .semibold))
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                tabOrPushLink(.kitBag) {
                    UserSettingsView()
                        .environmentObject(settings)
                } label: {
                    Text("See all")
                        .font(Theme.Fonts.archivo(15))
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
            }

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(settings.savedSetups) { setup in
                        Button {
                            settings.activateSetup(setup)
                            openBatteryFromKit = true
                        } label: {
                            KitStoryRing(kind: .setup(tag: ringTag(for: setup)), name: setup.name)
                        }
                        .buttonStyle(.plain)
                    }

                    NavigationLink {
                        UserSettingsView(startsWithEditor: true)
                            .environmentObject(settings)
                    } label: {
                        KitStoryRing(kind: .new)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: Display-only summaries
    // These look up saved selections and use the same rules as the calculators.
    // Index lookups are guarded so a stale saved index can never crash Home.

    private var batteryCamera: Camera? {
        KitSummary.camera(brand: settings.batteryCalcBrand, model: settings.batteryCalcModel)
    }

    /// Camera + accessories draw — same rule as the Battery screen (see KitSummary)
    private var batteryDraw: Double? {
        KitSummary.drawWatts(brand: settings.batteryCalcBrand,
                             model: settings.batteryCalcModel,
                             accessories: settings.batteryCalcAccessories,
                             quantities: settings.focusSystemQuantities)
    }

    private var savedBattery: Battery? {
        let batteries = BatteryCalculatorView.batteryList
        return batteries.indices.contains(lastBatteryIndex) ? batteries[lastBatteryIndex] : nil
    }

    private var savedBatteryQuantity: Int {
        (1...20).contains(lastBatteryQuantity) ? lastBatteryQuantity : 1
    }

    /// Same expression as the Battery screen's base runtime (see KitSummary)
    private var batteryRuntime: Double? {
        guard let battery = savedBattery, let draw = batteryDraw else { return nil }
        return KitSummary.runtimeHours(draw: draw, battery: battery, quantity: savedBatteryQuantity)
    }

    private var batterySummary: String {
        guard let battery = savedBattery else { return "Runtime for your camera build" }
        return "on \(savedBatteryQuantity)× \(battery.model)"
    }

    private var batteryDetail: [String] {
        guard let camera = batteryCamera, let draw = batteryDraw else { return [] }
        return [camera.model, String(format: "%.1f W draw", draw)]
    }

    /// Total storage — same expression as DataCalculatorView.totalStorageRequired
    private var storageGB: Double? {
        let cameras = CameraDatabase.shared.getCameraForDataCalc()

        func gigabytes(brand: Int, model: Int, codec: Int) -> Double? {
            guard cameras.indices.contains(brand),
                  cameras[brand].models.indices.contains(model),
                  cameras[brand].models[model].codecs.indices.contains(codec)
            else { return nil }
            return cameras[brand].models[model].codecs[codec].bitrate * 0.45 * settings.recordingHours
        }

        guard var total = gigabytes(brand: settings.dataCalcBrand,
                                    model: settings.dataCalcModel,
                                    codec: settings.dataCalcCodec)
        else { return nil }

        for camera in settings.additionalCameras {
            guard let value = gigabytes(brand: camera.brand, model: camera.model, codec: camera.codec)
            else { return nil }
            total += value
        }
        return total
    }

    /// Same TB / GB switch as the Data screen
    private var storageValue: (value: String, unit: String)? {
        guard let gb = storageGB else { return nil }
        if gb >= 1000 {
            return (String(format: "%.2f", gb / 1000), "TB")
        }
        return (String(format: "%.1f", gb), "GB")
    }

    private var storageSummary: String {
        let count = settings.additionalCameras.count + 1
        let cams = count == 1 ? "1 cam" : "\(count) cams"
        return "\(cams) · " + String(format: "%g hrs", settings.recordingHours)
    }

    private func ringTag(for setup: KitSetup) -> String {
        KitSummary.camera(brand: setup.brand, model: setup.model)?.model.uppercased() ?? "KIT"
    }
}

// Preview
#Preview {
    HomePageView()
        .environmentObject(UserSettings())
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .environmentObject(UserSettings())
    }
}
