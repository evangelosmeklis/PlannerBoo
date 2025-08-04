import SwiftUI

struct PermissionsOnboardingView: View {
    @ObservedObject var permissionsManager: PermissionsManager
    @Binding var showOnboarding: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                Text("Welcome to PlannerBoo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("To get the most out of your planner, we need a few permissions")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    PermissionRow(
                        icon: "photo.on.rectangle",
                        title: "Photos",
                        description: "Add images to your planner pages",
                        isGranted: permissionsManager.photosAccess,
                        color: .green
                    )
                    
                    PermissionRow(
                        icon: "calendar",
                        title: "Calendar",
                        description: "Create and sync events with your calendar",
                        isGranted: permissionsManager.calendarAccess,
                        color: .blue
                    )
                    
                    PermissionRow(
                        icon: "list.bullet",
                        title: "Reminders",
                        description: "Create and manage reminders",
                        isGranted: permissionsManager.remindersAccess,
                        color: .orange
                    )
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button("Grant All Permissions") {
                        permissionsManager.requestAllPermissions()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("Continue Without Permissions") {
                        showOnboarding = false
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
            .frame(maxWidth: min(600, geometry.size.width * 0.8))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .background(Color(.systemBackground))
            .overlay(
                HStack {
                    Spacer()
                    VStack {
                        Button("Skip") {
                            showOnboarding = false
                        }
                        .padding()
                        Spacer()
                    }
                }
            )
        }
        .onChange(of: permissionsManager.photosAccess) { 
            checkAllPermissions()
        }
        .onChange(of: permissionsManager.calendarAccess) {
            checkAllPermissions()
        }
        .onChange(of: permissionsManager.remindersAccess) {
            checkAllPermissions()
        }
    }
    
    private func checkAllPermissions() {
        // Auto-dismiss if user has granted all permissions
        if permissionsManager.photosAccess && 
           permissionsManager.calendarAccess && 
           permissionsManager.remindersAccess {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showOnboarding = false
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            } else {
                Circle()
                    .stroke(Color.secondary, lineWidth: 2)
                    .frame(width: 24, height: 24)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    @Previewable @State var showOnboarding = true
    
    PermissionsOnboardingView(
        permissionsManager: PermissionsManager(),
        showOnboarding: $showOnboarding
    )
}