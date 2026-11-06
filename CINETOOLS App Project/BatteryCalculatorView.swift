//
//  ContentView.swift
//  Camera Battery Calculator
//
//  Created by steven mann on 29/01/2025.
//

import SwiftUI
import Foundation
import Combine

// First, let's create a separate view for the runtime display
struct RuntimeDisplayCard: View {
    let runtime: Double
    let totalPowerDraw: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Estimated Runtime")
                .font(.subheadline)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", runtime))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("hours")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Text(String(format: "%.0f minutes", runtime * 60))
                .font(.title3)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            
            HStack {
                Label("\(String(format: "%.1f", totalPowerDraw))W", systemImage: "bolt.fill")
                    .foregroundStyle(.orange)
                    .font(.headline)
                    .monospacedDigit()
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal)
    }
}

// Create a separate view for the accessories section
struct AccessoriesSection: View {
    @Binding var selectedAccessories: Set<Int>
    @Binding var focusSystemQuantities: [Int: Int]
    @EnvironmentObject var settings: UserSettings
    let accessories: [Accessory]
    // Accessory indices sorted A–Z by name (keeps original indices so saved selections still match)
    private var sortedAccessoryIndices: [Int] {
        accessories.indices.sorted {
            accessories[$0].name.localizedCaseInsensitiveCompare(accessories[$1].name) == .orderedAscending
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(AccessoryCategory.allCases, id: \.self) { category in
                DisclosureGroup {
                    VStack(spacing: 12) {
                        ForEach(sortedAccessoryIndices, id: \.self) { index in
                            if accessories[index].category == category {
                                VStack(alignment: .leading, spacing: 8) {
                                    ModernAccessoryToggle(
                                        accessory: accessories[index],
                                        isSelected: selectedAccessories.contains(index),
                                        action: {
                                            if selectedAccessories.contains(index) {
                                                selectedAccessories.remove(index)
                                                if accessories[index].category.supportsQuantity {
                                                    focusSystemQuantities.removeValue(forKey: index)
                                                }
                                            } else {
                                                selectedAccessories.insert(index)
                                                if accessories[index].category.supportsQuantity {
                                                    focusSystemQuantities[index] = settings.focusSystemQuantities[index] ?? 1
                                                }
                                            }
                                        }
                                    )
                                    
                                    if accessories[index].category.supportsQuantity && selectedAccessories.contains(index) {
                                        HStack {
                                            Text("Quantity")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 12) {
                                                Button(action: {
                                                    if let current = focusSystemQuantities[index] ?? settings.focusSystemQuantities[index], current > 1 {
                                                        focusSystemQuantities[index] = current - 1
                                                    }
                                                }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundStyle(.gray)
                                                }
                                                
                                                Text("\(focusSystemQuantities[index] ?? settings.focusSystemQuantities[index] ?? 1)")
                                                    .font(.headline)
                                                    .monospacedDigit()
                                                    .frame(minWidth: 30)
                                                
                                                Button(action: {
                                                    let current = focusSystemQuantities[index] ?? settings.focusSystemQuantities[index] ?? 1
                                                    if current < 99 {
                                                        focusSystemQuantities[index] = current + 1
                                                    }
                                                }) {
                                                    Image(systemName: "plus.circle.fill")
                                                        .foregroundStyle(.blue)
                                                }
                                            }
                                        }
                                        .padding(.leading, 36)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                } label: {
                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                if category != AccessoryCategory.allCases.last {
                    Divider()
                }
            }
        }
    }
}

struct BatteryCalculatorView: View {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentBrand: Int
    @State private var currentModel: Int
    @State private var currentAccessories: Set<Int>
    @State private var selectedBattery = 0
    @State private var batteryQuantity = 1
    
    // Add state to track if we're just navigating pickers
    @State private var isNavigatingPicker = false
    
    // Add a state to track if we're navigating to advanced calculator
    @State private var isNavigatingToAdvanced = false
    
    // Add a state to track if we're in a picker view
    @State private var isInPickerView = false
    
    // Add a state to track if we're actually leaving the view
    @State private var isLeavingView = false
    
    // Add local state for focus system quantities
    @State private var localFocusSystemQuantities: [Int: Int] = [:]

    // MARK: Restyle v4 — presentation state only
    @Environment(\.openURL) private var openURL
    @State private var activeSheet: BatterySheet? = nil
    /// Brand sheet moves straight on to the model list after a brand is picked
    @State private var cameraSheetShowsModels = false

    // MARK: Advanced (inline) — state moved from AdvancedBatteryCalculatorView
    @State private var isAdvancedOn = false
    @State private var ambientTemperature = 20.0 // Default 20°C
    @State private var batteryAge = 1.0 // Default 1 year
    
    let cameraBrands = CameraDatabase.shared.getCameraForBatteryCalc()
    let accessories = CameraDatabase.shared.getAccessories()
    let batteries = [
        Battery(model: "98Wh", wattHours: 98, voltage: 14.8),
        Battery(model: "150Wh", wattHours: 150, voltage: 14.8),
        Battery(model: "11Wh (Canon LP-E6)", wattHours: 11, voltage: 7.4),
        Battery(model: "16Wh (Nikon EN-EL15c Nikon ZR)", wattHours: 16, voltage: 7.2),
        Battery(model: "16.4Wh (NP-FZ100 Sony A7iii, FX30)", wattHours: 16.4, voltage: 7.2),
        Battery(model: "28Wh (BP-U30)", wattHours: 28, voltage: 14.8),
        Battery(model: "36Wh (Nikon EN-EL18d)", wattHours: 28, voltage: 10.8),
        Battery(model: "50Wh", wattHours: 50, voltage: 14.8),
        Battery(model: "56Wh (BP-U60)", wattHours: 50, voltage: 14.8),
        Battery(model: "95W Hawkwoods SA-95 Smart Audio Battery", wattHours: 95, voltage: 14.4),
        Battery(model: "97.58Wh (DJI TB50 Ronin 2, 4D)", wattHours: 98, voltage: 14.8),
        Battery(model: "240Wh", wattHours: 240, voltage: 14.8),
        Battery(model: "290Wh", wattHours: 290, voltage: 14.8),
        Battery(model: "420Wh", wattHours: 420, voltage: 14.8),
        Battery(model: "1200Wh (BeBob CUBE 1200)", wattHours: 1200, voltage: 14.8),
        Battery(model: "1600Wh (Anton Bauer VCLX)", wattHours: 1600, voltage: 14.8)
    ]
    
    // Add computed properties for safe indices
    private var safeBrand: Int {
        min(currentBrand, max(0, cameraBrands.count - 1))
    }
    
    private var safeModel: Int {
        min(currentModel, max(0, cameraBrands[safeBrand].models.count - 1))
    }
    
    // Update computed properties to use safe indices
    private var totalPowerDraw: Double {
        let cameraDraw = cameraBrands[safeBrand].models[safeModel].powerDraw
        let accessoriesDraw = currentAccessories.reduce(0.0) { total, index in
            guard index < accessories.count else { return total }
            let accessory = accessories[index]
            if accessory.category.supportsQuantity {
                let quantity = localFocusSystemQuantities[index] ?? settings.focusSystemQuantities[index] ?? 1
                return total + (accessory.powerDraw * Double(quantity))
            } else {
                return total + accessory.powerDraw
            }
        }
        return cameraDraw + accessoriesDraw
    }
    
    private var runtime: Double {
        let battery = batteries[selectedBattery]
        return (battery.wattHours * 0.90 * Double(batteryQuantity)) / totalPowerDraw
    }

    // MARK: Advanced factors — copied verbatim from AdvancedBatteryCalculatorView (unchanged)

    // Temperature efficiency factor (simplified model)
    private var temperatureEfficiencyFactor: Double {
        // Efficiency factors for different temperature ranges
        switch ambientTemperature {
            case ..<(-20):  return 0.65  // Below -20°C
            case -20..<(-10): return 0.70  // -20°C to -10°C
            case -10..<0:   return 0.80  // -10°C to 0°C
            case 0..<10:    return 0.90  // 0°C to 10°C
            case 10..<20:   return 0.95  // 10°C to 20°C
            case 20..<30:   return 1.00  // 20°C to 30°C (Optimal)
            case 30..<40:   return 0.95  // 30°C to 40°C
            case 40..<50:   return 0.90  // 40°C to 50°C
            case 50...:     return 0.85  // Above 50°C
            default:        return 1.00  // Fallback
        }
    }

    // Battery age efficiency factor
    private var ageEfficiencyFactor: Double {
        // Simplified model: Battery capacity decreases by about 20% after 500 cycles (roughly 2 years of regular use)
        let ageFactor = max(1.0 - (batteryAge * 0.12), 0.2) // Maximum degradation of 40%
        return ageFactor
    }

    private var advancedRuntime: Double {
        let battery = batteries[selectedBattery]
        let baseEfficiency = 0.90 // Base Li-ion efficiency
        let totalEfficiency = baseEfficiency * temperatureEfficiencyFactor * ageEfficiencyFactor
        let effectiveWattHours = battery.wattHours * totalEfficiency * Double(batteryQuantity)
        return effectiveWattHours / totalPowerDraw
    }

    // MARK: Display-only values (pick which existing result to show; no new maths)

    private var displayedRuntime: Double {
        isAdvancedOn ? advancedRuntime : runtime
    }

    private var displayedEfficiency: Double {
        isAdvancedOn ? 0.90 * temperatureEfficiencyFactor * ageEfficiencyFactor : 0.90
    }
    
    // Keep only these working sorted indices
    private var sortedBrandIndices: [Int] {
        let indices = cameraBrands.indices.sorted { 
            cameraBrands[$0].name.lowercased() < cameraBrands[$1].name.lowercased() 
        }
        return indices
    }
    
    private var sortedModelIndices: [Int] {
        let indices = cameraBrands[safeBrand].models.indices.sorted {
            cameraBrands[safeBrand].models[$0].model.lowercased() < 
            cameraBrands[safeBrand].models[$1].model.lowercased()
        }
        return indices
    }
    
    init(
        currentBrand: Int? = nil,
        currentModel: Int? = nil,
        currentAccessories: Set<Int>? = nil
    ) {
        let settings = UserSettings()
        let cameras = CameraDatabase.shared.getCameraForBatteryCalc()
        
        // Validate brand index
        var brand = currentBrand ?? settings.selectedBrand
        if brand >= cameras.count {
            brand = 0
        }
        
        // Validate model index
        var model = currentModel ?? settings.selectedModel
        if model >= cameras[brand].models.count {
            model = 0
        }
        
        // Validate accessories
        let validAccessories = (currentAccessories ?? settings.selectedAccessories).filter { 
            $0 < CameraDatabase.shared.getAccessories().count 
        }
        
        _currentBrand = State(initialValue: brand)
        _currentModel = State(initialValue: model)
        _currentAccessories = State(initialValue: validAccessories)
        
        // Initialize local quantities as empty - we'll fall back to settings values
        _localFocusSystemQuantities = State(initialValue: [:])
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ThemedBackButton(title: "Tools") {
                        isLeavingView = true  // Set this flag before dismissing
                        dismiss()
                    }
                    .padding(.horizontal, Theme.Spacing.titleMargin)
                    .padding(.top, 4)

                    ScreenTitle(text: "Battery Runtime")
                        .padding(.top, 4)

                    VStack(spacing: 0) {
                        runtimeHero
                            .padding(.top, 16)
                        cameraSection
                        peripheralsSection
                        powerSection
                        advancedSection

                        TextLink("Missing kit? Request an addition") {
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
            .themedScreen()
            .sheet(item: $activeSheet) { sheet in
                sheetContent(for: sheet)
                    .themedSheet()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if !isNavigatingPicker && !isInPickerView {
                currentBrand = settings.batteryCalcBrand
                currentModel = settings.batteryCalcModel
                currentAccessories = settings.batteryCalcAccessories
            }
        }
        .onDisappear {
            // Reset when actually leaving the view (using back button)
            if isLeavingView {
                settings.resetCalculatorStates()
            }
        }
        // Update the onChange handlers
        .onChange(of: currentBrand) { newValue in
            // Only set navigating state if we're actually in the picker
            if isInPickerView {
                isNavigatingPicker = true
            }
            // Validate brand change
            if newValue >= cameraBrands.count {
                currentBrand = 0
            }
            // Reset model when brand changes
            currentModel = 0
            settings.batteryCalcBrand = currentBrand
            settings.batteryCalcModel = currentModel
        }
        .onChange(of: currentModel) { newValue in
            // Only set navigating state if we're actually in the picker
            if isInPickerView {
                isNavigatingPicker = true
            }
            // Validate model change
            if newValue >= cameraBrands[safeBrand].models.count {
                currentModel = 0
            }
            settings.batteryCalcModel = currentModel
        }
        // Update the task modifier
        .task {
            // Only reset navigation state if we were actually in a picker
            if isNavigatingPicker && !isInPickerView {
                isNavigatingPicker = false
            }
        }
        // Update the battery picker onChange handler
        .onChange(of: selectedBattery) { newValue in
            isNavigatingPicker = true
            // Validate battery selection
            if newValue >= batteries.count {
                selectedBattery = 0
            }
        }
    }
}

// MARK: - Restyle v4: Battery screen sections
//
// Presentation only. Every value shown comes from the existing computed properties
// (runtime, totalPowerDraw, batteries, accessories…). Accessory and quantity changes
// below are the same code that lived in AccessoriesSection.

enum BatterySheet: Identifiable, Equatable {
    case camera
    case battery
    case accessories(AccessoryCategory)

    var id: String {
        switch self {
        case .camera: return "camera"
        case .battery: return "battery"
        case .accessories(let category): return "accessories-\(category.rawValue)"
        }
    }
}

extension BatteryCalculatorView {

    // MARK: Hero

    var runtimeHero: some View {
        ResultHero {
            RingGauge(progress: displayedRuntime / 10) {
                VStack(spacing: 2) {
                    Text("Est. runtime")
                        .microLabel()
                    Text(String(format: "%.1f", displayedRuntime))
                        .font(Theme.Fonts.heroRing)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .contentTransition(.numericText())
                        .animation(Theme.Motion.result, value: displayedRuntime)
                    Text("hours · " + String(format: "%.0f min", displayedRuntime * 60))
                        .font(Theme.Fonts.archivo(15))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    // Per-battery information when multiple batteries are selected
                    if batteryQuantity > 1 {
                        Text(String(format: "%.1f hrs per battery", displayedRuntime / Double(batteryQuantity)))
                            .font(Theme.Fonts.subLabel)
                            .foregroundStyle(Theme.Colors.textQuaternary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                .padding(.horizontal, 28)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)

            Text("Ring shows share of a 10-hour day")
                .font(Theme.Fonts.subLabel)
                .foregroundStyle(Theme.Colors.textQuaternary)
                .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                StatTile(label: "Draw",
                         value: String(format: "%.1f", totalPowerDraw),
                         unit: "W")
                StatTile(label: "Capacity",
                         value: String(format: "%g", batteries[selectedBattery].wattHours * Double(batteryQuantity)),
                         unit: "Wh")
                StatTile(label: "Efficiency",
                         value: "\(Int(displayedEfficiency * 100))",
                         unit: "%")
            }
        }
    }

    // MARK: 1 · Camera

    var cameraSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "1 · Camera")
            GroupedCard {
                SettingRow("Brand", value: cameraBrands[safeBrand].name, chevron: true) {
                    cameraSheetShowsModels = false
                    activeSheet = .camera
                }
                RowDivider()
                SettingRow("Model", value: cameraBrands[safeBrand].models[safeModel].model, chevron: true) {
                    cameraSheetShowsModels = true
                    activeSheet = .camera
                }
                RowDivider()
                SettingRow("Power draw",
                           value: String(format: "%.1f W", cameraBrands[safeBrand].models[safeModel].powerDraw),
                           mono: true,
                           valueColor: Theme.Colors.textPrimary)
            }
        }
    }

    // MARK: 2 · Peripherals

    var peripheralsSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "2 · Peripherals")
            GroupedCard {
                ForEach(AccessoryCategory.allCases, id: \.self) { category in
                    let watts = selectedWatts(in: category)
                    SettingRow(category.rawValue, subLabel: selectedNames(in: category)) {
                        activeSheet = .accessories(category)
                    } trailing: {
                        RowValue(text: watts > 0 ? String(format: "%.1f W", watts) : "",
                                 mono: true,
                                 chevron: true)
                    }
                    RowDivider()
                }
                SettingRow("Accessories total",
                           value: String(format: "%.1f W", totalPowerDraw - cameraBrands[safeBrand].models[safeModel].powerDraw),
                           mono: true,
                           valueColor: Theme.Colors.textPrimary)
            }
        }
    }

    // MARK: 3 · Power

    var powerSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "3 · Power")
            GroupedCard {
                SettingRow("Battery", value: batteries[selectedBattery].model, chevron: true) {
                    activeSheet = .battery
                }
                RowDivider()
                SettingRow("Number of batteries") {
                    StepperPill(value: batteryQuantity,
                                canDecrement: batteryQuantity > 1,
                                canIncrement: batteryQuantity < 20,
                                onDecrement: {
                                    if batteryQuantity > 1 {
                                        batteryQuantity -= 1
                                    }
                                },
                                onIncrement: {
                                    if batteryQuantity < 20 {
                                        batteryQuantity += 1
                                    }
                                })
                }
            }
        }
    }

    // MARK: 4 · Advanced (inline)

    var advancedSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "4 · Advanced")
            GroupedCard {
                SettingRow("Temp & battery age", subLabel: "Base calculation uses 90% efficiency") {
                    Toggle("Temp & battery age", isOn: $isAdvancedOn.animation(.snappy))
                        .labelsHidden()
                        .themedControlTint()
                }

                if isAdvancedOn {
                    RowDivider()
                    sliderRow(title: "Ambient temperature",
                              value: "\(Int(ambientTemperature))°C · \(Int(temperatureEfficiencyFactor * 100))%") {
                        Slider(value: $ambientTemperature, in: -20...50, step: 1)
                    }
                    RowDivider()
                    sliderRow(title: "Battery age",
                              value: String(format: "%g yrs", batteryAge) + " · \(Int(ageEfficiencyFactor * 100))%") {
                        Slider(value: $batteryAge, in: 0...5, step: 0.5)
                    }
                }
            }
        }
    }

    private func sliderRow<S: View>(title: String, value: String, @ViewBuilder slider: () -> S) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Text(value)
                    .font(Theme.Fonts.rowValue)
                    .foregroundStyle(Theme.Colors.textTertiary)
                    .contentTransition(.numericText())
            }
            slider()
                .tint(Theme.Colors.paper)
        }
        .padding(.horizontal, Theme.Spacing.rowPadding)
        .padding(.vertical, 14)
    }

    // MARK: Sheets

    @ViewBuilder
    func sheetContent(for sheet: BatterySheet) -> some View {
        switch sheet {
        case .camera:
            if cameraSheetShowsModels {
                SheetScaffold(title: "Model", onDone: { activeSheet = nil }) {
                    SelectionList(options: modelOptions, selectedID: safeModel) { id in
                        currentModel = id
                        activeSheet = nil
                    }
                }
            } else {
                SheetScaffold(title: "Brand", onDone: { activeSheet = nil }) {
                    SelectionList(options: brandOptions, selectedID: safeBrand) { id in
                        currentBrand = id
                        withAnimation(.snappy) { cameraSheetShowsModels = true }
                    }
                }
            }

        case .battery:
            SheetScaffold(title: "Battery", onDone: { activeSheet = nil }) {
                SelectionList(options: batteryOptions, selectedID: selectedBattery) { id in
                    selectedBattery = id
                    activeSheet = nil
                }
            }

        case .accessories(let category):
            SheetScaffold(title: category.rawValue, onDone: { activeSheet = nil }) {
                MultiSelectList(options: accessoryOptions(in: category),
                                isSelected: { currentAccessories.contains($0) },
                                onToggle: { toggleAccessory($0) }) { index in
                    if accessories[index].category.supportsQuantity && currentAccessories.contains(index) {
                        HStack {
                            Text("Quantity")
                                .font(Theme.Fonts.subLabel)
                                .foregroundStyle(Theme.Colors.textTertiary)
                            Spacer()
                            StepperPill(value: accessoryQuantity(index),
                                        canDecrement: accessoryQuantity(index) > 1,
                                        canIncrement: accessoryQuantity(index) < 99,
                                        onDecrement: { decrementQuantity(index) },
                                        onIncrement: { incrementQuantity(index) },
                                        diameter: 34)
                        }
                        .padding(.horizontal, Theme.Spacing.rowPadding)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
    }

    // MARK: Picker options (labels only)

    private var brandOptions: [PickerOption] {
        sortedBrandIndices.map { index in
            let count = cameraBrands[index].models.count
            return PickerOption(id: index,
                                title: cameraBrands[index].name,
                                subtitle: count == 1 ? "1 model" : "\(count) models")
        }
    }

    private var modelOptions: [PickerOption] {
        sortedModelIndices.map { index in
            let camera = cameraBrands[safeBrand].models[index]
            return PickerOption(id: index,
                                title: camera.model,
                                subtitle: String(format: "%.1f W", camera.powerDraw))
        }
    }

    private var batteryOptions: [PickerOption] {
        batteries.indices.map { PickerOption(id: $0, title: batteries[$0].model) }
    }

    /// Accessories in one category, A–Z by name (original indices kept so saved selections still match)
    private func accessoryOptions(in category: AccessoryCategory) -> [PickerOption] {
        accessories.indices
            .filter { accessories[$0].category == category }
            .sorted { accessories[$0].name.localizedCaseInsensitiveCompare(accessories[$1].name) == .orderedAscending }
            .map { PickerOption(id: $0, title: accessories[$0].name,
                                subtitle: String(format: "%.1f W", accessories[$0].powerDraw)) }
    }

    // MARK: Peripheral row summaries (display only)

    private func selectedIndices(in category: AccessoryCategory) -> [Int] {
        currentAccessories
            .filter { $0 < accessories.count && accessories[$0].category == category }
            .sorted { accessories[$0].name.localizedCaseInsensitiveCompare(accessories[$1].name) == .orderedAscending }
    }

    private func selectedNames(in category: AccessoryCategory) -> String {
        let names = selectedIndices(in: category).map { index -> String in
            let quantity = accessoryQuantity(index)
            if accessories[index].category.supportsQuantity && quantity > 1 {
                return "\(accessories[index].name) ×\(quantity)"
            }
            return accessories[index].name
        }
        return names.isEmpty ? "None" : names.joined(separator: ", ")
    }

    /// Same per-item rule as totalPowerDraw, summed for one category
    private func selectedWatts(in category: AccessoryCategory) -> Double {
        selectedIndices(in: category).reduce(0.0) { total, index in
            let accessory = accessories[index]
            if accessory.category.supportsQuantity {
                return total + (accessory.powerDraw * Double(accessoryQuantity(index)))
            } else {
                return total + accessory.powerDraw
            }
        }
    }

    // MARK: Accessory selection & quantities — same logic as AccessoriesSection

    private func accessoryQuantity(_ index: Int) -> Int {
        localFocusSystemQuantities[index] ?? settings.focusSystemQuantities[index] ?? 1
    }

    private func toggleAccessory(_ index: Int) {
        if currentAccessories.contains(index) {
            currentAccessories.remove(index)
            if accessories[index].category.supportsQuantity {
                localFocusSystemQuantities.removeValue(forKey: index)
            }
        } else {
            currentAccessories.insert(index)
            if accessories[index].category.supportsQuantity {
                localFocusSystemQuantities[index] = settings.focusSystemQuantities[index] ?? 1
            }
        }
    }

    private func decrementQuantity(_ index: Int) {
        if let current = localFocusSystemQuantities[index] ?? settings.focusSystemQuantities[index], current > 1 {
            localFocusSystemQuantities[index] = current - 1
        }
    }

    private func incrementQuantity(_ index: Int) {
        let current = localFocusSystemQuantities[index] ?? settings.focusSystemQuantities[index] ?? 1
        if current < 99 {
            localFocusSystemQuantities[index] = current + 1
        }
    }
}

// New Modern Helper Views
struct ModernCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
        .padding(16)
        .frame(maxWidth: .infinity)
        .background {
            if colorScheme == .light {
                Color(white: 2)  // Very light grey for light mode
                    .opacity(40)
            }
            Rectangle()
                .fill(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
    }
}

struct ModernAccessoryToggle: View {
    let accessory: Accessory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(accessory.name)
                    .font(.subheadline)
                Text("\(String(format: "%.1f", accessory.powerDraw))W")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? .green : .secondary)
                .font(.system(size: 22))
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// Helper Views
struct EquipmentCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            content
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct PowerDrawRow: View {
    let value: Double
    var label: String? = nil
    var unit: String = "W"
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(label ?? "Power Draw")
            Spacer()
            Text("\(String(format: "%.1f", value))\(unit)")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}

struct AccessoryToggleRow: View {
    let accessory: Accessory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                Text(accessory.name)
                Spacer()
                Text("\(String(format: "%.1f", accessory.powerDraw))W")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// Add a preview provider with proper environment object
#Preview {
    NavigationStack {
        BatteryCalculatorView()
            .environmentObject(UserSettings())
    }
}
