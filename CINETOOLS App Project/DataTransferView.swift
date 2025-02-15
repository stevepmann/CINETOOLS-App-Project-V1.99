//
//  DataTransferView.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//

import SwiftUI
import Foundation

struct DataTransferView: View {
    @State private var selectedSpeed = 0
    @State private var selectedSourceDrive = 0
    @State private var isEditingDataAmount = false
    @State private var dataAmountString = "100"  // String for text input
    @State private var dataAmount = 100.0  // Double for calculations
    
    let transferSpeeds = [
        TransferSpeed(name: "USB 2.0", speedMbps: 480),
        TransferSpeed(name: "USB 3.0", speedMbps: 5000),
        TransferSpeed(name: "USB 3.1", speedMbps: 10000),
        TransferSpeed(name: "USB 3.2", speedMbps: 20000),
        TransferSpeed(name: "Thunderbolt 3", speedMbps: 40000),
        TransferSpeed(name: "Thunderbolt 4", speedMbps: 40000),
        TransferSpeed(name: "CFexpress Type A", speedMbps: 1000),
        TransferSpeed(name: "CFexpress Type B", speedMbps: 2000)
    ]
    
    let drives = [
        DriveSpeed(name: "Samsung T7", readSpeedMbps: 8000, writeSpeedMbps: 7000, type: "Portable SSD"),
        DriveSpeed(name: "Samsung T5", readSpeedMbps: 4000, writeSpeedMbps: 3800, type: "Portable SSD"),
        DriveSpeed(name: "SanDisk Extreme Pro", readSpeedMbps: 16000, writeSpeedMbps: 15200, type: "Portable SSD"),
        DriveSpeed(name: "LaCie Rugged", readSpeedMbps: 1100, writeSpeedMbps: 1000, type: "HDD"),
        DriveSpeed(name: "G-Drive Mobile", readSpeedMbps: 1000, writeSpeedMbps: 950, type: "HDD"),
        DriveSpeed(name: "WD Elements", readSpeedMbps: 1200, writeSpeedMbps: 1100, type: "HDD"),
        DriveSpeed(name: "CFexpress Card", readSpeedMbps: 1700, writeSpeedMbps: 1400, type: "Memory Card"),
        DriveSpeed(name: "Internal SSD", readSpeedMbps: 35000, writeSpeedMbps: 30000, type: "Internal Drive"),
        DriveSpeed(name: "SD UHS-II Card", readSpeedMbps: 300, writeSpeedMbps: 250, type: "Memory Card")
    ]
    
    private var effectiveTransferSpeed: Double {
        let connectionSpeed = transferSpeeds[selectedSpeed].speedMbps
        let sourceReadSpeed = drives[selectedSourceDrive].readSpeedMbps
        
        // Transfer speed is limited by the slowest component
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
                                    
                                    Divider()
                                    
                                    PowerDrawRow(
                                        value: drives[selectedSourceDrive].readSpeedMbps,
                                        label: "Read Speed",
                                        unit: " Mbps",
                                        icon: "arrow.down.circle",
                                        color: .blue
                                    )
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
                                VStack(spacing: 16) {
                                    HStack {
                                        Label {
                                            Text("Data Amount (GB)")
                                                .font(.title2)
                                                .foregroundColor(.primary)
                                        } icon: {
                                            Image(systemName: "internaldrive.fill")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                        
                                        // Tappable text field
                                        TextField("GB", text: $dataAmountString)
                                            .multilineTextAlignment(.trailing)
                                            .keyboardType(.decimalPad)
                                            .frame(width: 80)
                                            .monospacedDigit()
                                            .onSubmit {
                                                if let value = Double(dataAmountString) {
                                                    dataAmount = min(max(value, 0), 10000)
                                                    dataAmountString = String(format: "%.1f", dataAmount)
                                                }
                                            }
                                    }
                                    
                                    Slider(value: $dataAmount, in: 0...10000, step: 1) { editing in
                                        if !editing {
                                            dataAmountString = String(format: "%.1f", dataAmount)
                                        }
                                    }
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
                         
                        }
                        .padding(10)
                        .padding(.horizontal)
                  
                    }
                    .padding(.vertical)
                }
            }
        }
        .onChange(of: dataAmountString) { oldValue, newValue in
            // Only allow numbers and decimal point
            let filtered = newValue.filter { "0123456789.".contains($0) }
            if filtered != newValue {
                dataAmountString = filtered
            }
            
            // Update dataAmount if valid
            if let value = Double(filtered) {
                dataAmount = min(max(value, 0), 10000)
            }
        }
    }
}

#Preview {
    DataTransferView()
} 
