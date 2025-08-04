//
//  ContentView.swift
//  PlannerBoo
//
//  Created by Evangelos Meklis on 4/8/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var permissionsManager: PermissionsManager
    @State private var showOnboarding = true
    
    var body: some View {
        Group {
            if showOnboarding {
                PermissionsOnboardingView(
                    permissionsManager: permissionsManager,
                    showOnboarding: $showOnboarding
                )
            } else {
                PlannerPageView()
            }
        }
        .onAppear {
            // Check permissions when view appears
            permissionsManager.checkPermissions()
            
            // Small delay to let permissions check complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if permissionsManager.photosAccess {
                    showOnboarding = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PermissionsManager())
}
