import SwiftUI

// Restyle v4: Support.
// Same links and mailto subjects as before; laid out as a "Missing your kit?" card,
// contact rows, an About card and the version footer.

struct SupportPageView: View {
    @Environment(\.dismiss) private var dismiss

    /// Show "‹ Tools" when pushed (hidden when used as a tab)
    var showsBackButton: Bool = true

    init(showsBackButton: Bool = true) {
        self.showsBackButton = showsBackButton
    }

    private func open(_ string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

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

                ScreenTitle(text: "Support", eyebrow: "We read everything", size: 34)
                    .padding(.top, showsBackButton ? 4 : 20)

                VStack(spacing: 0) {
                    // Request Equipment
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Missing your kit?")
                            .displayTitle(22)
                        Text("Tell us the camera, codec or accessory and we'll add it in a future update.")
                            .font(Theme.Fonts.archivo(16))
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        PrimaryButton("Request an addition") {
                            open("mailto:app@stevepmann.com?subject=CineTools%20Equipment%20Request")
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.Colors.card,
                                in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous))
                    .padding(.top, 20)

                    // Contact
                    ThemedSectionHeader(title: "Contact")
                    GroupedCard {
                        SettingRow("Get in touch", subLabel: "Questions or feedback",
                                   value: "app@stevepmann.com", chevron: true) {
                            open("mailto:app@stevepmann.com?subject=CineTools%20Feedback")
                        }
                        RowDivider()
                        SettingRow("Instagram", subLabel: "Updates and new kit",
                                   value: "@cinetools.app", chevron: true) {
                            open("https://www.instagram.com/cinetools.app")
                        }
                        RowDivider()
                        SettingRow("Rate the app", subLabel: "Leave a review",
                                   value: "App Store", chevron: true) {
                            open("https://apps.apple.com/app/id6742568544?action=write-review")
                        }
                    }

                    // About
                    ThemedSectionHeader(title: "About")
                    GroupedCard {
                        Text("CineTools was developed by Steve Mann, a working DP and location sound mixer from the South Coast of the UK. The app was designed to streamline calculations when prepping for shoots, and also on set. Made by the video community for the video community!")
                            .font(Theme.Fonts.archivo(15))
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(Theme.Spacing.rowPadding)
                        RowDivider()
                        SettingRow("Website", value: "stevepmann.com", chevron: true) {
                            open("https://www.stevepmann.com")
                        }
                        RowDivider()
                        SettingRow("Instagram", value: "@stevepmann", chevron: true) {
                            open("https://www.instagram.com/stevepmann")
                        }
                    }

                    // Footer
                    VStack(spacing: 4) {
                        Text(appVersion.isEmpty ? "CineTools" : "CineTools \(appVersion)")
                        Text("Made by Steve Mann, a working DP and location sound mixer")
                    }
                    .font(Theme.Fonts.archivo(13))
                    .foregroundStyle(Theme.Colors.textQuaternary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                }
                .padding(.horizontal, Theme.Spacing.cardMargin)
                .padding(.bottom, 120)
            }
        }
        .scrollIndicators(.hidden)
        .themedScreen()
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
