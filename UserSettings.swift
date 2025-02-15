public final class UserSettings: ObservableObject {
    // Add reference to CameraDatabase to check valid indices
    private let cameraDatabase = CameraDatabase.shared
    
    // Existing properties
    @Published var selectedBrand: Int
    @Published var selectedModel: Int
    @Published var selectedCodec: Int
    @Published var recordingHours: Double
    @Published var additionalCameras: [AdditionalCamera]
    @Published var mainCameraName: String
    @Published var selectedAccessories: Set<Int>
    
    // New property for saved setups
    @Published var savedSetups: [KitSetup]
    
    // Calculator-specific states remain unchanged
    @Published var batteryCalcBrand: Int
    @Published var batteryCalcModel: Int
    @Published var batteryCalcAccessories: Set<Int>
    
    @Published var dataCalcBrand: Int
    @Published var dataCalcModel: Int
    @Published var dataCalcCodec: Int
    
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
        
        // Initialize other properties
        self.selectedCodec = UserDefaults.standard.integer(forKey: "SelectedCodec")
        self.recordingHours = UserDefaults.standard.double(forKey: "RecordingHours")
        self.mainCameraName = UserDefaults.standard.string(forKey: "MainCameraName") ?? "Camera 1"
        
        // Initialize additionalCameras
        if let data = UserDefaults.standard.data(forKey: "AdditionalCameras"),
           let decoded = try? JSONDecoder().decode([AdditionalCamera].self, from: data) {
            self.additionalCameras = decoded
        } else {
            self.additionalCameras = []
        }
        
        // Initialize calculator states
        self.batteryCalcBrand = self.selectedBrand
        self.batteryCalcModel = self.selectedModel
        self.batteryCalcAccessories = self.selectedAccessories
        
        self.dataCalcBrand = self.selectedBrand
        self.dataCalcModel = self.selectedModel
        self.dataCalcCodec = 0
        
        setupPropertyObservers()
    }
    
    // Add methods for managing setups
    func saveCurrentSetup(name: String) {
        let newSetup = KitSetup(
            id: UUID(),
            name: name,
            brand: selectedBrand,
            model: selectedModel,
            accessories: selectedAccessories,
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
        // Update current selection
        selectedBrand = setup.brand
        selectedModel = setup.model
        selectedAccessories = setup.accessories
        
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
    
    // Existing methods remain unchanged
    // ... rest of the class implementation ...
} 