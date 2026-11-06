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

    // MARK: Restyle v4 — presentation state only
    @Environment(\.openURL) private var openURL
    @State private var showCameraSheet = false
    @State private var cameraSheetStep: DataPickerStep = .brand
    
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
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ThemedBackButton(title: "Tools") {
                        dismiss()
                    }
                    .padding(.horizontal, Theme.Spacing.titleMargin)
                    .padding(.top, 4)

                    ScreenTitle(text: "Data Usage")
                        .padding(.top, 4)

                    VStack(spacing: 0) {
                        storageHero
                            .padding(.top, 16)
                        durationSection
                        mainCameraSection

                        // Additional Cameras Section
                        ForEach(settings.additionalCameras) { camera in
                            AdditionalCameraView(
                                camera: camera,
                                settings: settings,
                                cameras: cameras,
                                activePicker: $activePicker
                            )
                        }

                        OutlineButton("+ Add camera") {
                            addCamera()
                        }
                        .padding(.top, 24)

                        TextLink("Request camera / codec addition") {
                            if let url = URL(string: "mailto:app@stevepmann.com") {
                                openURL(url)
                            }
                        }
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, Theme.Spacing.cardMargin)
                    .padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .themedScreen()
            .sheet(isPresented: $showCameraSheet) {
                CameraPickerFlow(
                    step: $cameraSheetStep,
                    brandOptions: dataBrandOptions(cameras: cameras, sorted: sortedBrandIndices),
                    modelOptions: dataModelOptions(brand: currentBrand, sorted: sortedModelIndices),
                    codecOptions: dataCodecOptions(model: currentModel, sorted: sortedCodecIndices),
                    selectedBrand: currentBrandIndex,
                    selectedModel: currentModelIndex,
                    selectedCodec: currentCodecIndex,
                    onBrand: { selectedBrandBinding.wrappedValue = $0 },
                    onModel: { selectedModelBinding.wrappedValue = $0 },
                    onCodec: { selectedCodecBinding.wrappedValue = $0 },
                    onDone: { showCameraSheet = false }
                )
                .themedSheet()
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

// MARK: - Restyle v4: Data screen sections
//
// Presentation only. Storage figures use the existing totalStorageRequired and the same
// per-camera expression the old "Breakdown" used (bitrate * 0.45 * recordingHours).
// Picker taps go through the existing bindings, so all reset / save behaviour is unchanged.

extension DataCalculatorView {

    /// One legend / bar entry per camera (main first, then additional cameras in order)
    fileprivate struct StorageEntry: Identifiable {
        let id: String
        let label: String
        let gigabytes: Double
    }

    fileprivate var storageEntries: [StorageEntry] {
        var entries = [StorageEntry(
            id: "main",
            label: "\(settings.mainCameraName) · \(currentModel.name)",
            gigabytes: currentCodec.bitrate * 0.45 * settings.recordingHours
        )]
        for camera in settings.additionalCameras {
            let model = cameras[camera.brand].models[camera.model]
            let codec = model.codecs[camera.codec]
            entries.append(StorageEntry(
                id: camera.id.uuidString,
                label: "\(camera.name) · \(model.name)",
                gigabytes: codec.bitrate * 0.45 * settings.recordingHours
            ))
        }
        return entries
    }

    // MARK: Hero

    var storageHero: some View {
        ResultHero {
            Text("Total required storage")
                .microLabel()

            VStack(alignment: .leading, spacing: 2) {
                if totalStorageRequired >= 1000 {
                    HeroNumber(value: String(format: "%.2f", totalStorageRequired / 1000), unit: "TB")
                    Text("\(String(format: "%.1f", totalStorageRequired)) GB")
                        .font(Theme.Fonts.mono(15))
                        .foregroundStyle(Theme.Colors.textTertiary)
                } else {
                    HeroNumber(value: String(format: "%.1f", totalStorageRequired), unit: "GB")
                }
            }

            StorageStackedBar(values: storageEntries.map(\.gigabytes))

            VStack(spacing: 10) {
                ForEach(Array(storageEntries.enumerated()), id: \.element.id) { position, entry in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(segmentColor(position))
                            .frame(width: 8, height: 8)
                        Text(entry.label)
                            .font(Theme.Fonts.archivo(15))
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .lineLimit(1)
                        Spacer(minLength: 8)
                        Text("\(String(format: "%.1f", entry.gigabytes)) GB")
                            .font(Theme.Fonts.mono(15))
                            .foregroundStyle(Theme.Colors.textTertiary)
                    }
                }
            }
        }
    }

    // MARK: Recording duration

    var durationSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "1 · Recording duration")
            GroupedCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Per camera")
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Spacer()
                        Text("\(settings.recordingHours, specifier: "%.1f")")
                            .font(Theme.Fonts.mono(22))
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Text("hrs")
                            .font(Theme.Fonts.mono(15))
                            .foregroundStyle(Theme.Colors.textTertiary)
                    }
                    Slider(value: $settings.recordingHours, in: 0...10, step: 0.1)
                        .tint(Theme.Colors.paper)
                }
                .padding(.horizontal, Theme.Spacing.rowPadding)
                .padding(.vertical, 14)
            }
        }
    }

    // MARK: Camera 1

    var mainCameraSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "Camera 1", dotColor: segmentColor(0))
            GroupedCard {
                SettingRow("Name") {
                    TextField("Camera Name", text: $settings.mainCameraName)
                        .multilineTextAlignment(.trailing)
                        .font(Theme.Fonts.body)
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
                RowDivider()
                SettingRow("Brand", value: currentBrand.name, chevron: true) {
                    openCameraSheet(at: .brand)
                }
                RowDivider()
                SettingRow("Model", value: currentModel.name, chevron: true) {
                    openCameraSheet(at: .model)
                }
                RowDivider()
                SettingRow("Codec",
                           subLabel: "\(String(format: "%.1f", currentCodec.bitrate)) Mbps",
                           value: currentCodec.name,
                           chevron: true) {
                    openCameraSheet(at: .codec)
                }
            }
        }
    }

    private func openCameraSheet(at step: DataPickerStep) {
        cameraSheetStep = step
        showCameraSheet = true
    }
}

// MARK: - Shared Data helpers (file scope)

/// Camera colour by position: rose, Paper, #A09679, #6F6656 (repeats after four)
fileprivate func segmentColor(_ position: Int) -> Color {
    let colors = Theme.Colors.cameraSegments
    return colors[position % colors.count]
}

fileprivate func dataBrandOptions(cameras: [CameraData], sorted: [Int]) -> [PickerOption] {
    sorted.map { index in
        let count = cameras[index].models.count
        return PickerOption(id: index, title: cameras[index].name,
                            subtitle: count == 1 ? "1 model" : "\(count) models")
    }
}

fileprivate func dataModelOptions(brand: CameraData, sorted: [Int]) -> [PickerOption] {
    sorted.map { index in
        let count = brand.models[index].codecs.count
        return PickerOption(id: index, title: brand.models[index].name,
                            subtitle: count == 1 ? "1 codec" : "\(count) codecs")
    }
}

fileprivate func dataCodecOptions(model: CameraModel, sorted: [Int]) -> [PickerOption] {
    sorted.map { index in
        PickerOption(id: index, title: model.codecs[index].name,
                     subtitle: "\(String(format: "%.1f", model.codecs[index].bitrate)) Mbps")
    }
}

/// Which list the camera sheet is showing
enum DataPickerStep {
    case brand, model, codec
}

/// Brand → Model → Codec sheet. Picking a brand moves on to models, a model moves on to codecs,
/// a codec closes the sheet. All selections are reported back through the closures.
fileprivate struct CameraPickerFlow: View {
    @Binding var step: DataPickerStep
    let brandOptions: [PickerOption]
    let modelOptions: [PickerOption]
    let codecOptions: [PickerOption]
    let selectedBrand: Int
    let selectedModel: Int
    let selectedCodec: Int
    let onBrand: (Int) -> Void
    let onModel: (Int) -> Void
    let onCodec: (Int) -> Void
    let onDone: () -> Void

    var body: some View {
        switch step {
        case .brand:
            SheetScaffold(title: "Brand", onDone: onDone) {
                SelectionList(options: brandOptions, selectedID: selectedBrand) { id in
                    onBrand(id)
                    withAnimation(.snappy) { step = .model }
                }
            }
        case .model:
            SheetScaffold(title: "Model", onDone: onDone) {
                SelectionList(options: modelOptions, selectedID: selectedModel) { id in
                    onModel(id)
                    withAnimation(.snappy) { step = .codec }
                }
            }
        case .codec:
            SheetScaffold(title: "Codec", onDone: onDone) {
                SelectionList(options: codecOptions, selectedID: selectedCodec) { id in
                    onCodec(id)
                    onDone()
                }
            }
        }
    }
}

/// Stacked bar: one segment per camera, 3pt gaps, animated.
fileprivate struct StorageStackedBar: View {
    let values: [Double]
    var height: CGFloat = 12

    var body: some View {
        GeometryReader { proxy in
            let total = values.reduce(0, +)
            let gap: CGFloat = 3
            let usable = max(proxy.size.width - gap * CGFloat(max(values.count - 1, 0)), 0)
            HStack(spacing: gap) {
                if total > 0 {
                    ForEach(Array(values.enumerated()), id: \.offset) { position, value in
                        Capsule()
                            .fill(segmentColor(position))
                            .frame(width: usable * CGFloat(value / total))
                    }
                } else {
                    Capsule().fill(Theme.Colors.trackInactive)
                }
            }
        }
        .frame(height: height)
        .animation(Theme.Motion.result, value: values)
        .accessibilityHidden(true)
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

    // MARK: Restyle v4 — presentation state only
    @State private var showSheet = false
    @State private var sheetStep: DataPickerStep = .brand
    
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
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "Camera \((cameraIndex ?? 0) + 2)",
                                dotColor: segmentColor((cameraIndex ?? 0) + 1),
                                actionTitle: "Remove",
                                action: removeCamera)
            GroupedCard {
                SettingRow("Name") {
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
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textTertiary)
                }
                RowDivider()
                SettingRow("Brand", value: cameras[localBrand].name, chevron: true) {
                    sheetStep = .brand
                    showSheet = true
                }
                RowDivider()
                SettingRow("Model", value: cameras[localBrand].models[localModel].name, chevron: true) {
                    sheetStep = .model
                    showSheet = true
                }
                RowDivider()
                SettingRow("Codec",
                           subLabel: "\(String(format: "%.1f", cameras[localBrand].models[localModel].codecs[localCodec].bitrate)) Mbps",
                           value: cameras[localBrand].models[localModel].codecs[localCodec].name,
                           chevron: true) {
                    sheetStep = .codec
                    showSheet = true
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            CameraPickerFlow(
                step: $sheetStep,
                brandOptions: dataBrandOptions(cameras: cameras, sorted: sortedBrandIndices),
                modelOptions: dataModelOptions(brand: cameras[localBrand], sorted: sortedModelIndices),
                codecOptions: dataCodecOptions(model: cameras[localBrand].models[localModel], sorted: sortedCodecIndices),
                selectedBrand: localBrand,
                selectedModel: localModel,
                selectedCodec: localCodec,
                onBrand: { brandBinding.wrappedValue = $0 },
                onModel: { modelBinding.wrappedValue = $0 },
                onCodec: { codecBinding.wrappedValue = $0 },
                onDone: { showSheet = false }
            )
            .themedSheet()
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
