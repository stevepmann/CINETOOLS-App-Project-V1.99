//
//  DataCalculatorView.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//

import SwiftUI
import Foundation

struct AdditionalCamera: Identifiable, Codable {
    var id: UUID
    var name: String
    var brand: Int
    var model: Int
    var codec: Int
    
    // Add CodingKeys to handle the UUID
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand
        case model
        case codec
    }
    
    // Custom init for decoding to handle the UUID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decode(Int.self, forKey: .brand)
        model = try container.decode(Int.self, forKey: .model)
        codec = try container.decode(Int.self, forKey: .codec)
    }
    
    // Regular init
    init(name: String = "", brand: Int, model: Int, codec: Int) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.model = model
        self.codec = codec
    }
}

// Update the enum to conform to Equatable
enum PickerState: Equatable {
    case none
    case mainBrand
    case mainModel
    case mainCodec
    case additionalCamera(UUID)
    
    // Custom Equatable implementation for handling UUID comparison
    static func == (lhs: PickerState, rhs: PickerState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.mainBrand, .mainBrand):
            return true
        case (.mainModel, .mainModel):
            return true
        case (.mainCodec, .mainCodec):
            return true
        case (.additionalCamera(let id1), .additionalCamera(let id2)):
            return id1 == id2
        default:
            return false
        }
    }
}

struct DataCalculatorView: View {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    
    @State private var activePicker: PickerState = .none
    @State private var currentBrandIndex: Int
    @State private var currentModelIndex: Int
    @State private var currentCodecIndex: Int
    
    // Update bindings to use activePicker state
    private var selectedBrandBinding: Binding<Int> {
        Binding(
            get: { currentBrandIndex },
            set: { newValue in
                activePicker = .mainBrand
                currentBrandIndex = newValue
                currentModelIndex = 0
                currentCodecIndex = 0
                settings.dataCalcBrand = newValue
                settings.dataCalcModel = 0
                settings.dataCalcCodec = 0
            }
        )
    }
    
    private var selectedModelBinding: Binding<Int> {
        Binding(
            get: { currentModelIndex },
            set: { newValue in
                activePicker = .mainModel
                currentModelIndex = newValue
                currentCodecIndex = 0
                settings.dataCalcModel = newValue
                settings.dataCalcCodec = 0
            }
        )
    }
    
    private var selectedCodecBinding: Binding<Int> {
        Binding(
            get: { currentCodecIndex },
            set: { newValue in
                activePicker = .mainCodec
                currentCodecIndex = newValue
                settings.dataCalcCodec = newValue
            }
        )
    }
    
    // Separate state for main camera that won't be affected by additional cameras
    @State private var mainCameraState: CameraState
    
    struct CameraState {
        var brand: Int
        var model: Int
        var codec: Int
    }
    
    // Add state to track if we're just navigating pickers
    @State private var isNavigatingPicker = false
    
    // Get camera data from database
    let cameras = CameraDatabase.shared.getCameraForDataCalc()
    
    init() {
        let settings = UserSettings()
        // Initialize main camera state from settings
        _mainCameraState = State(initialValue: CameraState(
            brand: settings.dataCalcBrand,
            model: settings.dataCalcModel,
            codec: settings.dataCalcCodec
        ))
        _currentBrandIndex = State(initialValue: settings.dataCalcBrand)
        _currentModelIndex = State(initialValue: settings.dataCalcModel)
        _currentCodecIndex = State(initialValue: settings.dataCalcCodec)
    }
    
    // Update computed properties to use mainCameraState
    private var currentBrand: CameraData {
        cameras[currentBrandIndex]
    }
    
    private var currentModel: CameraModel {
        currentBrand.models[currentModelIndex]
    }
    
    private var currentCodec: CodecData {
        currentModel.codecs[currentCodecIndex]
    }
    
    // Add these sorted indices properties
    private var sortedBrandIndices: [Int] {
        cameras.indices.sorted { 
            cameras[$0].name.lowercased() < cameras[$1].name.lowercased() 
        }
    }
    
    private var sortedModelIndices: [Int] {
        currentBrand.models.indices.sorted {
            currentBrand.models[$0].name.lowercased() < 
            currentBrand.models[$1].name.lowercased()
        }
    }
    
    private var sortedCodecIndices: [Int] {
        currentModel.codecs.indices.sorted {
            currentModel.codecs[$0].name.lowercased() < 
            currentModel.codecs[$1].name.lowercased()
        }
    }
    
    // Helper functions for camera management
    private func addCamera() {
        settings.additionalCameras.append(AdditionalCamera(
            name: "Camera \(settings.additionalCameras.count + 2)",
            brand: 0,
            model: 0,
            codec: 0
        ))
    }
    
    private func removeCamera(at index: Int) {
        settings.additionalCameras.remove(at: index)
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
                                    // Header with camera number and name field
                                    HStack {
                                        Text("Camera 1")
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        TextField("Camera Name", text: $settings.mainCameraName)
                                            .multilineTextAlignment(.trailing)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Divider()
                                    
                                    // Brand Selection
                                    Picker(selection: selectedBrandBinding) {
                                        ForEach(sortedBrandIndices, id: \.self) { index in
                                            Text(cameras[index].name).tag(index)
                                        }
                                    } label: {
                                        HStack {
                                            Label {
                                                Text("Brand")
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
                                    Picker(selection: selectedModelBinding) {
                                        ForEach(sortedModelIndices, id: \.self) { index in
                                            Text(currentBrand.models[index].name).tag(index)
                                        }
                                    } label: {
                                        HStack {
                                            Label {
                                                Text("Model")
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
                                    
                                    // Codec Selection with bitrate
                                    VStack(spacing: 4) {
                                        Picker(selection: selectedCodecBinding) {
                                            ForEach(sortedCodecIndices, id: \.self) { index in
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
                                        
                                        // Add bitrate display
                                        HStack {
                                            Spacer()
                                            Text("\(String(format: "%.1f", currentCodec.bitrate)) Mbps")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .monospacedDigit()
                                        }
                                    }
                                }
                            }
                            
                            // Additional Cameras Section
                            ForEach(settings.additionalCameras) { camera in
                                AdditionalCameraView(
                                    camera: camera,
                                    settings: settings,
                                    cameras: cameras,
                                    activePicker: $activePicker
                                )
                            }
                            
                            // Add Camera Button
                            Button {
                                addCamera()
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
                                        Text("\(settings.recordingHours, specifier: "%.1f")")
                                            .monospacedDigit()
                                    }
                                    
                                    Slider(value: $settings.recordingHours, in: 0...10, step: 0.1)
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
                                if !settings.additionalCameras.isEmpty {
                                    Divider()
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Breakdown:")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        
                                        Text("\(settings.mainCameraName): \(String(format: "%.1f", currentCodec.bitrate * 0.45 * settings.recordingHours)) GB")
                                        
                                        ForEach(settings.additionalCameras) { camera in
                                            let model = cameras[camera.brand].models[camera.model]
                                            let codec = model.codecs[camera.codec]
                                            Text("\(camera.name): \(String(format: "%.1f", codec.bitrate * 0.45 * settings.recordingHours)) GB")
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
        .onAppear {
            // Only reset if we're not in any picker
            if case .none = activePicker {
                currentBrandIndex = settings.dataCalcBrand
                currentModelIndex = settings.dataCalcModel
                currentCodecIndex = settings.dataCalcCodec
            }
        }
        .onDisappear {
            // Only reset if we're actually leaving the view (not just navigating pickers)
            if case .none = activePicker {
                settings.resetCalculatorStates()
            }
        }
        // Reset picker state when returning from navigation
        .onChange(of: activePicker) { newValue in
            if case .none = newValue {
                // Keep current values, don't reset to settings
            }
        }
    }
    
    // Update storage calculation to use mainCameraState
    private var totalStorageRequired: Double {
        let mainCameraStorage = (currentCodec.bitrate * 0.45) * settings.recordingHours
        
        let additionalStorage = settings.additionalCameras.reduce(0.0) { total, camera in
            let model = cameras[camera.brand].models[camera.model]
            let codec = model.codecs[camera.codec]
            return total + (codec.bitrate * 0.45 * settings.recordingHours)
        }
        
        return mainCameraStorage + additionalStorage
    }
}

// Simple helper views
private struct CameraHeaderView: View {
    let index: Int
    @ObservedObject var settings: UserSettings
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text("Camera \(index + 2)")
                .font(.title2)
                .foregroundColor(.primary)
            
            TextField("Camera Name", text: Binding(
                get: { settings.additionalCameras[index].name },
                set: { settings.additionalCameras[index].name = $0 }
            ))
            .multilineTextAlignment(.trailing)
            .foregroundColor(.secondary)
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
                    .font(.title2)
            }
        }
    }
}

private struct CameraBrandPicker: View {
    let selection: Binding<Int>
    let cameras: [CameraData]
    
    var body: some View {
        Picker(selection: selection) {
            ForEach(0..<cameras.count, id: \.self) { index in
                Text(cameras[index].name).tag(index)
            }
        } label: {
            HStack {
                Label("Brand", systemImage: "camera.fill")
                    .foregroundStyle(.foreground)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .pickerStyle(.navigationLink)
    }
}

private struct CameraModelPicker: View {
    let selection: Binding<Int>
    let cameras: [CameraData]
    let brandIndex: Int
    
    var body: some View {
        Picker(selection: selection) {
            ForEach(0..<cameras[brandIndex].models.count, id: \.self) { index in
                Text(cameras[brandIndex].models[index].name).tag(index)
            }
        } label: {
            HStack {
                Label("Model", systemImage: "video.fill")
                    .foregroundStyle(.foreground)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .pickerStyle(.navigationLink)
    }
}

private struct CameraCodecPicker: View {
    let selection: Binding<Int>
    let cameras: [CameraData]
    let brandIndex: Int
    let modelIndex: Int
    
    var body: some View {
        Picker(selection: selection) {
            ForEach(0..<cameras[brandIndex].models[modelIndex].codecs.count, id: \.self) { index in
                Text(cameras[brandIndex].models[modelIndex].codecs[index].name).tag(index)
            }
        } label: {
            HStack {
                Label("Codec", systemImage: "film.fill")
                    .foregroundStyle(.foreground)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .pickerStyle(.navigationLink)
    }
}

// Update AdditionalCameraView
struct AdditionalCameraView: View {
    let camera: AdditionalCamera
    @ObservedObject var settings: UserSettings
    let cameras: [CameraData]
    @Binding var activePicker: PickerState
    
    @State private var localBrand: Int
    @State private var localModel: Int
    @State private var localCodec: Int
    
    // Add sorted indices computed properties
    private var sortedBrandIndices: [Int] {
        cameras.indices.sorted { 
            cameras[$0].name.lowercased() < cameras[$1].name.lowercased() 
        }
    }
    
    private var sortedModelIndices: [Int] {
        cameras[localBrand].models.indices.sorted {
            cameras[localBrand].models[$0].name.lowercased() < 
            cameras[localBrand].models[$1].name.lowercased()
        }
    }
    
    private var sortedCodecIndices: [Int] {
        cameras[localBrand].models[localModel].codecs.indices.sorted {
            cameras[localBrand].models[localModel].codecs[$0].name.lowercased() < 
            cameras[localBrand].models[localModel].codecs[$1].name.lowercased()
        }
    }
    
    init(camera: AdditionalCamera, settings: UserSettings, cameras: [CameraData], activePicker: Binding<PickerState>) {
        self.camera = camera
        self.settings = settings
        self.cameras = cameras
        self._activePicker = activePicker
        _localBrand = State(initialValue: camera.brand)
        _localModel = State(initialValue: camera.model)
        _localCodec = State(initialValue: camera.codec)
    }
    
    private var brandBinding: Binding<Int> {
        Binding(
            get: { localBrand },
            set: { newValue in
                activePicker = .additionalCamera(camera.id)
                localBrand = newValue
                localModel = 0
                localCodec = 0
                updateCamera(brand: newValue)
            }
        )
    }
    
    private var modelBinding: Binding<Int> {
        Binding(
            get: { localModel },
            set: { newValue in
                activePicker = .additionalCamera(camera.id)
                localModel = newValue
                localCodec = 0
                updateCamera(model: newValue)
            }
        )
    }
    
    private var codecBinding: Binding<Int> {
        Binding(
            get: { localCodec },
            set: { newValue in
                activePicker = .additionalCamera(camera.id)
                localCodec = newValue
                updateCamera(codec: newValue)
            }
        )
    }
    
    private var cameraIndex: Int? {
        settings.additionalCameras.firstIndex(where: { $0.id == camera.id })
    }
    
    private func removeCamera() {
        if let index = cameraIndex {
            settings.additionalCameras.remove(at: index)
        }
    }
    
    var body: some View {
        ModernCard {
            VStack(spacing: 12) {
                // Header
                HStack {
                    Text("Camera \((cameraIndex ?? 0) + 2)")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    TextField("Camera Name", text: Binding(
                        get: { camera.name },
                        set: { newName in
                            guard let index = cameraIndex else { return }
                            var cameras = settings.additionalCameras
                            cameras[index].name = newName
                            settings.additionalCameras = cameras
                        }
                    ))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
                    
                    // Remove Camera Button
                    Button(action: removeCamera) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title2)
                    }
                }
                
                Divider()
                
                // Brand Picker
                Picker(selection: brandBinding) {
                    ForEach(sortedBrandIndices, id: \.self) { brandIndex in
                        Text(cameras[brandIndex].name).tag(brandIndex)
                    }
                } label: {
                    HStack {
                        Label("Brand", systemImage: "camera.fill")
                            .foregroundStyle(.foreground)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .pickerStyle(.navigationLink)
                
                // Model Picker
                Picker(selection: modelBinding) {
                    ForEach(sortedModelIndices, id: \.self) { modelIndex in
                        Text(cameras[localBrand].models[modelIndex].name).tag(modelIndex)
                    }
                } label: {
                    HStack {
                        Label("Model", systemImage: "video.fill")
                            .foregroundStyle(.foreground)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .pickerStyle(.navigationLink)
                
                // Codec Picker with bitrate
                VStack(spacing: 4) {
                    Picker(selection: codecBinding) {
                        ForEach(sortedCodecIndices, id: \.self) { codecIndex in
                            Text(cameras[localBrand].models[localModel].codecs[codecIndex].name).tag(codecIndex)
                        }
                    } label: {
                        HStack {
                            Label("Codec", systemImage: "film.fill")
                                .foregroundStyle(.foreground)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    // Add bitrate display
                    HStack {
                        Spacer()
                        Text("\(String(format: "%.1f", cameras[localBrand].models[localModel].codecs[localCodec].bitrate)) Mbps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }
        }
        .onAppear {
            if case .additionalCamera(camera.id) = activePicker {
                // Keep current values
            } else {
                localBrand = camera.brand
                localModel = camera.model
                localCodec = camera.codec
            }
        }
    }
    
    private func updateCamera(brand: Int? = nil, model: Int? = nil, codec: Int? = nil) {
        guard let index = settings.additionalCameras.firstIndex(where: { $0.id == camera.id }) else { return }
        var cameras = settings.additionalCameras
        if let brand = brand {
            cameras[index].brand = brand
            cameras[index].model = 0
            cameras[index].codec = 0
        }
        if let model = model {
            cameras[index].model = model
            cameras[index].codec = 0
        }
        if let codec = codec {
            cameras[index].codec = codec
        }
        settings.additionalCameras = cameras
    }
}

#Preview {
    let settings = UserSettings()
    return NavigationStack {
        DataCalculatorView()
            .environmentObject(settings)
    }
} 
