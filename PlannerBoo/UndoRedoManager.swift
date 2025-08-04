import SwiftUI
import PencilKit

@MainActor
class UndoRedoManager: ObservableObject {
    @Published var canUndo = false
    @Published var canRedo = false
    
    private weak var canvasView: PKCanvasView?
    
    func setCanvasView(_ canvasView: PKCanvasView) {
        self.canvasView = canvasView
        updateUndoRedoState()
    }
    
    func undo() {
        canvasView?.undoManager?.undo()
        updateUndoRedoState()
    }
    
    func redo() {
        canvasView?.undoManager?.redo()
        updateUndoRedoState()
    }
    
    func updateUndoRedoState() {
        canUndo = canvasView?.undoManager?.canUndo ?? false
        canRedo = canvasView?.undoManager?.canRedo ?? false
    }
}