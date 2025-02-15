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
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        LazyVStack(spacing: 20) {
                            Spacer()
                                .frame(height: 16)
                            
                            // Title
                            Text("Data Transfer Speed Calculator")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal)
                            
                            ModernCard {
                                VStack(spacing: 12) {
                                    Picker(selection: $selectedSourceDrive) {
                                        ForEach(0..<drives.count, id: \.self) { index in
                                            Text("\(drives[index].name) (\(drives[index].type))").tag(index)
                                        }
                                    } label: {
                                        HStack {
                                            Label {
                                                Text("Source")
                                                    .font(.title2)
                                                    .foregroundColor(.primary)
                                            } icon: {
                                                Image(systemName: "externaldrive.fill")
                                                    .foregroundStyle(.blue)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary.opacity(0.7))
                                        }
                                    }
                                    .pickerStyle(.navigationLink)
                                    .onChange(of: selectedSourceDrive) { oldValue, newValue in
                                        isCustomDrive = newValue == drives.count - 1
                                    }
                                    
                                    if isCustomDrive {
                                        Divider()
                                        
                                        // Custom speed input
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Custom Speed")
                                                .font(.headline)
                                            
                                            Spacer()
                                            
                                            // Combined text field and Mbps label in one container
                                            HStack(spacing: 4) {
                                                TextField("0", text: $customReadSpeed)
                                                    .multilineTextAlignment(.trailing)
                                                    .keyboardType(.numberPad)
                                                    .frame(width: 80)
                                                    .monospacedDigit()
                                                    .font(.system(.title3, design: .rounded))
                                                    .foregroundColor(isCustomSpeedOverLimit ? .red : .primary)
                                                
                                                Text("Mbps")
                                                    .font(.headline)
                                                    .foregroundStyle(isCustomSpeedOverLimit ? .red : .secondary)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(.ultraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .offset(y: isCustomSpeedOverLimit ? -5 : 0)
                                            .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isCustomSpeedOverLimit)
                                        }
                                    } else {
                                        Divider()
                                        
                                        PowerDrawRow(
                                            value: drives[selectedSourceDrive].readSpeedMbps,
                                            label: "Read Speed",
                                            unit: " Mbps",
                                            icon: "arrow.down.circle",
                                            color: .orange
                                        )
                                    }
                                }
                            }
                            
                            // Connection Type Section
                             ModernCard {
                                VStack(spacing: 12) {
                                    Picker(selection: $selectedSpeed) {
                                        ForEach(0..<transferSpeeds.count, id: \.self) { index in
                                            Text(transferSpeeds[index].name).tag(index)
                                        }
                                    } label: {
                                        HStack {
                                            Label {
                                                Text("Connection Type")
                                                    .font(.title2)
                                                    .foregroundColor(.primary)
                                            } icon: {
                                                Image(systemName: "cable.connector")
                                                    .foregroundStyle(.blue)
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
                                        value: effectiveTransferSpeed,
                                        label: "Effective Speed",
                                        unit: " Mbps",
                                        icon: "speedometer",
                                        color: .orange
                                    )
                                }
                            }
                            
                            // Data Amount Section
                            ModernCard {
                                HStack(alignment: .center, spacing: 16) {
                                    // Title and icon
                                    Label {
                                        Text("Data Amount")
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                    } icon: {
                                        Image(systemName: "internaldrive.fill")
                                            .foregroundStyle(.blue)
                                    }
                                    
                                    Spacer()
                                    
                                    // Enhanced text field
                                    HStack(spacing: 4) {
                                        TextField("0.0", text: $dataAmountString)
                                            .multilineTextAlignment(.trailing)
                                            .keyboardType(.decimalPad)
                                            .frame(width: 80)
                                            .monospacedDigit()
                                            .font(.system(.title3, design: .rounded))
                                            .foregroundColor(isOverLimit ? .red : .primary)
                                        
                                        Text("GB")
                                            .font(.headline)
                                            .foregroundStyle(isOverLimit ? .red : .secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(y: isOverLimit ? -5 : 0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isOverLimit)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Transfer Time Display
                        ModernCard {
                            VStack(spacing: 16) {
                                Text("Estimated Transfer Time")
                                    .font(.subheadline)
                                    .textCase(.uppercase)
                                    .foregroundStyle(.secondary)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(String(format: "%.1f", transferTimeMinutes))
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .monospacedDigit()
                                        .foregroundColor(.primary)
                                    Text("min")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                                
                                if transferTimeMinutes >= 60 {
                                    Text(String(format: "%.1f hours", transferTimeMinutes / 60))
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                            .padding(24)
                        }
                        .padding(.horizontal)
                        
                        // Support Section
                        VStack(spacing: 16) {
                            Link("Request Feature Update/ Gear Addition",
                                 destination: URL(string: "mailto:app@stevepmann.com")!)
                                .font(.subheadline)
                            
                            VStack(spacing: 1) {
                                Image("-headerlogo-")
                                    .resizable()
                                    .frame(width: 300, height: 100)
                            }
                         
                        }
                        .padding(10)
                        .padding(.horizontal)
                  
                    }
                    .padding(.vertical)
                    
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

#Preview {
    DataTransferView()
} 
