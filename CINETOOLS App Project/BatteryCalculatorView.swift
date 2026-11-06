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
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 22)  // Add space at the top
                        
                        // Title
                        Text("Camera Rig Runtime Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal)
                        
                        // Camera Section
                        ModernCard {
                            VStack(spacing: 12) {
                                Picker(selection: $currentBrand) {
                                    ForEach(sortedBrandIndices, id: \.self) { index in
                                        Text(cameraBrands[index].name).tag(index)
                                    }
                                } label: {
                                    HStack {
                                        Label {
                                            Text("Brand")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        } icon: {
                                            Image(systemName: "camera.fill")
                                                .foregroundStyle(.green)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary.opacity(0.7))
                                    }
                                }
                                .pickerStyle(.navigationLink)
                                .onAppear { isInPickerView = true }
                                .onDisappear { isInPickerView = false }
                                
                                Divider()
                                
                                Picker(selection: $currentModel) {
                                    ForEach(sortedModelIndices, id: \.self) { index in
                                        Text(cameraBrands[currentBrand].models[index].model).tag(index)
                                    }
                                } label: {
                                    HStack {
                                        Label {
                                            Text("Model")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        } icon: {
                                            Image(systemName: "video.fill")
                                                .foregroundStyle(.green)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary.opacity(0.7))
                                    }
                                }
                                .pickerStyle(.navigationLink)
                                .onAppear { isInPickerView = true }
                                .onDisappear { isInPickerView = false }

                                Divider()
                                
                                PowerDrawRow(
                                    value: cameraBrands[safeBrand].models[safeModel].powerDraw,
                                    icon: "bolt.fill",
                                    color: .orange
                                )
                            }
                        }
                        
                        // Accessories Section
                        ModernCard {
                            AccessoriesSection(
                                selectedAccessories: $currentAccessories,
                                focusSystemQuantities: $localFocusSystemQuantities,
                                accessories: accessories
                            )
                        }
                        
                        // Battery Section
                        ModernCard {
                            VStack(spacing: 12) {
                                Picker(selection: $selectedBattery) {
                                    ForEach(0..<batteries.count, id: \.self) { index in
                                        Text(batteries[index].model).tag(index)
                                    }
                                } label: {
                                    HStack {
                                        Label {
                                            Text("Battery Capacity")
                                                .font(.title2)
                                                .foregroundColor(.primary)
                                        } icon: {
                                            Text("🔋")
                                                .font(.title3)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary.opacity(0.7))
                                    }
                                }
                                .pickerStyle(.navigationLink)
                                
                                Divider()
                                
                                // Update the battery quantity section
                                HStack {
                                    Text("Number of Batteries")
                                        .font(.title3)  // Slightly smaller than .title2 used above
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            if batteryQuantity > 1 {
                                                batteryQuantity -= 1
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundStyle(.secondary)
                                                .font(.title2)
                                        }
                                        
                                        Text("\(batteryQuantity)")
                                            .font(.headline)
                                            .monospacedDigit()
                                            .frame(minWidth: 30)
                                        
                                        Button(action: {
                                            if batteryQuantity < 20 {
                                                batteryQuantity += 1
                                            }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundStyle(.secondary)
                                                .font(.title2)
                                        }
                                    }
                                }
                                
                                // Add total capacity display
                                HStack {
                                    Text("Total Battery Capacity")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(String(format: "%.1f", batteries[selectedBattery].wattHours * Double(batteryQuantity)))Wh")
                                        .font(.subheadline)
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        // Runtime Display
                        ModernCard {
                            VStack(spacing: 16) {
                                Text("Estimated Runtime")
                                    .font(.subheadline)
                                    .textCase(.uppercase)
                                    .foregroundStyle(.secondary)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(String(format: "%.1f", runtime))
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .monospacedDigit()
                                        .foregroundColor(.primary)
                                    Text("hours")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text(String(format: "%.0f minutes", runtime * 60))
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                                
                                // Add per-battery information when multiple batteries are selected
                                if batteryQuantity > 1 {
                                    Text("(\(String(format: "%.1f", runtime / Double(batteryQuantity))) hours per battery)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                                
                                HStack {
                                    Label("\(String(format: "%.1f", totalPowerDraw))W", systemImage: "bolt.fill")
                                        .foregroundStyle(.orange)
                                        .font(.headline)
                                        .monospacedDigit()
                                }
                                .padding(.top, 8)
                                
                                Divider()
                                
                                // First, create the destination view
                                let advancedView = AdvancedBatteryCalculatorView(
                                    brand: currentBrand,
                                    model: currentModel,
                                    battery: selectedBattery,
                                    accessories: currentAccessories,
                                    batteryQuantity: batteryQuantity
                                )

                                // Then create the navigation link with modifiers
                                NavigationLink {
                                    advancedView
                                        .onAppear {
                                            isNavigatingToAdvanced = true
                                        }
                                        .onDisappear {
                                            isNavigatingToAdvanced = false
                                        }
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Label {
                                                Text("Advanced Runtime Calculator")
                                                    .foregroundColor(.primary)
                                            } icon: {
                                                Image(systemName: "arrow.right.circle.fill")
                                                    .foregroundStyle(.orange)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary.opacity(0.7))
                                        }
                                        
                                     
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(20)
                        }
                        
                        // Support Section
                        VStack(spacing: 16) {
                            Link("Request Camera/Accessory Addition",
                                 destination: URL(string: "mailto:app@stevepmann.com")!)
                                .font(.subheadline)
                        }
                        .padding(10)
                    }
                    .padding(.horizontal)
                }
                
                // Update the floating back button
                VStack {
                    HStack {
                        Button(action: {
                            isLeavingView = true  // Set this flag before dismissing
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
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
