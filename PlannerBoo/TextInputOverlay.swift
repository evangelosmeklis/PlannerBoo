import SwiftUI

struct TextInputOverlay: View {
    @State private var textBoxes: [TextBox] = []
    @State private var showingTextInput = false
    @State private var newText = ""
    @State private var selectedBox: UUID?
    
    let date: Date
    
    var body: some View {
        ZStack {
            // Existing text boxes
            ForEach(textBoxes) { textBox in
                DraggableTextBox(
                    textBox: textBox,
                    isSelected: selectedBox == textBox.id,
                    onTap: { selectedBox = textBox.id },
                    onMove: { newPosition in
                        updateTextBoxPosition(id: textBox.id, position: newPosition)
                    },
                    onDelete: {
                        deleteTextBox(id: textBox.id)
                    }
                )
            }
        }
        .onTapGesture(count: 2) { location in
            // Double tap to add text
            addTextBox(at: location)
        }
        .onAppear {
            loadTextBoxes()
        }
        .alert("Add Text", isPresented: $showingTextInput) {
            TextField("Enter text", text: $newText)
            Button("Add") {
                if !newText.isEmpty {
                    createTextBox()
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func addTextBox(at location: CGPoint) {
        showingTextInput = true
    }
    
    private func createTextBox() {
        let newBox = TextBox(
            text: newText,
            position: CGPoint(x: 100, y: 200), // Default position
            fontSize: 16
        )
        textBoxes.append(newBox)
        newText = ""
        saveTextBoxes()
    }
    
    private func updateTextBoxPosition(id: UUID, position: CGPoint) {
        if let index = textBoxes.firstIndex(where: { $0.id == id }) {
            textBoxes[index].position = position
            saveTextBoxes()
        }
    }
    
    private func deleteTextBox(id: UUID) {
        textBoxes.removeAll { $0.id == id }
        selectedBox = nil
        saveTextBoxes()
    }
    
    private func saveTextBoxes() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let textURL = documentsPath.appendingPathComponent("text_\(dateKey).json")
        
        if let data = try? JSONEncoder().encode(textBoxes) {
            try? data.write(to: textURL)
        }
    }
    
    private func loadTextBoxes() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let textURL = documentsPath.appendingPathComponent("text_\(dateKey).json")
        
        if let data = try? Data(contentsOf: textURL),
           let boxes = try? JSONDecoder().decode([TextBox].self, from: data) {
            textBoxes = boxes
        }
    }
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct TextBox: Identifiable, Codable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var fontSize: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case text, position, fontSize
    }
    
    init(text: String, position: CGPoint, fontSize: CGFloat) {
        self.text = text
        self.position = position
        self.fontSize = fontSize
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        
        // Decode CGPoint manually
        let positionContainer = try container.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
        let x = try positionContainer.decode(CGFloat.self, forKey: .x)
        let y = try positionContainer.decode(CGFloat.self, forKey: .y)
        position = CGPoint(x: x, y: y)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(fontSize, forKey: .fontSize)
        
        // Encode CGPoint manually
        var positionContainer = container.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
        try positionContainer.encode(position.x, forKey: .x)
        try positionContainer.encode(position.y, forKey: .y)
    }
    
    private enum PositionKeys: String, CodingKey {
        case x, y
    }
}

struct DraggableTextBox: View {
    let textBox: TextBox
    let isSelected: Bool
    let onTap: () -> Void
    let onMove: (CGPoint) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Text(textBox.text)
            .font(.custom("Georgia", size: textBox.fontSize))
            .foregroundColor(.black)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.8))
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
            .position(textBox.position)
            .onTapGesture {
                onTap()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        onMove(value.location)
                    }
            )
            .contextMenu {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
    }
}

#Preview {
    TextInputOverlay(date: Date())
        .frame(width: 400, height: 600)
        .background(Color.gray.opacity(0.1))
}