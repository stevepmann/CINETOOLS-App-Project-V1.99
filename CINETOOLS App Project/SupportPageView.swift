import SwiftUI

struct SupportPageView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 80)
                    
                    Text("Support")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                    
                    // Main Support Cards Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        // Request Equipment Card
                        ModernCard {
                            Button {
                                if let url = URL(string: "mailto:app@stevepmann.com?subject=CineTools%20Equipment%20Request") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.app")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.gray)
                                    
                                    Text("Request Addition")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Add missing gear")
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
                        
                        // Get in Touch Card
                        ModernCard {
                            Button {
                                if let url = URL(string: "mailto:app@stevepmann.com?subject=CineTools%20Feedback") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.gray)
                                    
                                    Text("Get in Touch")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Questions or feedback")
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
                        
                        // Rate App Card
                        ModernCard {
                            Button {
                                if let url = URL(string: "https://apps.apple.com/us/app/go-game-connect/id6742568544") { // Add actual App Store ID
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.gray)
                                    
                                    Text("Rate the App")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Leave a review")
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
                        
                        // Instagram Card
                        ModernCard {
                            Button {
                                if let url = URL(string: "https://www.instagram.com/cinetools.app") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.gray)
                                    
                                    Text("Follow Us")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Follow us on Instagram for updates")
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
                    
                    // About Section
                    ModernCard {
                        VStack(spacing: 16) {
                            Label {
                                Text("About")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            } icon: {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            Text("CineTools was developed by Steve Mann, a working DP from the South Coast of the UK. The app was designed to streamline calculations when prepping for shoots, and also on set. Made by the video community for the video community!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 24) {
                                Spacer()
                                Link(destination: URL(string: "https://www.stevepmann.com")!) {
                                    Label("Website", systemImage: "globe")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                Link(destination: URL(string: "https://www.instagram.com/stevepmann")!) {
                                    Label("Instagram", systemImage: "camera.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                        }
                        .padding(16)
                    }
                    .padding(.horizontal)
                    
                    // Logo
                    VStack(spacing: 1) {
                        Image("-headerlogo-")
                            .resizable()
                            .frame(width: 300, height: 100)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            
            // Floating Back Button
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
                .padding(.top, 60)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarHidden(true)
    }
}

// Helper extension for Instagram gradient colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SupportPageView()
} 
