//
//  HomePageView.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 1) {
                            Image("header")
                                .resizable()
                            .frame(width: 300, height: 100)
                        
                        }
                        .padding(.top, 20)
                        
                        // Tools Grid
                        VStack(spacing: 16) {
                            // Battery Calculator
                            
                            NavigationLink(destination: ContentView()) {
                                ModernCard {
                                    HStack(spacing: 16) {
                                        Image(systemName: "battery.100.bolt")
                                            .font(.system(size: 28))
                                            .foregroundStyle(.green)
                                            .frame(width: 40)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Battery Calculator")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text("Calculate runtime for your\ncamera build")
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                    }
                                    .padding(.vertical, 5)
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            
                            // Data Calculator
                            NavigationLink(destination: DataCalculatorView()) {
                                ModernCard {
                                    HStack(spacing: 10) {
                                        Image(systemName: "internaldrive.fill")
                                            .font(.system(size: 28))
                                            .foregroundStyle(.blue)
                                            .frame(width: 40)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Data Calculator")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text("Calculate data requirements depending on codec and resolution")
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineSpacing(2)
                                        }
                                        .padding(.vertical, 5)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                    .frame(minHeight: 70)
                                }
                            }
                            
                            // Data Transfer Calculator
                            NavigationLink(destination: DataTransferView()) {
                                ModernCard {
                                    HStack(spacing: 10) {
                                        Image(systemName: "cable.connector.horizontal")
                                            .font(.system(size: 28))
                                            .foregroundStyle(.blue)
                                            .frame(width: 40)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Transfer Calculator")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text("Calculate data transfer times between devices")
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineSpacing(2)
                                        }
                                        .padding(.vertical, 5)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                    .frame(minHeight: 70)
                                    
                                }
                                
                            }
                            
                            
                        }
                        .padding(.horizontal)
                        
                        // After the main tools grid and before any footer content
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            // User Settings Card
                            NavigationLink(destination: UserSettingsView()) {
                                ModernCard {
                                    VStack(spacing: 8) {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 32))
                                            .foregroundStyle(.gray)
                                        
                                        Text("Your Kit Bag")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Save your setup")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .padding(.vertical, 8)
                                }
                            }
                            
                            // Support Card
                            NavigationLink(destination: SupportPageView()) {
                                ModernCard {
                                    VStack(spacing: 8) {
                                        Image(systemName: "envelope.badge")
                                            .font(.system(size: 32))
                                            .foregroundStyle(.gray)
                                        
                                        Text("Support")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Get in touch")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        .padding(.bottom, 20)
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

// Preview
#Preview {
    HomePageView()
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .environmentObject(UserSettings())
    }
}
