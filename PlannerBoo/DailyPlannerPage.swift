import SwiftUI
import PencilKit

struct DailyPlannerPage: View {
    let date: Date
    @State private var canvasView = PKCanvasView()
    @State private var showingPhotoPicker = false
    @State private var showingEventCreator = false
    @EnvironmentObject var permissionsManager: PermissionsManager
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }
    
    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with date
                HStack {
                    Text(dateFormatter.string(from: date))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: { showingPhotoPicker = true }) {
                            Image(systemName: "photo.badge.plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: { showingEventCreator = true }) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                
                // Main content area with drawing canvas and health data
                ScrollView {
                    VStack(spacing: 16) {
                        // Health & Fitness Section
                        if permissionsManager.healthAccess {
                            HealthDataView(date: date)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 8) {
                                Text("Health & Fitness Data")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Grant health permissions to see your daily activity")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Grant Health Access") {
                                    Task {
                                        await permissionsManager.requestHealthAccess()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Drawing/Writing Canvas
                        DrawingCanvasView(canvasView: $canvasView, date: date)
                            .frame(height: 600)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .background(Color.white)
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerView(date: date)
        }
        .sheet(isPresented: $showingEventCreator) {
            EventCreatorView(date: date)
        }
    }
}

#Preview {
    DailyPlannerPage(date: Date())
}