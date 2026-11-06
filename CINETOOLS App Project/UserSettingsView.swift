import SwiftUI

struct UserSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: UserSettings
    @State private var isSaved = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var isShowingNewSetupSheet = false
    @State private var newSetupName = ""
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
    
    // Add these sorted indices properties
    private var sortedBrandIndices: [Int] {
        cameras.indices.sorted { 
            cameras[$0].name.lowercased() < cameras[$1].name.lowercased() 
        }
    }
    
    private var sortedModelIndices: [Int] {
        cameras[selectedBrand].models.indices.sorted {
            cameras[selectedBrand].models[$0].name.lowercased() < 
            cameras[selectedBrand].models[$1].name.lowercased()
        }
    }
    
    // Add this computed property to filter results
    private var filteredResults: (cameras: [(brand: Int, model: Int)], accessories: [Int]) {
        if searchText.isEmpty {
            return ([], [])
        }
        
        let searchTerms = searchText.lowercased().split(separator: " ")
        
        // Filter and sort cameras
        var matchingCameras: [(brand: Int, model: Int)] = []
        for (brandIndex, brand) in cameras.enumerated() {
            for (modelIndex, model) in brand.models.enumerated() {
                let fullName = "\(brand.name) \(model.name)".lowercased()
                if searchTerms.allSatisfy({ fullName.contains($0) }) {
                    matchingCameras.append((brandIndex, modelIndex))
                }
            }
        }
        
        // Sort matching cameras alphabetically
        matchingCameras.sort { first, second in
            let firstName = "\(cameras[first.brand].name) \(cameras[first.brand].models[first.model].name)".lowercased()
            let secondName = "\(cameras[second.brand].name) \(cameras[second.brand].models[second.model].name)".lowercased()
            return firstName < secondName
        }
        
        // Filter and sort accessories
        let matchingAccessories = accessories.enumerated()
            .compactMap { index, accessory in
                searchTerms.allSatisfy { accessory.name.lowercased().contains($0) } ? index : nil
            }
            .sorted { accessories[$0].name.lowercased() < accessories[$1].name.lowercased() }
        
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
                                ForEach(sortedBrandIndices, id: \.self) { index in
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
                                ForEach(sortedModelIndices, id: \.self) { index in
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
                                                VStack(alignment: .leading, spacing: 8) {
                                                    ModernAccessoryToggle(
                                                        accessory: accessories[index],
                                                        isSelected: settings.selectedAccessories.contains(index),
                                                        action: {
                                                            if settings.selectedAccessories.contains(index) {
                                                                settings.selectedAccessories.remove(index)
                                                                if accessories[index].category.supportsQuantity {
                                                                    settings.focusSystemQuantities.removeValue(forKey: index)
                                                                }
                                                            } else {
                                                                settings.selectedAccessories.insert(index)
                                                                if accessories[index].category.supportsQuantity {
                                                                    settings.focusSystemQuantities[index] = 1
                                                                }
                                                            }
                                                            settings.saveSettings()
                                                        }
                                                    )
                                                    
                                                    // Add quantity selector for focus systems
                                                    if accessories[index].category.supportsQuantity && settings.selectedAccessories.contains(index) {
                                                        HStack {
                                                            Text("Quantity")
                                                                .font(.subheadline)
                                                                .foregroundColor(.secondary)
                                                            
                                                            Spacer()
                                                            
                                                            HStack(spacing: 12) {
                                                                Button(action: {
                                                                    if let current = settings.focusSystemQuantities[index], current > 1 {
                                                                        settings.focusSystemQuantities[index] = current - 1
                                                                        settings.saveSettings()
                                                                    }
                                                                }) {
                                                                    Image(systemName: "minus.circle.fill")
                                                                        .foregroundStyle(.gray)
                                                                }
                                                                
                                                                Text("\(settings.focusSystemQuantities[index] ?? 1)")
                                                                    .font(.headline)
                                                                    .monospacedDigit()
                                                                    .frame(minWidth: 30)
                                                                
                                                                Button(action: {
                                                                    let current = settings.focusSystemQuantities[index] ?? 1
                                                                    if current < 99 {
                                                                        settings.focusSystemQuantities[index] = current + 1
                                                                        settings.saveSettings()
                                                                    }
                                                                }) {
                                                                    Image(systemName: "plus.circle.fill")
                                                                        .foregroundStyle(.blue)
                                                                }
                                                            }
                                                        }
                                                        .padding(.leading, 36)
                                                    }
                                                }
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
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(settings.selectedAccessories).sorted(), id: \.self) { index in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(accessories[index].name)
                                                    .font(.subheadline)
                                                if accessories[index].category.supportsQuantity {
                                                    Text("× \(settings.focusSystemQuantities[index] ?? 1)")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }
                                                Spacer()
                                                let powerDraw = accessories[index].powerDraw * 
                                                Double(accessories[index].category.supportsQuantity ?
                                                    settings.focusSystemQuantities[index] ?? 1 : 1)
                                                Text("\(String(format: "%.1f", powerDraw))W")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .monospacedDigit()
                                            }
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
                                let totalPower = settings.selectedAccessories.reduce(
                                    cameras[selectedBrand].models[selectedModel].powerDraw
                                ) { total, index in
                                    let accessory = accessories[index]
                                    if accessories[index].category.supportsQuantity {
                                        return total + (accessory.powerDraw *
                                            Double(settings.focusSystemQuantities[index] ?? 1))
                                    } else {
                                        return total + accessory.powerDraw
                                    }
                                }
                                Text("\(String(format: "%.1f", totalPower))W")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Saved Kit Bags Card (replaces old Save Kit Bag card)
                    ModernCard {
                        VStack(spacing: 16) {
                            // Title and Add Button
                            HStack {
                                Label {
                                    Text("Saved Setups")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                } icon: {
                                    Image(systemName: "folder.fill")
                                        .foregroundStyle(.blue)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    isShowingNewSetupSheet = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                }
                            }
                            
                            Divider()
                            
                            // Saved Setups List
                            if settings.savedSetups.isEmpty {
                                Text("No saved setups yet")
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical)
                            } else {
                                ForEach(settings.savedSetups) { setup in
                                    VStack {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(setup.name)
                                                    .font(.headline)
                                                Text("\(cameras[setup.brand].name) \(cameras[setup.brand].models[setup.model].name)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            if setup.isActive {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.green)
                                            }
                                            
                                            Button(action: {
                                                settings.deleteSetup(setup)
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundStyle(.red)
                                            }
                                            .padding(.leading)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            settings.activateSetup(setup)
                                        }
                                        
                                        if setup.id != settings.savedSetups.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            
                            Text("Save your most used setups for next time, by making your selections above, then hitting the plus symbol and saving your setup. It will then be pre-selected when opening calculators")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
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
            
            // Floating back button
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
        .sheet(isPresented: $isShowingNewSetupSheet) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Setup Name", text: $newSetupName)
                    }
                }
                .navigationTitle("New Setup")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        isShowingNewSetupSheet = false
                        newSetupName = ""
                    },
                    trailing: Button("Save") {
                        if !newSetupName.isEmpty {
                            settings.saveCurrentSetup(name: newSetupName)
                            isShowingNewSetupSheet = false
                            newSetupName = ""
                        }
                    }
                    .disabled(newSetupName.isEmpty)
                )
            }
            .presentationDetents([.height(200)])
        }
    }
}

#Preview {
    let settings = UserSettings()
    NavigationStack {
        UserSettingsView()
            .environmentObject(settings)
    }
} 
