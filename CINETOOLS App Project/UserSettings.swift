import SwiftUI
import Combine

// Add KitSetup struct before UserSettings class
struct KitSetup: Codable, Identifiable {
    let id: UUID
    let name: String
    var brand: Int
    var model: Int
    var accessories: Set<Int>
    var focusSystemQuantities: [Int: Int] // [accessoryIndex: quantity]
    var isActive: Bool
}

public final class UserSettings: ObservableObject {
    // Add reference to CameraDatabase to check valid indices
    private let cameraDatabase = CameraDatabase.shared
    
    @Published var selectedBrand: Int
    @Published var selectedModel: Int
    @Published var selectedCodec: Int
    @Published var recordingHours: Double
    @Published var additionalCameras: [AdditionalCamera]
    @Published var mainCameraName: String
    @Published var selectedAccessories: Set<Int>
    
    // Calculator-specific states
    @Published var batteryCalcBrand: Int
    @Published var batteryCalcModel: Int
    @Published var batteryCalcAccessories: Set<Int>
    
    @Published var dataCalcBrand: Int
    @Published var dataCalcModel: Int
    @Published var dataCalcCodec: Int
    
    @Published var savedSetups: [KitSetup]
    
    // Add new property
    @Published var focusSystemQuantities: [Int: Int] = [:] // [accessoryIndex: quantity]
    
    private let defaults = UserDefaults.standard
    
    public init() {
        // Load saved setups
        if let data = UserDefaults.standard.data(forKey: "SavedSetups"),
           let decoded = try? JSONDecoder().decode([KitSetup].self, from: data) {
            self.savedSetups = decoded
            // Find active setup
            if let activeSetup = decoded.first(where: { $0.isActive }) {
                self.selectedBrand = activeSetup.brand
                self.selectedModel = activeSetup.model
                self.selectedAccessories = activeSetup.accessories
            } else {
                // Use defaults if no active setup
                self.selectedBrand = 0
                self.selectedModel = 0
                self.selectedAccessories = []
            }
        } else {
            self.savedSetups = []
            self.selectedBrand = 0
            self.selectedModel = 0
            self.selectedAccessories = []
        }
        
        // Get the camera data for validation
        let cameras = cameraDatabase.getCameraForDataCalc()
        
        // Load and validate brand index
        var loadedBrand = UserDefaults.standard.integer(forKey: "SelectedBrand")
        if loadedBrand >= cameras.count {
            loadedBrand = 0 // Reset to 0 if out of range
        }
        
        // Load and validate model index
        var loadedModel = UserDefaults.standard.integer(forKey: "SelectedModel")
        if loadedModel >= cameras[loadedBrand].models.count {
            loadedModel = 0 // Reset to 0 if out of range
        }
        
        let loadedCodec = UserDefaults.standard.integer(forKey: "SelectedCodec")
        let loadedAccessories = Set(UserDefaults.standard.array(forKey: "SelectedAccessories") as? [Int] ?? [])
        
        // Initialize base properties with validated values
        self.selectedBrand = loadedBrand
        self.selectedModel = loadedModel
        self.selectedCodec = loadedCodec
        self.selectedAccessories = loadedAccessories
        self.recordingHours = UserDefaults.standard.double(forKey: "RecordingHours")
        self.mainCameraName = UserDefaults.standard.string(forKey: "MainCameraName") ?? "Camera 1"
        
        // Initialize additionalCameras
        if let data = UserDefaults.standard.data(forKey: "AdditionalCameras"),
           let decoded = try? JSONDecoder().decode([AdditionalCamera].self, from: data) {
            self.additionalCameras = decoded
        } else {
            self.additionalCameras = []
        }
        
        // Initialize calculator states with validated values
        self.batteryCalcBrand = loadedBrand
        self.batteryCalcModel = loadedModel
        self.batteryCalcAccessories = loadedAccessories
        
        self.dataCalcBrand = loadedBrand
        self.dataCalcModel = loadedModel
        self.dataCalcCodec = 0
        
        // After initialization, set up the property observers
        setupPropertyObservers()
    }
    
    private func setupPropertyObservers() {
        $selectedBrand
            .dropFirst()
            .sink { [weak self] newValue in
                guard let self = self else { return }
                
                // Validate brand index
                let cameras = self.cameraDatabase.getCameraForDataCalc()
                if newValue < cameras.count {
                    // Reset model if needed
                    if self.selectedModel >= cameras[newValue].models.count {
                        self.selectedModel = 0
                    }
                    
                    self.saveSettings()
                    self.batteryCalcBrand = newValue
                    self.dataCalcBrand = newValue
                }
            }
            .store(in: &cancellables)
        
        $selectedModel
            .dropFirst()
            .sink { [weak self] newValue in
                guard let self = self else { return }
                
                // Validate model index
                let cameras = self.cameraDatabase.getCameraForDataCalc()
                if self.selectedBrand < cameras.count && 
                   newValue < cameras[self.selectedBrand].models.count {
                    self.saveSettings()
                    self.batteryCalcModel = newValue
                    self.dataCalcModel = newValue
                }
            }
            .store(in: &cancellables)
        
        $selectedAccessories
            .dropFirst()
            .sink { [weak self] newValue in
                self?.saveSettings()
                self?.batteryCalcAccessories = newValue
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func saveSettings() {
        defaults.set(selectedBrand, forKey: "SelectedBrand")
        defaults.set(selectedModel, forKey: "SelectedModel")
        defaults.set(selectedCodec, forKey: "SelectedCodec")
        defaults.set(recordingHours, forKey: "RecordingHours")
        defaults.set(mainCameraName, forKey: "MainCameraName")
        defaults.set(Array(selectedAccessories), forKey: "SelectedAccessories")
        
        if let encoded = try? JSONEncoder().encode(additionalCameras) {
            defaults.set(encoded, forKey: "AdditionalCameras")
        }
    }
    
    func resetCalculatorStates() {
        // Validate indices before resetting
        let cameras = cameraDatabase.getCameraForDataCalc()
        var brand = selectedBrand
        var model = selectedModel
        
        if brand >= cameras.count {
            brand = 0
        }
        if model >= cameras[brand].models.count {
            model = 0
        }
        
        batteryCalcBrand = brand
        batteryCalcModel = model
        batteryCalcAccessories = selectedAccessories
        
        dataCalcBrand = brand
        dataCalcModel = model
    }
    
    // Add helper method to validate indices
    private func validateIndices() {
        let cameras = cameraDatabase.getCameraForDataCalc()
        if selectedBrand >= cameras.count {
            selectedBrand = 0
        }
        if selectedModel >= cameras[selectedBrand].models.count {
            selectedModel = 0
        }
    }
    
    func saveCurrentSetup(name: String) {
        let newSetup = KitSetup(
            id: UUID(),
            name: name,
            brand: selectedBrand,
            model: selectedModel,
            accessories: selectedAccessories,
            focusSystemQuantities: focusSystemQuantities,
            isActive: true
        )
        
        // Deactivate other setups
        savedSetups = savedSetups.map { setup in
            var updatedSetup = setup
            updatedSetup.isActive = false
            return updatedSetup
        }
        
        savedSetups.append(newSetup)
        saveSetups()
    }
    
    func activateSetup(_ setup: KitSetup) {
        selectedBrand = setup.brand
        selectedModel = setup.model
        selectedAccessories = setup.accessories
        focusSystemQuantities = setup.focusSystemQuantities
        
        // Update active status
        savedSetups = savedSetups.map { existingSetup in
            var updatedSetup = existingSetup
            updatedSetup.isActive = existingSetup.id == setup.id
            return updatedSetup
        }
        
        saveSetups()
        saveSettings()
    }
    
    func deleteSetup(_ setup: KitSetup) {
        savedSetups.removeAll { $0.id == setup.id }
        saveSetups()
    }
    
    private func saveSetups() {
        if let encoded = try? JSONEncoder().encode(savedSetups) {
            defaults.set(encoded, forKey: "SavedSetups")
        }
    }
} 