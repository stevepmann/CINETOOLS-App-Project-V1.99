//
//  New_Camera_Tools_AppApp.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//

import SwiftUI

@main
struct New_Camera_Tools_AppApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView() // Restyle v4: Tools / Kit Bag / Support tabs
                .preferredColorScheme(.dark) // Restyle v4: dark is the target
        }
    }
}
