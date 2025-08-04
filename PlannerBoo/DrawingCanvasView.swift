import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var selectedTool: PKInkingTool
    @Binding var showEraser: Bool
    @Binding var eraserSize: CGFloat
    @Binding var toolMode: ToolMode
    let date: Date
    
    func makeUIView(context: Context) -> PKCanvasView {
        // Configure for both pencil and finger input
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = UIColor.clear
        canvasView.isOpaque = false
        canvasView.delegate = context.coordinator
        
        // Allow both finger and pencil drawing
        canvasView.allowsFingerDrawing = true
        canvasView.isMultipleTouchEnabled = true
        
        // Set initial tool
        canvasView.tool = selectedTool
        
        // Load existing drawing for this date if available
        loadDrawing()
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Enable/disable drawing based on tool mode
        uiView.isUserInteractionEnabled = (toolMode == .pen || toolMode == .eraser)
        
        // Update tool when selection changes
        if showEraser {
            uiView.tool = PKEraserTool(.bitmap, width: eraserSize)
        } else {
            uiView.tool = selectedTool
        }
        
        // Handle date changes through coordinator to avoid state modification during view update
        context.coordinator.updateForDateChange()
    }
    
    func loadDrawing() {
        // Load saved drawing for this specific date
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let drawingURL = documentsPath.appendingPathComponent("drawing_\(dateKey).drawing")
        
        // Use background queue for file I/O to prevent main thread blocking
        DispatchQueue.global(qos: .userInitiated).async {
            if let drawingData = try? Data(contentsOf: drawingURL),
               let drawing = try? PKDrawing(data: drawingData) {
                DispatchQueue.main.async {
                    self.canvasView.drawing = drawing
                }
            } else {
                DispatchQueue.main.async {
                    // Clear the canvas if no drawing exists for this date
                    self.canvasView.drawing = PKDrawing()
                }
            }
        }
    }
    
    func saveDrawing() {
        saveDrawingForDate(date)
    }
    
    func saveDrawingForDate(_ saveDate: Date) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: saveDate)
        let drawingURL = documentsPath.appendingPathComponent("drawing_\(dateKey).drawing")
        
        let drawingData = canvasView.drawing.dataRepresentation()
        
        // Use background queue for file I/O to prevent main thread blocking
        DispatchQueue.global(qos: .utility).async {
            try? drawingData.write(to: drawingURL)
        }
    }
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: DrawingCanvasView
        private var lastLoadedDate: Date?
        private var saveTimer: Timer?
        
        init(_ parent: DrawingCanvasView) {
            self.parent = parent
            super.init()
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Throttle save operations to prevent excessive I/O
            saveTimer?.invalidate()
            saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.parent.saveDrawing()
            }
        }
        
        func updateForDateChange() {
            if lastLoadedDate != parent.date {
                // Save current drawing before switching
                saveTimer?.invalidate()
                if let oldDate = lastLoadedDate {
                    parent.saveDrawingForDate(oldDate)
                }
                
                lastLoadedDate = parent.date
                parent.loadDrawing()
            }
        }
    }
}

#Preview {
    @Previewable @State var canvasView = PKCanvasView()
    @Previewable @State var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    @Previewable @State var showEraser = false
    @Previewable @State var eraserSize: CGFloat = 20
    @Previewable @State var toolMode: ToolMode = .pen
    
    DrawingCanvasView(
        canvasView: $canvasView,
        selectedTool: $selectedTool,
        showEraser: $showEraser,
        eraserSize: $eraserSize,
        toolMode: $toolMode,
        date: Date()
    )
}