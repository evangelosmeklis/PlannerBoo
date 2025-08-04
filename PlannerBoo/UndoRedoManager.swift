import SwiftUI
import PencilKit

@MainActor
class UndoRedoManager: ObservableObject {
    @Published var canUndo = false
    @Published var canRedo = false
    
    private var undoManager: UndoManager?
    
    func setUndoManager(_ undoManager: UndoManager?) {
        self.undoManager = undoManager
        updateUndoRedoState()
    }
    
    func undo() {
        undoManager?.undo()
        updateUndoRedoState()
    }
    
    func redo() {
        undoManager?.redo()
        updateUndoRedoState()
    }
    
    func updateUndoRedoState() {
        canUndo = undoManager?.canUndo ?? false
        canRedo = undoManager?.canRedo ?? false
    }
    
    // Register drawing action for undo/redo
    func registerDrawingAction(oldDrawing: PKDrawing, newDrawing: PKDrawing, canvasView: PKCanvasView) {
        undoManager?.registerUndo(withTarget: self) { [weak self] _ in
            canvasView.drawing = oldDrawing
            self?.registerDrawingAction(oldDrawing: newDrawing, newDrawing: oldDrawing, canvasView: canvasView)
            self?.updateUndoRedoState()
        }
        updateUndoRedoState()
    }
    
    // Register text action for undo/redo
    func registerTextAction<T>(
        target: T,
        oldValue: Any,
        newValue: Any,
        keyPath: ReferenceWritableKeyPath<T, Any>,
        actionName: String
    ) where T: AnyObject {
        undoManager?.registerUndo(withTarget: target) { targetObject in
            targetObject[keyPath: keyPath] = oldValue
            self.registerTextAction(
                target: targetObject,
                oldValue: newValue,
                newValue: oldValue,
                keyPath: keyPath,
                actionName: actionName
            )
            self.updateUndoRedoState()
        }
        undoManager?.setActionName(actionName)
        updateUndoRedoState()
    }
}