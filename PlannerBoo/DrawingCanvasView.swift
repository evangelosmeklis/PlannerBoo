import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var selectedTool: PKInkingTool
    @Binding var showEraser: Bool
    @Binding var eraserSize: CGFloat
    let date: Date
    @State private var currentLoadedDate: Date?
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput // Allow both Apple Pencil and finger
        canvasView.backgroundColor = UIColor.clear // Make transparent to show lined paper
        canvasView.isOpaque = false
        
        // Set initial tool
        canvasView.tool = selectedTool
        
        // Load existing drawing for this date if available
        currentLoadedDate = date
        loadDrawing()
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update tool when selection changes
        if showEraser {
            uiView.tool = PKEraserTool(.bitmap, width: eraserSize)
        } else {
            uiView.tool = selectedTool
        }
        
        // Only reload drawing if the date has actually changed
        if currentLoadedDate != date {
            // Save current drawing before switching
            if let oldDate = currentLoadedDate {
                saveDrawingForDate(oldDate)
            }
            currentLoadedDate = date
            loadDrawing()
        }
    }
    
    private func loadDrawing() {
        // Load saved drawing for this specific date
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let drawingURL = documentsPath.appendingPathComponent("drawing_\(dateKey).drawing")
        
        if let drawingData = try? Data(contentsOf: drawingURL),
           let drawing = try? PKDrawing(data: drawingData) {
            canvasView.drawing = drawing
        } else {
            // Clear the canvas if no drawing exists for this date
            canvasView.drawing = PKDrawing()
        }
    }
    
    private func saveDrawing() {
        saveDrawingForDate(date)
    }
    
    private func saveDrawingForDate(_ saveDate: Date) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: saveDate)
        let drawingURL = documentsPath.appendingPathComponent("drawing_\(dateKey).drawing")
        
        let drawingData = canvasView.drawing.dataRepresentation()
        try? drawingData.write(to: drawingURL)
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
        
        init(_ parent: DrawingCanvasView) {
            self.parent = parent
            super.init()
            parent.canvasView.delegate = self
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.saveDrawing()
        }
    }
}

#Preview {
    @Previewable @State var canvasView = PKCanvasView()
    @Previewable @State var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    @Previewable @State var showEraser = false
    @Previewable @State var eraserSize: CGFloat = 20
    
    DrawingCanvasView(
        canvasView: $canvasView,
        selectedTool: $selectedTool,
        showEraser: $showEraser,
        eraserSize: $eraserSize,
        date: Date()
    )
}