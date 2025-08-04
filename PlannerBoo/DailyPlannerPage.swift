import SwiftUI
import PencilKit

struct DailyPlannerPage: View {
    let date: Date
    let onDateSelected: ((Date) -> Void)?
    @State private var canvasView = PKCanvasView()
    @State private var showingPhotoPicker = false
    @State private var showingEventCreator = false
    @State private var showingOverview = false
    @State private var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    @State private var showEraser = false
    @State private var showDrawingToolbar = true
    @State private var eraserSize: CGFloat = 40
    @State private var toolMode: ToolMode = .pen
    @EnvironmentObject var permissionsManager: PermissionsManager
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    private var dayNumberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Classic planner paper background
                Color(red: 0.98, green: 0.97, blue: 0.94) // Cream paper color
                
                VStack(spacing: 0) {
                    // Header section with classic planner styling
                    VStack(spacing: 8) {
                        // Month/Year at the top
                        Text(monthYearFormatter.string(from: date))
                            .font(.custom("Georgia", size: 18))
                            .foregroundColor(.black)
                            .tracking(1.2)
                        
                        // Day of week and date number
                        HStack(alignment: .top, spacing: 16) {
                            // Large day number
                            Text(dayNumberFormatter.string(from: date))
                                .font(.custom("Georgia", size: 72))
                                .fontWeight(.light)
                                .foregroundColor(.black)
                                .frame(width: 100, height: 100)
                                .background(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Day of week
                                Text(dateFormatter.string(from: date))
                                    .font(.custom("Georgia", size: 24))
                                    .foregroundColor(.black)
                                    .tracking(0.8)
                                
                                // Action buttons in classic style
                                HStack(spacing: 12) {
                                    Button(action: { showingPhotoPicker = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "photo")
                                                .font(.caption)
                                            Text("Photos")
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.05))
                                        .cornerRadius(4)
                                    }
                                    .foregroundColor(.black)
                                    
                                    Button(action: { showingEventCreator = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "calendar")
                                                .font(.caption)
                                            Text("Events")
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.05))
                                        .cornerRadius(4)
                                    }
                                    .foregroundColor(.black)
                                    
                                    Button(action: { showingOverview = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "calendar.badge.clock")
                                                .font(.caption)
                                            Text("Overview")
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.05))
                                        .cornerRadius(4)
                                    }
                                    .foregroundColor(.black)
                                    
                                    Button(action: { showDrawingToolbar.toggle() }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: showDrawingToolbar ? "paintbrush.fill" : "paintbrush")
                                                .font(.caption)
                                            Text("Tools")
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.05))
                                        .cornerRadius(4)
                                    }
                                    .foregroundColor(.black)
                                }
                                .padding(.top, 8)
                                
                                // Unified toolbar positioned right below action buttons
                                if showDrawingToolbar {
                                    UnifiedToolbar(
                                        selectedTool: $selectedTool,
                                        showEraser: $showEraser,
                                        eraserSize: $eraserSize,
                                        toolMode: $toolMode
                                    )
                                    .padding(.top, 12)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        
                        // Decorative line under header
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 1)
                            .padding(.horizontal, 32)
                    }
                    .background(Color(red: 0.96, green: 0.95, blue: 0.92))
                    
                    // Main content area with lined paper effect
                    ZStack {
                        // Lined paper background that extends to full height
                        LinedPaperBackground(geometry: geometry)
                        
                        ScrollView {
                            VStack(spacing: 24) {
                                // Main writing/drawing area with overlays
                                ZStack {
                                    // Drawing canvas (bottom layer) - with edge exclusion
                                    DrawingCanvasView(
                                        canvasView: $canvasView,
                                        selectedTool: $selectedTool,
                                        showEraser: $showEraser,
                                        eraserSize: $eraserSize,
                                        toolMode: $toolMode,
                                        date: date
                                    )
                                    .frame(height: max(800, geometry.size.height - 200))
                                    .background(Color.clear)
                                    .padding(.horizontal, 60) // Exclude 60pt edges from drawing
                                    
                                    // Photo overlay (middle layer)
                                    DraggablePhotoOverlay(date: date)
                                        .frame(height: max(800, geometry.size.height - 200))
                                    
                                    // Text input overlay (top layer) - responds to tool mode
                                    TextInputOverlay(date: date, toolMode: $toolMode)
                                        .frame(height: max(800, geometry.size.height - 200))
                                        .padding(.horizontal, 60) // Exclude 60pt edges from text input
                                }
                                .padding(.horizontal, 32)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerView(date: date)
        }
        .sheet(isPresented: $showingEventCreator) {
            EventCreatorView(date: date)
        }
        .sheet(isPresented: $showingOverview) {
            OverviewView(onDateSelected: { selectedDate in
                // Navigate to the selected date and dismiss the sheet
                onDateSelected?(selectedDate)
                showingOverview = false
            })
        }
    }
}

struct LinedPaperBackground: View {
    let geometry: GeometryProxy
    
    var body: some View {
        Canvas { context, size in
            let lineSpacing: CGFloat = 32 // Spacing between lines
            let leftMargin: CGFloat = 80 // Left margin for red line
            let lineColor = Color.black.opacity(0.15)
            let marginLineColor = Color.red.opacity(0.3)
            
            // Draw horizontal lines across the entire height
            var y: CGFloat = 60 // Start below header
            let totalHeight = max(size.height, geometry.size.height)
            
            while y < totalHeight {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 32, y: y))
                        path.addLine(to: CGPoint(x: size.width - 32, y: y))
                    },
                    with: .color(lineColor),
                    lineWidth: 0.5
                )
                y += lineSpacing
            }
            
            // Draw left margin line (red line) - extend to full height
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: leftMargin, y: 0))
                    path.addLine(to: CGPoint(x: leftMargin, y: totalHeight))
                },
                with: .color(marginLineColor),
                lineWidth: 1
            )
            
            // Draw three holes for binder
            let holeRadius: CGFloat = 4
            let holeColor = Color.black.opacity(0.1)
            let holeX: CGFloat = 20
            
            // Position holes based on visible area
            let holePositions = [
                120.0,
                max(300, totalHeight / 2),
                max(500, totalHeight - 120)
            ]
            
            for holeY in holePositions {
                if holeY < totalHeight {
                    context.fill(
                        Path { path in
                            path.addEllipse(in: CGRect(
                                x: holeX - holeRadius,
                                y: holeY - holeRadius,
                                width: holeRadius * 2,
                                height: holeRadius * 2
                            ))
                        },
                        with: .color(holeColor)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DailyPlannerPage(date: Date(), onDateSelected: nil)
        .environmentObject(PermissionsManager())
}