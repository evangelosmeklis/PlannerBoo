import SwiftUI

struct UndoRedoButtons: View {
    @ObservedObject var undoRedoManager: UndoRedoManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Undo button
            Button(action: {
                undoRedoManager.undo()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.caption)
                    Text("Undo")
                        .font(.caption)
                }
                .foregroundColor(undoRedoManager.canUndo ? .blue : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .disabled(!undoRedoManager.canUndo)
            
            // Redo button
            Button(action: {
                undoRedoManager.redo()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.caption)
                    Text("Redo")
                        .font(.caption)
                }
                .foregroundColor(undoRedoManager.canRedo ? .blue : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .disabled(!undoRedoManager.canRedo)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    UndoRedoButtons(undoRedoManager: UndoRedoManager())
}