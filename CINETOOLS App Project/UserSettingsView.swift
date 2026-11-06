import SwiftUI

// Restyle v4: Kit Bag.
// The list of saved setups is the main screen; the existing kit editor
// (search, camera, peripherals, current-kit summary, name + save) opens as a sheet.
// All selection, save, activate and delete code is the same as before.

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

    /// Show "‹ Tools" when pushed from Home (hidden when used as a tab)
    var showsBackButton: Bool = true
    /// Open the editor straight away (Home "+ New" ring)
    var startsWithEditor: Bool = false

    init(showsBackButton: Bool = true, startsWithEditor: Bool = false) {
        self.showsBackButton = showsBackButton
        self.startsWithEditor = startsWithEditor
    }

    // MARK: Restyle v4 — presentation state only
    @State private var editorSheet: KitEditorSheet? = nil
    @State private var brandSheetShowsModels = false
    @State private var openBatteryFromKit = false
    @State private var showSavedToast = false

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

    // MARK: - Kit Bag (main screen)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if showsBackButton {
                    ThemedBackButton(title: "Tools") {
                        dismiss()
                    }
                    .padding(.horizontal, Theme.Spacing.titleMargin)
                    .padding(.top, 4)
                }

                ScreenTitle(text: "Kit Bag", eyebrow: "Saved setups", size: 34)
                    .padding(.top, showsBackButton ? 4 : 20)

                VStack(spacing: 12) {
                    if settings.savedSetups.isEmpty {
                        emptyState
                    } else {
                        ForEach(settings.savedSetups) { setup in
                            setupCard(setup)
                        }
                    }

                    OutlineButton("+ New setup") {
                        editorSheet = .editor
                    }
                    .padding(.top, 8)

                    NavigationLink {
                        SupportPageView()
                    } label: {
                        Text("Request camera / peripheral addition")
                            .font(Theme.Fonts.archivo(15))
                            .foregroundStyle(Theme.Colors.textTertiary)
                            .frame(maxWidth: .infinity, minHeight: Theme.Size.tapTarget)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Theme.Spacing.cardMargin)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
        }
        .scrollIndicators(.hidden)
        .themedScreen()
        .overlay(alignment: .bottom) {
            if showSavedToast {
                Text("Saved to Kit Bag")
                    .font(Theme.Fonts.archivo(15, .semibold))
                    .foregroundStyle(Theme.Colors.ink)
                    .padding(.horizontal, 20)
                    .frame(height: 44)
                    .background(Theme.Colors.paper, in: Capsule())
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $openBatteryFromKit) {
            BatteryCalculatorView()
                .environmentObject(settings)
        }
        .sheet(item: $editorSheet) { _ in
            editorView
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Theme.Radius.sheetTop)
                .presentationBackground(Theme.Colors.bg)
                .preferredColorScheme(.dark)
        }
        .onAppear {
            if startsWithEditor && editorSheet == nil {
                editorSheet = .editor
            }
        }
    }

    // MARK: Setup card

    private func setupCard(_ setup: KitSetup) -> some View {
        let camera = KitSummary.camera(brand: setup.brand, model: setup.model)
        let draw = KitSummary.drawWatts(brand: setup.brand, model: setup.model,
                                        accessories: setup.accessories,
                                        quantities: setup.focusSystemQuantities)
        let battery = KitSummary.lastBattery
        let quantity = KitSummary.lastBatteryQuantity
        let hours = draw.flatMap { d in battery.flatMap { KitSummary.runtimeHours(draw: d, battery: $0, quantity: quantity) } }
        let names = KitSummary.accessoryNames(setup.accessories, quantities: setup.focusSystemQuantities)
        let summary = ([camera?.model ?? "Camera"] + [names.joined(separator: ", ")])
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        var stats = draw.map { String(format: "%.1f W", $0) } ?? ""
        if let hours, let battery {
            stats += String(format: " · %.1f hrs on %d× ", hours, quantity) + battery.model
        }

        return HStack(alignment: .center, spacing: 14) {
            KitStoryRing(kind: .setup(tag: (camera?.model ?? "Kit").uppercased()),
                         diameter: 56,
                         showsName: false)

            VStack(alignment: .leading, spacing: 4) {
                if setup.isActive {
                    Text("Active")
                        .microLabel(10)
                }
                Text(setup.name)
                    .font(Theme.Fonts.archivo(20, .semibold))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .lineLimit(1)
                Text(summary)
                    .font(Theme.Fonts.archivo(14))
                    .foregroundStyle(Theme.Colors.textTertiary)
                    .lineLimit(1)
                if !stats.isEmpty {
                    Text(stats)
                        .font(Theme.Fonts.mono(14))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 6) {
                Button("Open") {
                    settings.activateSetup(setup)
                    openBatteryFromKit = true
                }
                .buttonStyle(PillButtonStyle())

                Button("Remove") {
                    settings.deleteSetup(setup)
                }
                .font(Theme.Fonts.archivo(14))
                .foregroundStyle(Theme.Colors.textTertiary)
                .buttonStyle(.plain)
                .frame(minHeight: 32)
            }
        }
        .padding(16)
        .background(Theme.Colors.card,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .onTapGesture {
            settings.activateSetup(setup)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("No saved setups yet")
                .font(Theme.Fonts.archivo(17, .semibold))
                .foregroundStyle(Theme.Colors.textPrimary)
            Text("Save your most used setups for next time. Tap New setup, pick your camera and peripherals, then save. It will then be pre-selected when opening calculators.")
                .font(Theme.Fonts.archivo(14))
                .foregroundStyle(Theme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.card,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
    }

    // MARK: - New setup editor (sheet)

    private var editorView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button("Cancel") {
                        editorSheet = nil
                        newSetupName = ""
                    }
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .buttonStyle(.plain)
                    Spacer()
                }
                .frame(minHeight: Theme.Size.tapTarget)
                .padding(.horizontal, Theme.Spacing.titleMargin)
                .padding(.top, 12)

                ScreenTitle(text: "New setup", eyebrow: "Kit Bag")

                VStack(spacing: 0) {
                    searchField
                        .padding(.top, 16)

                    if !searchText.isEmpty {
                        searchResults
                            .padding(.top, 12)
                    }

                    editorCameraSection
                    editorPeripheralsSection
                    editorNameSection

                    PrimaryButton("Save to Kit Bag") {
                        if !newSetupName.isEmpty {
                            settings.saveCurrentSetup(name: newSetupName)
                            editorSheet = nil
                            newSetupName = ""
                            flashSavedToast()
                        }
                    }
                    .disabled(newSetupName.isEmpty)
                    .opacity(newSetupName.isEmpty ? 0.5 : 1)
                    .padding(.top, 24)

                    Text("Your picks here are also the default kit the calculators open with.")
                        .font(Theme.Fonts.subLabel)
                        .foregroundStyle(Theme.Colors.textQuaternary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                }
                .padding(.horizontal, Theme.Spacing.cardMargin)
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.Colors.bg)
        .sheet(item: $pickerSheet) { sheet in
            pickerSheetContent(sheet)
                .themedSheet()
        }
    }

    @State private var pickerSheet: KitPickerSheet? = nil

    // Search bar
    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.Colors.textTertiary)

            TextField("Search for your kit", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textPrimary)
                .focused($isSearchFocused)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Theme.Spacing.rowPadding)
        .frame(minHeight: 48)
        .background(Theme.Colors.card, in: RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
    }

    // Search results
    private var searchResults: some View {
        let results = filteredResults
        return GroupedCard {
            if !results.cameras.isEmpty {
                resultsHeader("Cameras")
                ForEach(results.cameras, id: \.model) { brand, model in
                    Button {
                        settings.selectedBrand = brand
                        settings.selectedModel = model
                        searchText = ""
                    } label: {
                        resultRow("\(cameras[brand].name) \(cameras[brand].models[model].name)",
                                  isSelected: settings.selectedBrand == brand && settings.selectedModel == model)
                    }
                    .buttonStyle(RowButtonStyle())
                }
            }

            if !results.accessories.isEmpty {
                if !results.cameras.isEmpty {
                    RowDivider()
                }
                resultsHeader("Accessories")
                ForEach(results.accessories, id: \.self) { index in
                    Button {
                        if settings.selectedAccessories.contains(index) {
                            settings.selectedAccessories.remove(index)
                        } else {
                            settings.selectedAccessories.insert(index)
                        }
                        settings.saveSettings()
                    } label: {
                        resultRow(accessories[index].name,
                                  isSelected: settings.selectedAccessories.contains(index))
                    }
                    .buttonStyle(RowButtonStyle())
                }
            }

            if results.cameras.isEmpty && results.accessories.isEmpty {
                Text("No matches found")
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, minHeight: Theme.Size.rowMinHeight)
            }
        }
    }

    private func resultsHeader(_ title: String) -> some View {
        Text(title)
            .microLabel()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.rowPadding)
            .padding(.top, 14)
            .padding(.bottom, 4)
    }

    private func resultRow(_ title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textPrimary)
            Spacer()
            SelectionIndicator(isSelected: isSelected)
        }
        .padding(.horizontal, Theme.Spacing.rowPadding)
        .frame(minHeight: Theme.Size.rowMinHeight)
        .contentShape(Rectangle())
    }

    // 1 · Camera
    private var editorCameraSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "1 · Camera")
            GroupedCard {
                SettingRow("Brand", value: cameras[selectedBrand].name, chevron: true) {
                    brandSheetShowsModels = false
                    pickerSheet = .camera
                }
                RowDivider()
                SettingRow("Model", value: cameras[selectedBrand].models[selectedModel].name, chevron: true) {
                    brandSheetShowsModels = true
                    pickerSheet = .camera
                }
                RowDivider()
                SettingRow("Power draw",
                           value: String(format: "%.1f W", cameras[selectedBrand].models[selectedModel].powerDraw),
                           mono: true,
                           valueColor: Theme.Colors.textPrimary)
            }
        }
    }

    // 2 · Peripherals (+ total power draw, as in the old "Selected Setup" card)
    private var editorPeripheralsSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "2 · Peripherals")
            GroupedCard {
                ForEach(AccessoryCategory.allCases, id: \.self) { category in
                    let names = KitSummary.accessoryNames(
                        settings.selectedAccessories.filter { $0 < accessories.count && accessories[$0].category == category },
                        quantities: settings.focusSystemQuantities)
                    SettingRow(category.rawValue,
                               subLabel: names.isEmpty ? "None" : names.joined(separator: ", "),
                               action: { pickerSheet = .accessories(category) }) {
                        RowValue(text: "", chevron: true)
                    }
                    RowDivider()
                }

                // Always show total power draw
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
                SettingRow("Total power draw",
                           value: String(format: "%.1f W", totalPower),
                           mono: true,
                           valueColor: Theme.Colors.textPrimary)
            }
        }
    }

    // 3 · Name
    private var editorNameSection: some View {
        VStack(spacing: 0) {
            ThemedSectionHeader(title: "3 · Name")
            GroupedCard {
                SettingRow("Setup name") {
                    TextField("e.g. FX6 Doc", text: $newSetupName)
                        .multilineTextAlignment(.trailing)
                        .font(Theme.Fonts.body)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .submitLabel(.done)
                }
            }
        }
    }

    // MARK: Editor picker sheets

    @ViewBuilder
    private func pickerSheetContent(_ sheet: KitPickerSheet) -> some View {
        switch sheet {
        case .camera:
            if brandSheetShowsModels {
                SheetScaffold(title: "Model", onDone: { pickerSheet = nil }) {
                    SelectionList(
                        options: sortedModelIndices.map {
                            PickerOption(id: $0,
                                         title: cameras[selectedBrand].models[$0].name,
                                         subtitle: String(format: "%.1f W", cameras[selectedBrand].models[$0].powerDraw))
                        },
                        selectedID: selectedModel
                    ) { id in
                        settings.selectedModel = id
                        pickerSheet = nil
                    }
                }
            } else {
                SheetScaffold(title: "Brand", onDone: { pickerSheet = nil }) {
                    SelectionList(
                        options: sortedBrandIndices.map { index in
                            let count = cameras[index].models.count
                            return PickerOption(id: index, title: cameras[index].name,
                                                subtitle: count == 1 ? "1 model" : "\(count) models")
                        },
                        selectedID: selectedBrand
                    ) { id in
                        settings.selectedBrand = id
                        withAnimation(.snappy) { brandSheetShowsModels = true }
                    }
                }
            }

        case .accessories(let category):
            SheetScaffold(title: category.rawValue, onDone: { pickerSheet = nil }) {
                MultiSelectList(
                    options: accessories.indices
                        .filter { accessories[$0].category == category }
                        .sorted { accessories[$0].name.localizedCaseInsensitiveCompare(accessories[$1].name) == .orderedAscending }
                        .map { PickerOption(id: $0, title: accessories[$0].name,
                                            subtitle: String(format: "%.1f W", accessories[$0].powerDraw)) },
                    isSelected: { settings.selectedAccessories.contains($0) },
                    onToggle: { index in
                        // Same toggle logic as the old ModernAccessoryToggle action
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
                ) { index in
                    // Quantity selector for focus systems / audio
                    if accessories[index].category.supportsQuantity && settings.selectedAccessories.contains(index) {
                        HStack {
                            Text("Quantity")
                                .font(Theme.Fonts.subLabel)
                                .foregroundStyle(Theme.Colors.textTertiary)
                            Spacer()
                            StepperPill(
                                value: settings.focusSystemQuantities[index] ?? 1,
                                canDecrement: (settings.focusSystemQuantities[index] ?? 1) > 1,
                                canIncrement: (settings.focusSystemQuantities[index] ?? 1) < 99,
                                onDecrement: {
                                    if let current = settings.focusSystemQuantities[index], current > 1 {
                                        settings.focusSystemQuantities[index] = current - 1
                                        settings.saveSettings()
                                    }
                                },
                                onIncrement: {
                                    let current = settings.focusSystemQuantities[index] ?? 1
                                    if current < 99 {
                                        settings.focusSystemQuantities[index] = current + 1
                                        settings.saveSettings()
                                    }
                                },
                                diameter: 34
                            )
                        }
                        .padding(.horizontal, Theme.Spacing.rowPadding)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
    }

    // MARK: Toast

    private func flashSavedToast() {
        withAnimation(.snappy) { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + Theme.Motion.toastSeconds) {
            withAnimation(.snappy) { showSavedToast = false }
        }
    }
}

// MARK: - Sheet identifiers

enum KitEditorSheet: String, Identifiable {
    case editor
    var id: String { rawValue }
}

enum KitPickerSheet: Identifiable, Equatable {
    case camera
    case accessories(AccessoryCategory)

    var id: String {
        switch self {
        case .camera: return "camera"
        case .accessories(let category): return "accessories-\(category.rawValue)"
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
