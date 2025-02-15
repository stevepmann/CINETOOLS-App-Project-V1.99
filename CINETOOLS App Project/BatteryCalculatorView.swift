//
//  ContentView.swift
//  Camera Battery Calculator
//
//  Created by steven mann on 29/01/2025.
//

import SwiftUI
import Foundation

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
    let accessories: [Accessory]
    @Binding var selectedAccessories: Set<Int>
    let totalAccessoryPowerDraw: Double
    
    var body: some View {
        ModernCard {
            VStack(spacing: 12) {
                // Header
                Label {
                    Text("Accessories")
                        .font(.title2)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Categories
                ForEach(AccessoryCategory.allCases, id: \.self) { category in
                    DisclosureGroup {
                        VStack(spacing: 12) {
                            ForEach(accessories.indices, id: \.self) { index in
                                if accessories[index].category == category {
                                    ModernAccessoryToggle(
                                        accessory: accessories[index],
                                        isSelected: selectedAccessories.contains(index),
                                        action: {
                                            if selectedAccessories.contains(index) {
                                                selectedAccessories.remove(index)
                                            } else {
                                                selectedAccessories.insert(index)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    } label: {
                        Text(category.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                if !selectedAccessories.isEmpty {
                    Divider()
                    PowerDrawRow(
                        value: totalAccessoryPowerDraw,
                        label: "Total Accessories",
                        icon: "bolt.fill",
                        color: .orange
                    )
                }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedBrand: Int
    @State private var selectedModel: Int
    @State private var selectedBattery = 0
    @State private var selectedAccessories: Set<Int>
    
    // Get data from CameraDatabase
    let cameraBrands = CameraDatabase.shared.getCameraForBatteryCalc()
    let accessories = CameraDatabase.shared.getAccessories()
    let batteries = [
        Battery(model: "98Wh", wattHours: 98, voltage: 14.8),
        Battery(model: "150Wh", wattHours: 150, voltage: 14.8),
        Battery(model: "11Wh (Canon LP-E6)", wattHours: 11, voltage: 7.4),
        Battery(model: "28Wh (BP-U30)", wattHours: 28, voltage: 14.8),
        Battery(model: "36Wh (Nikon EN-EL18d)", wattHours: 28, voltage: 10.8),
        Battery(model: "50Wh", wattHours: 50, voltage: 14.8),
        Battery(model: "56Wh (BP-U60)", wattHours: 50, voltage: 14.8),
        Battery(model: "240Wh", wattHours: 240, voltage: 14.8),
        Battery(model: "290Wh", wattHours: 290, voltage: 14.8),
        Battery(model: "420Wh", wattHours: 420, voltage: 14.8)
    ]
    
    // Initialize with settings from EnvironmentObject
    init() {
        _selectedBrand = State(initialValue: 0)
        _selectedModel = State(initialValue: 0)
        _selectedAccessories = State(initialValue: Set<Int>())
    }
    
    private var totalPowerDraw: Double {
        let cameraDraw = cameraBrands[selectedBrand].models[selectedModel].powerDraw
        let accessoriesDraw = selectedAccessories.reduce(0.0) { total, index in
            total + accessories[index].powerDraw
        }
        return cameraDraw + accessoriesDraw
    }
    
    private var runtime: Double {
        let battery = batteries[selectedBattery]
        return (battery.wattHours * 0.90) / totalPowerDraw
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        LazyVStack(spacing: 20) {
                            Spacer()
                                .frame(height: 16)  // Add space at the top
                            
                            // Title
                            Text("Camera Rig Runtime Calculator")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal)
                            
                            
                            // Camera Section
                            ModernCard {
                                VStack(spacing: 12) {
                                    Picker(selection: $selectedBrand) {
                                        ForEach(0..<cameraBrands.count, id: \.self) { index in
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
                                    
                                    Divider()
                                    
                                    Picker(selection: $selectedModel) {
                                        ForEach(0..<cameraBrands[selectedBrand].models.count, id: \.self) { index in
                                            Text(cameraBrands[selectedBrand].models[index].model).tag(index)
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

                                    Divider()
                                    
                                    PowerDrawRow(
                                        value: cameraBrands[selectedBrand].models[selectedModel].powerDraw,
                                        icon: "bolt.fill",
                                        color: .orange
                                    )
                                }
                            }
                            
                           // Accessories Section
                            Section {
                                AccessoriesSection(
                                    accessories: accessories,
                                    selectedAccessories: $selectedAccessories,
                                    totalAccessoryPowerDraw: totalPowerDraw - cameraBrands[selectedBrand].models[selectedModel].powerDraw
                                )
                            }
                            
                            // Battery Section
                            Section {
                                ModernCard {
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
                                }
                            }
                        }
                        .padding(.horizontal)
                        
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
                                
                                HStack {
                                    Label("\(String(format: "%.1f", totalPowerDraw))W", systemImage: "bolt.fill")
                                        .foregroundStyle(.orange)
                                        .font(.headline)
                                        .monospacedDigit()
                                }
                                .padding(.top, 8)
                                
                                Divider()
                                
                                DisclosureGroup {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("The runtime estimate includes a standard 90% battery efficiency factor. For more accurate calculations considering ambient temperature and battery age;")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                       
                                        NavigationLink(destination: AdvancedBatteryCalculatorView(
                                            brand: selectedBrand,
                                            model: selectedModel,
                                            battery: selectedBattery,
                                            accessories: selectedAccessories
                                        )) {
                                            Text("See Advanced Calculator")
                                                .font(.subheadline)
                                                .foregroundStyle(.blue)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .padding(.vertical, 8)
                                } label: {
                                    Label("Advanced Runtime Calculation", systemImage: "info.circle")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(20)
                        }
                        .padding(.horizontal)
                        
                        // Support Section (without ModernCard)
                        VStack(spacing: 16) {
                            Link("Request Camera/Accessory Addition",
                                 destination: URL(string: "mailto:app@stevepmann.com")!)
                                .font(.subheadline)
                        }
                        .padding(10)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                  
                    VStack(spacing: 1) {
                        Image("-headerlogo-")
                            .resizable()
                            .frame(width: 300, height: 100)
                    }
                }
                
                // Add floating back button
                VStack {
                    HStack {
                        Button(action: {
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
    }
}

// Or using the new macro syntax:
#Preview {
    NavigationStack {
        ContentView()
            .environmentObject(UserSettings())
    }
}
