import SwiftUI
import Foundation

struct AdvancedBatteryCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: UserSettings
    
    // Add these parameters to receive values from BatteryCalculatorView
    let initialBrand: Int
    let initialModel: Int
    let initialBattery: Int
    let initialAccessories: Set<Int>
    
    @State private var selectedBrand: Int
    @State private var selectedModel: Int
    @State private var selectedBattery: Int
    @State private var selectedAccessories: Set<Int>
    @State private var ambientTemperature = 20.0 // Default 20°C
    @State private var batteryAge = 1.0 // Default 1 year
    
    let cameraBrands = CameraDatabase.shared.getCameraForBatteryCalc()
    let accessories = CameraDatabase.shared.getAccessories()
    let batteries = [
        Battery(model: "98Wh", wattHours: 98, voltage: 14.8),
        Battery(model: "150Wh", wattHours: 150, voltage: 14.8),
        // ... existing batteries ...
    ]
    
    // Update init to accept and use the passed values
    init(brand: Int, model: Int, battery: Int, accessories: Set<Int>) {
        initialBrand = brand
        initialModel = model
        initialBattery = battery
        initialAccessories = accessories
        
        _selectedBrand = State(initialValue: brand)
        _selectedModel = State(initialValue: model)
        _selectedBattery = State(initialValue: battery)
        _selectedAccessories = State(initialValue: accessories)
    }
    
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
    
    private var totalPowerDraw: Double {
        let cameraDraw = cameraBrands[selectedBrand].models[selectedModel].powerDraw
        let accessoriesDraw = selectedAccessories.reduce(0.0) { total, index in
            total + accessories[index].powerDraw
        }
        return cameraDraw + accessoriesDraw
    }
    
    private var runtime: Double {
        let battery = batteries[selectedBattery]
        let baseEfficiency = 0.90 // Base Li-ion efficiency
        let totalEfficiency = baseEfficiency * temperatureEfficiencyFactor * ageEfficiencyFactor
        let effectiveWattHours = battery.wattHours * totalEfficiency
        return effectiveWattHours / totalPowerDraw
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    LazyVStack(spacing: 20) {
                        Spacer()
                            .frame(height: 80)
                        
                        Text("Advanced Runtime Factors")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal)
                        
                        // Camera and Accessories sections (similar to basic calculator)
                        // ... existing camera and accessories sections ...
                        
                        // Temperature Section
                        ModernCard {
                            VStack(spacing: 16) {
                                HStack {
                                    Label {
                                        Text("Ambient Temperature")
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                    } icon: {
                                        Image(systemName: "thermometer.medium")
                                            .foregroundStyle(.red)
                                    }
                                    Spacer()
                                    Text("\(Int(ambientTemperature))°C")
                                        .monospacedDigit()
                                }
                                
                                Slider(value: $ambientTemperature, in: -20...50, step: 1)
                                
                                Text("Efficiency: \(Int(temperatureEfficiencyFactor * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Battery Age Section
                        ModernCard {
                            VStack(spacing: 16) {
                                HStack {
                                    Label {
                                        Text("Battery Age")
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                    } icon: {
                                        Image(systemName: "calendar")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                    Text("\(batteryAge, specifier: "%.1f") years")
                                        .monospacedDigit()
                                }
                                
                                Slider(value: $batteryAge, in: 0...5, step: 0.5)
                                
                                Text("Capacity: \(Int(ageEfficiencyFactor * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
                                    Text("hours")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text(String(format: "%.0f minutes", runtime * 60))
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Efficiency Factors:")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("• Temperature: \(Int(temperatureEfficiencyFactor * 100))%")
                                    Text("• Battery Age: \(Int(ageEfficiencyFactor * 100))%")
                                    Text("• Base Efficiency: 90%")
                                    Text("• Total Efficiency: \(Int(temperatureEfficiencyFactor * ageEfficiencyFactor * 0.9 * 100))%")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(24)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            
            // Floating Back Button
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
                .padding(.top, 60)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarHidden(true)
    }
}

#Preview {
    AdvancedBatteryCalculatorView(brand: 0, model: 0, battery: 0, accessories: [])
        .environmentObject(UserSettings())
} 
