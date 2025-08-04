//
//  PlannerBooApp.swift
//  PlannerBoo
//
//  Created by Evangelos Meklis on 4/8/25.
//

import SwiftUI

@main
struct PlannerBooApp: App {
    @StateObject private var permissionsManager = PermissionsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(permissionsManager)
                .preferredColorScheme(.light)
        }
        .windowResizability(.contentSize)
    }
}
