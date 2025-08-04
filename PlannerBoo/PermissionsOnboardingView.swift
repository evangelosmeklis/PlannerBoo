import SwiftUI

struct PermissionsOnboardingView: View {
    @ObservedObject var permissionsManager: PermissionsManager
    @Binding var showOnboarding: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Welcome to PlannerBoo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your digital planner needs access to these features to provide the best experience")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 20) {
                    PermissionRow(
                        icon: "photo.on.rectangle",
                        title: "Photos",
                        description: "Add photos to your planner pages",
                        isGranted: permissionsManager.photosAccess,
                        color: .green
                    )
                    
                    // Temporarily disabled permissions - coming soon
                    VStack(spacing: 12) {
                        Text("Coming Soon")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                Text("Calendar Integration")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.secondary)
                                Text("Reminders Integration")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.secondary)
                                Text("Health & Fitness Data")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button("Grant Photos Access") {
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
        .onChange(of: permissionsManager.photosAccess) { checkAllPermissions() }
    }
    
    private func checkAllPermissions() {
        // Auto-dismiss if user has granted Photos permission
        if permissionsManager.photosAccess {
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
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
                    .font(.title2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    @Previewable @State var showOnboarding = true
    return PermissionsOnboardingView(
        permissionsManager: PermissionsManager(),
        showOnboarding: $showOnboarding
    )
}