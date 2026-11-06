//
//  HomePageView.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//  Restyle v4: bento Home (Battery hero card, Data / Transfer tiles, Kit Bag rings).
//

import SwiftUI

struct HomePageView: View {
    @StateObject var settings = UserSettings()

    /// Set when a Kit Bag ring is tapped: loads that setup, then opens Battery
    @State private var openBatteryFromKit = false

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
                                 title: "Runtime",
                                 summary: "Runtime for your camera build",
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
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .themedScreen()
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

            NavigationLink {
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
                NavigationLink {
                    UserSettingsView()
                        .environmentObject(settings)
                } label: {
                    Text("See all")
                        .font(Theme.Fonts.archivo(15))
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
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
                        UserSettingsView()
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
        let brands = CameraDatabase.shared.getCameraForBatteryCalc()
        guard brands.indices.contains(settings.batteryCalcBrand),
              brands[settings.batteryCalcBrand].models.indices.contains(settings.batteryCalcModel)
        else { return nil }
        return brands[settings.batteryCalcBrand].models[settings.batteryCalcModel]
    }

    /// Camera + accessories draw — same per-item rule as BatteryCalculatorView.totalPowerDraw
    private var batteryDetail: [String] {
        guard let camera = batteryCamera else { return [] }
        let accessories = CameraDatabase.shared.getAccessories()
        let accessoriesDraw = settings.batteryCalcAccessories.reduce(0.0) { total, index in
            guard index < accessories.count else { return total }
            let accessory = accessories[index]
            if accessory.category.supportsQuantity {
                let quantity = settings.focusSystemQuantities[index] ?? 1
                return total + (accessory.powerDraw * Double(quantity))
            } else {
                return total + accessory.powerDraw
            }
        }
        return [camera.model, String(format: "%.1f W draw", camera.powerDraw + accessoriesDraw)]
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
        let brands = CameraDatabase.shared.getCameraForBatteryCalc()
        guard brands.indices.contains(setup.brand),
              brands[setup.brand].models.indices.contains(setup.model)
        else { return "KIT" }
        return brands[setup.brand].models[setup.model].model.uppercased()
    }
}

// Preview
#Preview {
    HomePageView()
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
