import SwiftUI

struct UserSettingsView: View {
    @State private var isShowingNewSetupSheet = false
    @State private var newSetupName = ""
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    ModernCard {
                        VStack(spacing: 12) {
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
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    // Existing content...
                }
            }
            // Existing floating back button...
        }
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