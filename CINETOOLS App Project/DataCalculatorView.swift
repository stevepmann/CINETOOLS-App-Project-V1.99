//
//  DataCalculatorView.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//

import SwiftUI
import Foundation

struct AdditionalCamera: Identifiable {
    let id = UUID()
    var brand: Int
    var model: Int
    var codec: Int
}

struct DataCalculatorView: View {
    @State private var selectedBrand = 0
    @State private var selectedModel = 0
    @State private var selectedCodec = 0
    @State private var recordingHours = 1.0
    @State private var additionalCameras: [AdditionalCamera] = []
    
    // Get camera data from database
    let cameras = CameraDatabase.shared.getCameraForDataCalc()
    
    // Helper computed properties
    private var currentBrand: CameraData {
        cameras[selectedBrand]
    }
    
    private var currentModel: CameraModel {
        currentBrand.models[selectedModel]
    }
    
    private var currentCodec: CodecData {
        currentModel.codecs[selectedCodec]
    }
    
    private var totalStorageRequired: Double {
        let mainCameraStorage = (currentCodec.bitrate * 0.45) * recordingHours
        
        let additionalStorage = additionalCameras.reduce(0.0) { total, camera in
            let model = cameras[camera.brand].models[camera.model]
            let codec = model.codecs[camera.codec]
            return total + (codec.bitrate * 0.45 * recordingHours)
        }
        
        return mainCameraStorage + additionalStorage
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
                            
                            // Title Section
                            Text("Data Usage Calculator")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal)
                            
                            ModernCard {
                                VStack(spacing: 12) {
                                    // Brand Selection
                                    Picker(selection: $selectedBrand) {
                                        ForEach(0..<cameras.count, id: \.self) { index in
                                            Text(cameras[index].name).tag(index)
                                        }
                                    } label: {
                                        HStack {
                                            Label {
                                                Text("Camera Brand")
                                                    .font(.title2)
                                                    .foregroundColor(.primary)
                                            } icon: {
                                                Image(systemName: "camera.fill")
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
                                    
                                    // Model Selection
                                    Picker(selection: $selectedModel) {
                                        ForEach(0..<currentBrand.models.count, id: \.self) { index in
                                            Text(currentBrand.models[index].name).tag(index)
                                        }
                                    } label: {
                                        HStack {
                                            Label {
                                                Text("Camera Model")
                                                    .font(.title2)
                                                    .foregroundColor(.primary)
                                            } icon: {
                                                Image(systemName: "video.fill")
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
                                    
                                    // Codec Selection
                                    Picker(selection: $selectedCodec) {
                                        ForEach(0..<currentModel.codecs.count, id: \.self) { index in
                                            Text(currentModel.codecs[index].name).tag(index)
                                        }
                                    } label: {
                                        HStack {
                                            Label {
                                                Text("Codec")
                                                    .font(.title2)
                                                    .foregroundColor(.primary)
                                            } icon: {
                                                Image(systemName: "film.fill")
                                                    .foregroundStyle(.orange)
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
                            
                            // Additional Cameras Section
                            ForEach(additionalCameras.indices, id: \.self) { index in
                                ModernCard {
                                    VStack(spacing: 12) {
                                        // Header with camera number and remove button
                                        HStack {
                                            Text("Camera \(index + 2)")
                                                .font(.title2)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Button {
                                                additionalCameras.remove(at: index)
                                            } label: {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundStyle(.red)
                                                    .font(.title2)
                                            }
                                        }
                                        
                                        Divider()
                                        
                                        // Brand Selection
                                        Picker(selection: Binding(
                                            get: { additionalCameras[index].brand },
                                            set: { newValue in
                                                additionalCameras[index].brand = newValue
                                                additionalCameras[index].model = 0
                                                additionalCameras[index].codec = 0
                                            }
                                        )) {
                                            ForEach(0..<cameras.count, id: \.self) { brandIndex in
                                                Text(cameras[brandIndex].name).tag(brandIndex)
                                            }
                                        } label: {
                                            HStack {
                                                Label("Brand", systemImage: "camera.fill")
                                                    .foregroundStyle(.blue)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                        .pickerStyle(.navigationLink)
                                        
                                        // Model Selection
                                        let camera = additionalCameras[index]
                                        Picker(selection: Binding(
                                            get: { camera.model },
                                            set: { newValue in
                                                additionalCameras[index].model = newValue
                                                additionalCameras[index].codec = 0
                                            }
                                        )) {
                                            ForEach(0..<cameras[camera.brand].models.count, id: \.self) { modelIndex in
                                                Text(cameras[camera.brand].models[modelIndex].name).tag(modelIndex)
                                            }
                                        } label: {
                                            HStack {
                                                Label("Model", systemImage: "video.fill")
                                                    .foregroundStyle(.blue)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                        .pickerStyle(.navigationLink)
                                        
                                        // Codec Selection
                                        Picker(selection: Binding(
                                            get: { camera.codec },
                                            set: { additionalCameras[index].codec = $0 }
                                        )) {
                                            ForEach(0..<cameras[camera.brand].models[camera.model].codecs.count, id: \.self) { codecIndex in
                                                Text(cameras[camera.brand].models[camera.model].codecs[codecIndex].name).tag(codecIndex)
                                            }
                                        } label: {
                                            HStack {
                                                Label("Codec", systemImage: "film.fill")
                                                    .foregroundStyle(.orange)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                        .pickerStyle(.navigationLink)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Add Camera Button
                            Button {
                                additionalCameras.append(AdditionalCamera(brand: 0, model: 0, codec: 0))
                            } label: {
                                Label("Add Camera", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                            }
                            .padding(.vertical, 8)
                            
                            // Recording Duration Section
                            ModernCard {
                                VStack(spacing: 16) {
                                    HStack {
                                        Label {
                                            Text("Recording Duration in Hours")
                                                .font(.title2)
                                                .foregroundColor(.primary)
                                        } icon: {
                                            Image(systemName: "clock.fill")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                        Text("\(recordingHours, specifier: "%.1f")")
                                            .monospacedDigit()
                                    }
                                    
                                    Slider(value: $recordingHours, in: 0...10, step: 0.1)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Total Storage Display
                        ModernCard {
                            VStack(spacing: 16) {
                                Text("Total Required Storage")
                                    .font(.subheadline)
                                    .textCase(.uppercase)
                                    .foregroundStyle(.secondary)
                                
                                VStack(spacing: 4) {
                                    if totalStorageRequired >= 1000 {
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text(String(format: "%.2f", totalStorageRequired / 1000))
                                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                                .monospacedDigit()
                                            Text("TB")
                                                .font(.title3)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Text("\(String(format: "%.1f", totalStorageRequired)) GB")
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                            .monospacedDigit()
                                    } else {
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text(String(format: "%.1f", totalStorageRequired))
                                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                                .monospacedDigit()
                                            Text("GB")
                                                .font(.title3)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                
                                // Show individual camera storage requirements
                                if !additionalCameras.isEmpty {
                                    Divider()
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Breakdown:")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        
                                        Text("Camera 1: \(String(format: "%.1f", currentCodec.bitrate * 0.45 * recordingHours)) GB")
                                        
                                        ForEach(additionalCameras.indices, id: \.self) { index in
                                            let camera = additionalCameras[index]
                                            let model = cameras[camera.brand].models[camera.model]
                                            let codec = model.codecs[camera.codec]
                                            Text("Camera \(index + 2): \(String(format: "%.1f", codec.bitrate * 0.45 * recordingHours)) GB")
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .padding(24)
                        }
                        .padding(.horizontal)
                        
                        // Support Section (without ModernCard)
                        VStack(spacing: 10) {
                       
                            Link("Request Camera/Codec Addition",
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
        .onChange(of: selectedBrand) { oldValue, newValue in
            // Reset model and codec when brand changes
            selectedModel = 0
            selectedCodec = 0
        }
        .onChange(of: selectedModel) { oldValue, newValue in
            // Reset codec when model changes
            selectedCodec = 0
        }
    }
}

#Preview {
    DataCalculatorView()
} 
