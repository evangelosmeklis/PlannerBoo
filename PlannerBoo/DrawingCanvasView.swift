import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let date: Date
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .pencilOnly // Only Apple Pencil, not finger
        canvasView.backgroundColor = UIColor.clear // Make transparent to show lined paper
        canvasView.isOpaque = false
        
        // Load existing drawing for this date if available
        loadDrawing()
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update the canvas if needed
    }
    
    private func loadDrawing() {
        // Load saved drawing for this specific date
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let drawingURL = documentsPath.appendingPathComponent("drawing_\(dateKey).drawing")
        
        if let drawingData = try? Data(contentsOf: drawingURL),
           let drawing = try? PKDrawing(data: drawingData) {
            canvasView.drawing = drawing
        }
    }
    
    private func saveDrawing() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
    return DrawingCanvasView(canvasView: $canvasView, date: Date())
}