import SwiftUI
import PencilKit

struct DrawingToolbar: View {
    @Binding var selectedTool: PKInkingTool
    @Binding var showEraser: Bool
    @Binding var eraserSize: CGFloat
    @State private var selectedColor: Color = .black
    @State private var selectedThickness: CGFloat = 5
    @State private var showColorPicker = false
    
    private let availableColors: [Color] = [
        .black, .blue, .red, .green, .orange, .purple, .brown, .pink
    ]
    
    private let thicknessOptions: [CGFloat] = [2, 5, 10] // Thin, Medium, Thick
    private let eraserSizes: [CGFloat] = [10, 20, 40] // Small, Medium, Large
    
    var body: some View {
        VStack(spacing: 8) {
            // Main toolbar row
            HStack(spacing: 16) {
                // Pen tool
                Button(action: {
                    showEraser = false
                    updateTool()
                }) {
                    Image(systemName: "pencil")
                        .font(.title2)
                        .foregroundColor(showEraser ? .gray : .black)
                        .padding(10)
                        .background(showEraser ? Color.clear : Color.black.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Eraser tool
                Button(action: {
                    showEraser = true
                }) {
                    Image(systemName: "eraser")
                        .font(.title2)
                        .foregroundColor(showEraser ? .black : .gray)
                        .padding(10)
                        .background(showEraser ? Color.black.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                }
                
                Divider()
                    .frame(height: 30)
                
                // Color picker button
                Button(action: {
                    showColorPicker.toggle()
                }) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        Text("Color")
                            .font(.caption)
                            .foregroundColor(.black)
                        Image(systemName: showColorPicker ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                }
                
                Divider()
                    .frame(height: 30)
                
                // Size selector (for both pen and eraser)
                HStack(spacing: 12) {
                    Text(showEraser ? "Eraser Size:" : "Pen Size:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        if showEraser {
                            ForEach(Array(eraserSizes.enumerated()), id: \.offset) { index, size in
                                Button(action: {
                                    eraserSize = size
                                }) {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: min(size/2 + 8, 20), height: min(size/2 + 8, 20))
                                        .overlay(
                                            Circle()
                                                .stroke(eraserSize == size ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        } else {
                            ForEach(Array(thicknessOptions.enumerated()), id: \.offset) { index, thickness in
                                Button(action: {
                                    selectedThickness = thickness
                                    updateTool()
                                }) {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: max(thickness + 8, 16), height: max(thickness + 8, 16))
                                        .overlay(
                                            Circle()
                                                .stroke(selectedThickness == thickness ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Color palette (shows/hides)
            if showColorPicker {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(availableColors, id: \.self) { color in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedColor = color
                                showEraser = false
                                updateTool()
                                showColorPicker = false
                            }
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            updateTool()
        }
    }
    
    private func updateTool() {
        if !showEraser {
            let uiColor = UIColor(selectedColor)
            selectedTool = PKInkingTool(.pen, color: uiColor, width: selectedThickness)
        }
    }
}

#Preview {
    @Previewable @State var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    @Previewable @State var showEraser = false
    @Previewable @State var eraserSize: CGFloat = 20
    
    return DrawingToolbar(
        selectedTool: $selectedTool,
        showEraser: $showEraser,
        eraserSize: $eraserSize
    )
    .padding()
}