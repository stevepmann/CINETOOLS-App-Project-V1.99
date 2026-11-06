//
//  DataTransferView.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//

import SwiftUI
import Foundation

struct DataTransferView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSpeed = 0
    @State private var selectedSourceDrive = 0
    @State private var isEditingDataAmount = false
    @State private var dataAmountString = "100"  // String for text input
    @State private var dataAmount = 100.0  // Double for calculations
    @State private var isOverLimit = false
    @State private var customReadSpeed: String = ""
    @State private var isCustomDrive = false
    @State private var isCustomSpeedOverLimit = false

    // MARK: Restyle v4 — presentation state only
    @Environment(\.openURL) private var openURL
    @State private var activeSheet: TransferSheet? = nil
    
    let transferSpeeds = [
        TransferSpeed(name: "USB 2.0", speedMbps: 240),
        TransferSpeed(name: "USB 3.0", speedMbps: 2400),
        TransferSpeed(name: "USB 3.1", speedMbps: 6400),
        TransferSpeed(name: "USB 3.2", speedMbps: 16000),
        TransferSpeed(name: "Thunderbolt 3", speedMbps: 20000),
        TransferSpeed(name: "Thunderbolt 4", speedMbps: 40000)
    ]
    
    let drives = [
        DriveSpeed(name: "LaCie Rugged", readSpeedMbps: 1100, writeSpeedMbps: 1000, type: "HDD"),
        DriveSpeed(name: "Samsung T7", readSpeedMbps: 8000, writeSpeedMbps: 7000, type: "Portable SSD"),
        DriveSpeed(name: "Samsung T5", readSpeedMbps: 4000, writeSpeedMbps: 3800, type: "Portable SSD"),
        DriveSpeed(name: "SanDisk Extreme Pro", readSpeedMbps: 16000, writeSpeedMbps: 15200, type: "Portable SSD"),
        DriveSpeed(name: "G-Drive Mobile", readSpeedMbps: 1000, writeSpeedMbps: 950, type: "HDD"),
        DriveSpeed(name: "WD Elements", readSpeedMbps: 1200, writeSpeedMbps: 1100, type: "HDD"),
        DriveSpeed(name: "CFexpress Card Type A", readSpeedMbps: 5600, writeSpeedMbps: 5000, type: "Memory Card"),
        DriveSpeed(name: "CFexpress Card Type B", readSpeedMbps: 13600, writeSpeedMbps: 13000, type: "Memory Card"),
        DriveSpeed(name: "Standard Internal Mac SSD", readSpeedMbps: 28000, writeSpeedMbps: 28000, type: "Internal Drive"),
        DriveSpeed(name: "SD UHS-II Card", readSpeedMbps: 300, writeSpeedMbps: 250, type: "Memory Card"),
        DriveSpeed(name: "External NVME SSD Enclosure", readSpeedMbps: 38000, writeSpeedMbps: 38000, type: "HDD"),
        DriveSpeed(name: "Custom Drive Speed", readSpeedMbps: 0, writeSpeedMbps: 0, type: "Custom")
    ]
    
    private var effectiveTransferSpeed: Double {
        let connectionSpeed = transferSpeeds[selectedSpeed].speedMbps
        let sourceReadSpeed: Double
        
        if selectedSourceDrive == drives.count - 1 && isCustomDrive {
            // Use custom speed if valid
            sourceReadSpeed = Double(customReadSpeed) ?? 0
        } else {
            sourceReadSpeed = drives[selectedSourceDrive].readSpeedMbps
        }
        
        return min(connectionSpeed, sourceReadSpeed)
    }
    
    private var transferTimeMinutes: Double {
        let speedGBps = effectiveTransferSpeed / 8000 // Convert Mbps to GB/s
        return dataAmount / speedGBps / 60 // Convert to minutes
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ThemedBackButton(title: "Tools") {
                        dismiss()
                    }
                    .padding(.horizontal, Theme.Spacing.titleMargin)
                    .padding(.top, 4)

                    ScreenTitle(text: "Transfer Speed")
                        .padding(.top, 4)

                    VStack(spacing: 0) {
                        transferHero
                            .padding(.top, 16)
                        setupSection
                        dataAmountSection

                        TextLink("Request a drive or connection") {
                            if let url = URL(string: "mailto:app@stevepmann.com") {
                                openURL(url)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, Theme.Spacing.cardMargin)
                    .padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .themedScreen()
            .sheet(item: $activeSheet) { sheet in
                sheetContent(for: sheet)
                    .themedSheet()
            }
            .navigationBarHidden(true)
        }
        // Moved from the old Source picker (unchanged)
        .onChange(of: selectedSourceDrive) { oldValue, newValue in
            isCustomDrive = newValue == drives.count - 1
        }
        .onChange(of: dataAmountString) { oldValue, newValue in
            // Only allow numbers and decimal point
            let filtered = newValue.filter { "0123456789.".contains($0) }
            if filtered != newValue {
                dataAmountString = filtered
            }
            
            // Update dataAmount if valid
            if let value = Double(filtered) {
                // Check if over limit
                isOverLimit = value > 5000
                
                // Clamp the value
                dataAmount = min(max(value, 0), 5000)
            }
        }
        .onChange(of: customReadSpeed) { oldValue, newValue in
            // Only allow numbers
            let filtered = newValue.filter { "0123456789".contains($0) }
            if filtered != newValue {
                customReadSpeed = filtered
            }
            
            // Check if over limit (100,000 Mbps)
            if let value = Double(filtered) {
                isCustomSpeedOverLimit = value > 100000
            }
        }
    }
}

// MARK: - Restyle v4: Transfer screen sections
//
// Presentation only. The time comes from the existing transferTimeMinutes and
// effectiveTransferSpeed. Text-field filtering / limits stay in the existing onChange handlers.

enum TransferSheet: String, Identifiable {
    case source, connection
    var id: String { rawValue }
}

extension DataTransferView {

    // MARK: Display-only speeds (the same inputs effectiveTransferSpeed takes the min() of)

    private var displayConnectionSpeed: Double {
        transferSpeeds[selectedSpeed].speedMbps
    }

    private var displaySourceReadSpeed: Double {
        if selectedSourceDrive == drives.count - 1 && isCustomDrive {
            return Double(customReadSpeed) ?? 0
        }
        return drives[selectedSourceDrive].readSpeedMbps
    }

    /// The slower of the two is the bottleneck (matches min() in effectiveTransferSpeed)
    private var driveIsBottleneck: Bool {
        displaySourceReadSpeed < displayConnectionSpeed
    }

    private func mbps(_ value: Double) -> String {
        "\(String(format: "%.0f", value)) Mbps"
    }

    // MARK: Hero

    var transferHero: some View {
        ResultHero {
            Text("Estimated transfer time")
                .microLabel()

            VStack(alignment: .leading, spacing: 2) {
                if transferTimeMinutes >= 60 {
                    HeroNumber(value: String(format: "%.1f", transferTimeMinutes / 60), unit: "hrs")
                    Text(String(format: "%.1f min", transferTimeMinutes))
                        .font(Theme.Fonts.mono(15))
                        .foregroundStyle(Theme.Colors.textTertiary)
                } else {
                    HeroNumber(value: String(format: "%.1f", transferTimeMinutes), unit: "min")
                }
            }

            VStack(spacing: 14) {
                SpeedBar(label: "Drive read",
                         value: mbps(displaySourceReadSpeed),
                         fraction: fraction(displaySourceReadSpeed),
                         isBottleneck: driveIsBottleneck)
                SpeedBar(label: "Connection",
                         value: mbps(displayConnectionSpeed),
                         fraction: fraction(displayConnectionSpeed),
                         isBottleneck: !driveIsBottleneck)
            }

            Text(driveIsBottleneck
                 ? "Limited by the drive's read speed — a faster drive or card would help."
                 : "Limited by the connection — a faster cable or port would help.")
                .font(Theme.Fonts.archivo(15))
                .foregroundStyle(Theme.Colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func fraction(_ speed: Double) -> Double {
        let top = max(displaySourceReadSpeed, displayConnectionSpeed)
        guard top > 0 else { return 0 }
        return speed / top
    }

    // MARK: Setup

    var setupSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "Setup")
            GroupedCard {
                SettingRow("Source",
                           subLabel: isCustomDrive ? "Custom read speed" : "Read \(mbps(drives[selectedSourceDrive].readSpeedMbps))",
                           value: drives[selectedSourceDrive].name,
                           chevron: true) {
                    activeSheet = .source
                }

                if isCustomDrive {
                    RowDivider()
                    SettingRow("Custom speed",
                               subLabel: isCustomSpeedOverLimit ? "Max 100,000 Mbps" : nil) {
                        HStack(spacing: 6) {
                            TextField("0", text: $customReadSpeed)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .font(Theme.Fonts.mono(17))
                                .foregroundStyle(isCustomSpeedOverLimit ? Theme.Colors.roseSmallOnInk : Theme.Colors.textPrimary)
                                .frame(width: 100)
                            Text("Mbps")
                                .font(Theme.Fonts.mono(15))
                                .foregroundStyle(isCustomSpeedOverLimit ? Theme.Colors.roseSmallOnInk : Theme.Colors.textTertiary)
                        }
                        .padding(.horizontal, 12)
                        .frame(minHeight: 36)
                        .background(Theme.Colors.cardRaised, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .offset(y: isCustomSpeedOverLimit ? -3 : 0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isCustomSpeedOverLimit)
                    }
                }

                RowDivider()
                SettingRow("Connection",
                           subLabel: "Effective \(mbps(effectiveTransferSpeed))",
                           value: transferSpeeds[selectedSpeed].name,
                           chevron: true) {
                    activeSheet = .connection
                }
            }
        }
    }

    // MARK: Data amount (typed field kept)

    var dataAmountSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "Data amount")
            GroupedCard {
                SettingRow("To offload",
                           subLabel: isOverLimit ? "Max 5,000 GB" : nil) {
                    HStack(spacing: 6) {
                        TextField("0.0", text: $dataAmountString)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .font(Theme.Fonts.mono(22))
                            .foregroundStyle(isOverLimit ? Theme.Colors.roseSmallOnInk : Theme.Colors.textPrimary)
                            .frame(width: 110)
                        Text("GB")
                            .font(Theme.Fonts.mono(17))
                            .foregroundStyle(isOverLimit ? Theme.Colors.roseSmallOnInk : Theme.Colors.textTertiary)
                    }
                    .padding(.horizontal, 12)
                    .frame(minHeight: 40)
                    .background(Theme.Colors.cardRaised, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .offset(y: isOverLimit ? -3 : 0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isOverLimit)
                }
            }
        }
    }

    // MARK: Sheets

    @ViewBuilder
    func sheetContent(for sheet: TransferSheet) -> some View {
        switch sheet {
        case .source:
            SheetScaffold(title: "Source", onDone: { activeSheet = nil }) {
                SelectionList(
                    options: drives.indices.map { index in
                        let drive = drives[index]
                        return PickerOption(id: index,
                                            title: drive.name,
                                            subtitle: drive.type == "Custom"
                                                ? "Enter your own read speed"
                                                : "\(drive.type) · \(mbps(drive.readSpeedMbps))")
                    },
                    selectedID: selectedSourceDrive
                ) { id in
                    selectedSourceDrive = id
                    activeSheet = nil
                }
            }
        case .connection:
            SheetScaffold(title: "Connection", onDone: { activeSheet = nil }) {
                SelectionList(
                    options: transferSpeeds.indices.map { index in
                        PickerOption(id: index,
                                     title: transferSpeeds[index].name,
                                     subtitle: mbps(transferSpeeds[index].speedMbps))
                    },
                    selectedID: selectedSpeed
                ) { id in
                    selectedSpeed = id
                    activeSheet = nil
                }
            }
        }
    }
}

/// Labelled horizontal speed bar. The bottleneck bar (and its value) is rose.
fileprivate struct SpeedBar: View {
    let label: String
    let value: String
    let fraction: Double
    let isBottleneck: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(Theme.Fonts.archivo(15))
                    .foregroundStyle(Theme.Colors.textSecondary)
                if isBottleneck {
                    Text("Bottleneck")
                        .microLabel(10, color: Theme.Colors.roseSmallOnInk)
                }
                Spacer()
                Text(value)
                    .font(Theme.Fonts.mono(15))
                    .foregroundStyle(isBottleneck ? Theme.Colors.roseSmallOnInk : Theme.Colors.textTertiary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.Colors.cardRaised)
                    Capsule()
                        .fill(isBottleneck ? Theme.Colors.rose : Theme.Colors.trackInactive)
                        .frame(width: proxy.size.width * CGFloat(min(max(fraction.isFinite ? fraction : 0, 0), 1)))
                }
            }
            .frame(height: 10)
            .animation(Theme.Motion.result, value: fraction)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DataTransferView()
} 
