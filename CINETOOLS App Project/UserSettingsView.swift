import SwiftUI

class UserSettings: ObservableObject {
    @Published var selectedBrand: Int
    @Published var selectedModel: Int
    @Published var selectedCodec: Int
    @Published var selectedAccessories: Set<Int>
    
    init() {
        self.selectedBrand = UserDefaults.standard.integer(forKey: "SelectedBrand")
        self.selectedModel = UserDefaults.standard.integer(forKey: "SelectedModel")
        self.selectedCodec = UserDefaults.standard.integer(forKey: "SelectedCodec")
        self.selectedAccessories = Set(UserDefaults.standard.array(forKey: "SelectedAccessories") as? [Int] ?? [])
    }
    
    func saveSettings() {
        UserDefaults.standard.set(selectedBrand, forKey: "SelectedBrand")
        UserDefaults.standard.set(selectedModel, forKey: "SelectedModel")
        UserDefaults.standard.set(selectedCodec, forKey: "SelectedCodec")
        UserDefaults.standard.set(Array(selectedAccessories), forKey: "SelectedAccessories")
    }
}

struct UserSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: UserSettings
    @State private var isSaved = false
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    let cameras = CameraDatabase.shared.getCameraForDataCalc()
    let accessories = CameraDatabase.shared.getAccessories()
    
    // Add these computed properties for safety
    private var selectedBrand: Int {
        min(settings.selectedBrand, max(0, cameras.count - 1))
    }
    
    private var selectedModel: Int {
        let modelCount = cameras[selectedBrand].models.count
        return min(settings.selectedModel, max(0, modelCount - 1))
    }
    
    // Add this computed property to filter results
    private var filteredResults: (cameras: [(brand: Int, model: Int)], accessories: [Int]) {
        if searchText.isEmpty {
            return ([], [])
        }
        
        let searchTerms = searchText.lowercased().split(separator: " ")
        
        // Filter cameras
        var matchingCameras: [(brand: Int, model: Int)] = []
        for (brandIndex, brand) in cameras.enumerated() {
            for (modelIndex, model) in brand.models.enumerated() {
                let fullName = "\(brand.name) \(model.name)".lowercased()
                if searchTerms.allSatisfy({ fullName.contains($0) }) {
                    matchingCameras.append((brandIndex, modelIndex))
                }
            }
        }
        
        // Filter accessories
        let matchingAccessories = accessories.enumerated().compactMap { index, accessory in
            searchTerms.allSatisfy { accessory.name.lowercased().contains($0) } ? index : nil
        }
        
        return (matchingCameras, matchingAccessories)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 16)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search for your kit", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .autocorrectionDisabled()
                            .foregroundColor(.secondary)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 200)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Search results
                    if !searchText.isEmpty {
                        ModernCard {
                            VStack(alignment: .leading, spacing: 16) {
                                let results = filteredResults
                                
                                if !results.cameras.isEmpty {
                                    Text("Cameras")
                                        .font(.headline)
                                    
                                    ForEach(results.cameras, id: \.model) { brand, model in
                                        Button {
                                            settings.selectedBrand = brand
                                            settings.selectedModel = model
                                            searchText = ""
                                        } label: {
                                            HStack {
                                                Text("\(cameras[brand].name) \(cameras[brand].models[model].name)")
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                if settings.selectedBrand == brand && settings.selectedModel == model {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                
                                if !results.accessories.isEmpty {
                                    if !results.cameras.isEmpty {
                                        Divider()
                                    }
                                    
                                    Text("Accessories")
                                        .font(.headline)
                                    
                                    ForEach(results.accessories, id: \.self) { index in
                                        Button {
                                            if settings.selectedAccessories.contains(index) {
                                                settings.selectedAccessories.remove(index)
                                            } else {
                                                settings.selectedAccessories.insert(index)
                                            }
                                            settings.saveSettings()
                                        } label: {
                                            HStack {
                                                Text(accessories[index].name)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                if settings.selectedAccessories.contains(index) {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                
                                if results.cameras.isEmpty && results.accessories.isEmpty {
                                    Text("No matches found")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Camera and Peripherals Card
                    ModernCard {
                        VStack(spacing: 12) {
                            // Camera Section
                            Text("1. Add Your Camera")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            Picker(selection: $settings.selectedBrand) {
                                ForEach(0..<cameras.count, id: \.self) { index in
                                    Text(cameras[index].name).tag(index)
                                }
                            } label: {
                                HStack {
                                    Text("Brand")
                                        .font(.title2)
                                        .foregroundColor(.primary)                                        
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary.opacity(100))
                                }
                            }
                            .pickerStyle(.navigationLink)
                            
                            Divider()
                            
                            Picker(selection: $settings.selectedModel) {
                                ForEach(0..<cameras[selectedBrand].models.count, id: \.self) { index in
                                    Text(cameras[selectedBrand].models[index].name).tag(index)
                                }
                            } label: {
                                HStack {
                                    Text("Model")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary.opacity(100))
                                }
                            }
                            .pickerStyle(.navigationLink)
                            
                            Divider()
                            
                            PowerDrawRow(
                                value: cameras[selectedBrand].models[selectedModel].powerDraw,
                                icon: "bolt.fill",
                                color: .orange
                            )
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Peripherals Section
                            Text("2. Add Peripherals")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            ForEach(AccessoryCategory.allCases, id: \.self) { category in
                                DisclosureGroup {
                                    VStack(spacing: 12) {
                                        ForEach(accessories.indices, id: \.self) { index in
                                            if accessories[index].category == category {
                                                ModernAccessoryToggle(
                                                    accessory: accessories[index],
                                                    isSelected: settings.selectedAccessories.contains(index),
                                                    action: {
                                                        if settings.selectedAccessories.contains(index) {
                                                            settings.selectedAccessories.remove(index)
                                                        } else {
                                                            settings.selectedAccessories.insert(index)
                                                        }
                                                        settings.saveSettings()
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
                        }
                    }
                    .padding(.horizontal)
                    
                    // Selected Setup Card
                    ModernCard {
                        VStack(spacing: 12) {
                            // Title
                            Label {
                                Text("Selected Setup")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            } icon: {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            // Camera Info
                            HStack {
                                
                                Text("\(cameras[selectedBrand].name) \(cameras[selectedBrand].models[selectedModel].name)")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(String(format: "%.1f", cameras[selectedBrand].models[selectedModel].powerDraw))W")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                            
                            Divider()
                            
                            // Only show peripherals section if accessories are selected
                            if !settings.selectedAccessories.isEmpty {
                              
                                
                                // Peripherals List
                                VStack(alignment: .leading, spacing: 8) {
                                     ForEach(Array(settings.selectedAccessories).sorted(), id: \.self) { index in
                                        HStack {
                                            Text(accessories[index].name)
                                                .font(.subheadline)
                                            Spacer()
                                            Text("\(String(format: "%.1f", accessories[index].powerDraw))W")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .monospacedDigit()
                                        }
                                    }
                                }
                            }
                            
                            // Always show total power draw
                            Divider()
                            
                            HStack {
                                Text("Total Power Draw:")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(String(format: "%.1f", settings.selectedAccessories.reduce(cameras[selectedBrand].models[selectedModel].powerDraw) { $0 + accessories[$1].powerDraw }))W")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save Kit Bag Button
                    ModernCard {
                        VStack(spacing: 16) {
                            Button(action: {
                                settings.saveSettings()
                                withAnimation {
                                    isSaved = true
                                }
                                // Reset after delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        isSaved = false
                                    }
                                }
                            }) {
                                HStack {
                                    if isSaved {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.headline)
                                        Text("Kit Bag Saved!")
                                            .font(.headline)
                                    } else {
                                        Image(systemName: "square.and.arrow.down.fill")
                                            .font(.headline)
                                        Text("Save Your Kit Bag")
                                            .font(.headline)
                                    }
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isSaved ? Color.green : Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            
                            Text("Save your kit bag for next time, and it will be pre-selected when opening calculators")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(8)
                    }
                    .padding(.horizontal)
                    
                    // Footer content
                    VStack(spacing: 16) {
                        NavigationLink(destination: SupportPageView()) { 
                            Text("Request Camera/Peripheral Addition") 
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        
                        // Logo
                        VStack(spacing: 1) {
                            Image("-headerlogo-")
                                .resizable()
                                .frame(width: 300, height: 100)
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.vertical)
            }
            
            // Floating back button remains unchanged
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

#Preview {
    UserSettingsView()
        .environmentObject(UserSettings())
} 
