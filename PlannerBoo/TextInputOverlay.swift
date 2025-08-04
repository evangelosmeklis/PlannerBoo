import SwiftUI

struct TextInputOverlay: View {
    @State private var textBoxes: [TextBox] = []
    @State private var stickyNotes: [StickyNote] = []
    @State private var showingTextInput = false
    @State private var newText = ""
    @State private var selectedBox: UUID?
    @State private var selectedNote: UUID?
    @State private var pendingTextPosition: CGPoint = .zero
    @State private var showingInlineEditor = false
    @State private var inlineEditorPosition: CGPoint = .zero
    @State private var showingStickyNoteEditor = false
    @State private var stickyNotePosition: CGPoint = .zero
    @State private var newStickyText = ""
    @State private var selectedStickyColor: StickyNoteColor = .yellow
    @State private var showingTextResizer = false
    @State private var resizingTextId: UUID?
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isStickyNoteFocused: Bool
    
    let date: Date
    
    var body: some View {
        ZStack {
            // Invisible tap area for adding text
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(count: 2) { location in
                    // Double tap to add sticky note
                    startStickyNoteEditing(at: location)
                }
                .onTapGesture { location in
                    // Handle tap behavior based on current state
                    let tappedOnExistingBox = textBoxes.contains { textBox in
                        let boxFrame = CGRect(
                            x: textBox.position.x - 50,
                            y: textBox.position.y - 20,
                            width: 100,
                            height: 40
                        )
                        return boxFrame.contains(location)
                    }
                    
                    let tappedOnExistingStickyNote = stickyNotes.contains { note in
                        let noteFrame = CGRect(
                            x: note.position.x - 75,
                            y: note.position.y - 75,
                            width: 150,
                            height: 150
                        )
                        return noteFrame.contains(location)
                    }
                    
                    if showingInlineEditor {
                        // If currently editing, finish the current text and don't start new one
                        finishInlineEditing()
                    } else if !tappedOnExistingBox && !tappedOnExistingStickyNote {
                        // Only start new editing if not tapping on existing items
                        selectedBox = nil
                        selectedNote = nil
                        startInlineEditing(at: location)
                    } else {
                        // Clear selections if tapping elsewhere
                        selectedBox = nil
                        selectedNote = nil
                    }
                }
            
            // Existing text boxes
            ForEach(textBoxes) { textBox in
                DraggableTextBox(
                    textBox: textBox,
                    isSelected: selectedBox == textBox.id,
                    onTap: { 
                        selectedBox = textBox.id
                        selectedNote = nil
                    },
                    onMove: { newPosition in
                        updateTextBoxPosition(id: textBox.id, position: newPosition)
                    },
                    onDelete: {
                        deleteTextBox(id: textBox.id)
                    }
                )
            }
            
            // Sticky notes
            ForEach(stickyNotes) { note in
                DraggableStickyNote(
                    note: note,
                    isSelected: selectedNote == note.id,
                    onTap: {
                        selectedNote = note.id
                        selectedBox = nil
                    },
                    onMove: { newPosition in
                        updateStickyNotePosition(id: note.id, position: newPosition)
                    },
                    onDelete: {
                        deleteStickyNote(id: note.id)
                    }
                )
            }
            
            // Control buttons for selected text
            if let selectedBoxId = selectedBox,
               let selectedTextBox = textBoxes.first(where: { $0.id == selectedBoxId }) {
                HStack(spacing: 8) {
                    // Resize button
                    Button(action: {
                        resizingTextId = selectedBoxId
                        showingTextResizer = true
                    }) {
                        Image(systemName: "textformat.size")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    // Delete button
                    Button(action: {
                        deleteTextBox(id: selectedBoxId)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                .position(x: selectedTextBox.position.x + 80, y: selectedTextBox.position.y - 30)
            }
            
            // Delete button for selected sticky note
            if let selectedNoteId = selectedNote,
               let selectedStickyNote = stickyNotes.first(where: { $0.id == selectedNoteId }) {
                Button(action: {
                    deleteStickyNote(id: selectedNoteId)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .position(x: selectedStickyNote.position.x + 75, y: selectedStickyNote.position.y - 75)
            }
            
            // Inline text editor that appears where you tap
            if showingInlineEditor {
                VStack {
                    HStack {
                        TextField("", text: $newText)
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(.black)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.leading)
                            .background(Color.clear)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                finishInlineEditing()
                            }
                            .onTapGesture {
                                // Prevent the tap from propagating to the background
                            }
                            .keyboardType(.default)
                            .autocorrectionDisabled(false)
                            .frame(minHeight: 30)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .offset(x: inlineEditorPosition.x, y: inlineEditorPosition.y)
            }
            
            // Sticky note editor
            if showingStickyNoteEditor {
                VStack(spacing: 8) {
                    TextField("Write your note...", text: $newStickyText, axis: .vertical)
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.black)
                        .padding(12)
                        .lineLimit(5...8)
                        .focused($isStickyNoteFocused)
                        .onSubmit {
                            finishStickyNoteEditing()
                        }
                        .keyboardType(.default)
                        .autocorrectionDisabled(false)
                    
                    // Color picker for sticky notes
                    HStack(spacing: 4) {
                        ForEach(StickyNoteColor.allCases, id: \.self) { color in
                            Button(action: {
                                selectedStickyColor = color
                            }) {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedStickyColor == color ? Color.black : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    HStack {
                        Button("Cancel") {
                            cancelStickyNoteEditing()
                        }
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button("Done") {
                            finishStickyNoteEditing()
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .frame(width: 150, height: 180)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedStickyColor.color.opacity(0.9))
                        .shadow(radius: 4)
                )
                .position(stickyNotePosition)
                .onTapGesture {
                    // Prevent the tap from propagating to the background
                }
            }
            
            // Text resizer overlay
            if showingTextResizer, let resizingId = resizingTextId,
               let textBox = textBoxes.first(where: { $0.id == resizingId }) {
                VStack(spacing: 12) {
                    Text("Text Size")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 16) {
                        ForEach([12, 16, 20, 24, 32], id: \.self) { size in
                            Button(action: {
                                updateTextSize(id: resizingId, size: CGFloat(size))
                                showingTextResizer = false
                                resizingTextId = nil
                            }) {
                                Text("Aa")
                                    .font(.custom("Georgia", size: CGFloat(size)))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(textBox.fontSize == CGFloat(size) ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                                    )
                            }
                        }
                    }
                    
                    Button("Done") {
                        showingTextResizer = false
                        resizingTextId = nil
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(radius: 8)
                )
                .position(x: textBox.position.x, y: textBox.position.y - 100)
                .onTapGesture {
                    // Prevent the tap from propagating to the background
                }
            }
        }
        .onAppear {
            loadTextBoxes()
            loadStickyNotes()
        }
        .onChange(of: date) { _ in
            // Save any current text before switching dates
            if showingInlineEditor && !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let newBox = TextBox(
                    text: newText,
                    position: inlineEditorPosition,
                    fontSize: 16
                )
                textBoxes.append(newBox)
                saveTextBoxes()
            }
            
            if showingStickyNoteEditor && !newStickyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let newNote = StickyNote(
                    text: newStickyText,
                    position: stickyNotePosition,
                    color: selectedStickyColor
                )
                stickyNotes.append(newNote)
                saveStickyNotes()
            }
            
            // Reset editor states for new date
            showingInlineEditor = false
            showingStickyNoteEditor = false
            showingTextResizer = false
            isTextFieldFocused = false
            isStickyNoteFocused = false
            newText = ""
            newStickyText = ""
            selectedBox = nil
            selectedNote = nil
            resizingTextId = nil
            selectedStickyColor = .yellow
            
            // Load content for the new date
            DispatchQueue.main.async {
                loadTextBoxes()
                loadStickyNotes()
            }
        }

    }
    
    private func startInlineEditing(at location: CGPoint) {
        inlineEditorPosition = location
        newText = ""
        showingInlineEditor = true
        isTextFieldFocused = true
    }
    
    private func finishInlineEditing() {
        // Always save text, even if it's empty (user might want to delete)
        if !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let newBox = TextBox(
                text: newText,
                position: inlineEditorPosition,
                fontSize: 16
            )
            textBoxes.append(newBox)
            saveTextBoxes()
        }
        
        newText = ""
        showingInlineEditor = false
        isTextFieldFocused = false
    }
    
    private func startStickyNoteEditing(at location: CGPoint) {
        stickyNotePosition = location
        newStickyText = ""
        showingStickyNoteEditor = true
        isStickyNoteFocused = true
    }
    
    private func finishStickyNoteEditing() {
        if !newStickyText.isEmpty {
            let newNote = StickyNote(
                text: newStickyText,
                position: stickyNotePosition,
                color: selectedStickyColor
            )
            stickyNotes.append(newNote)
            saveStickyNotes()
        }
        
        newStickyText = ""
        showingStickyNoteEditor = false
        isStickyNoteFocused = false
        selectedStickyColor = .yellow
    }
    
    private func cancelStickyNoteEditing() {
        newStickyText = ""
        showingStickyNoteEditor = false
        isStickyNoteFocused = false
        selectedStickyColor = .yellow
    }
    
    private func updateTextSize(id: UUID, size: CGFloat) {
        if let index = textBoxes.firstIndex(where: { $0.id == id }) {
            textBoxes[index].fontSize = size
            saveTextBoxes()
        }
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
    
    private func updateStickyNotePosition(id: UUID, position: CGPoint) {
        if let index = stickyNotes.firstIndex(where: { $0.id == id }) {
            stickyNotes[index].position = position
            saveStickyNotes()
        }
    }
    
    private func deleteStickyNote(id: UUID) {
        stickyNotes.removeAll { $0.id == id }
        selectedNote = nil
        saveStickyNotes()
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
        } else {
            textBoxes = []
        }
    }
    
    private func saveStickyNotes() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let notesURL = documentsPath.appendingPathComponent("sticky_notes_\(dateKey).json")
        
        if let data = try? JSONEncoder().encode(stickyNotes) {
            try? data.write(to: notesURL)
        }
    }
    
    private func loadStickyNotes() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let notesURL = documentsPath.appendingPathComponent("sticky_notes_\(dateKey).json")
        
        if let data = try? Data(contentsOf: notesURL),
           let notes = try? JSONDecoder().decode([StickyNote].self, from: data) {
            stickyNotes = notes
        } else {
            stickyNotes = []
        }
    }
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

enum StickyNoteColor: String, CaseIterable, Codable {
    case yellow = "yellow"
    case pink = "pink"
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    
    var color: Color {
        switch self {
        case .yellow: return .yellow
        case .pink: return .pink
        case .blue: return Color(red: 0.7, green: 0.9, blue: 1.0)
        case .green: return Color(red: 0.7, green: 1.0, blue: 0.7)
        case .orange: return .orange
        }
    }
}

struct StickyNote: Identifiable, Codable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var color: StickyNoteColor
    
    enum CodingKeys: String, CodingKey {
        case text, position, color
    }
    
    init(text: String, position: CGPoint, color: StickyNoteColor) {
        self.text = text
        self.position = position
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        
        // Decode CGPoint manually
        let positionContainer = try container.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
        let x = try positionContainer.decode(CGFloat.self, forKey: .x)
        let y = try positionContainer.decode(CGFloat.self, forKey: .y)
        position = CGPoint(x: x, y: y)
        
        // Try to decode color, default to yellow if not found
        if let colorString = try? container.decode(String.self, forKey: .color),
           let stickyColor = StickyNoteColor(rawValue: colorString) {
            color = stickyColor
        } else {
            color = .yellow
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        
        // Encode CGPoint manually
        var positionContainer = container.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
        try positionContainer.encode(position.x, forKey: .x)
        try positionContainer.encode(position.y, forKey: .y)
        
        // Encode color
        try container.encode(color.rawValue, forKey: .color)
    }
    
    private enum PositionKeys: String, CodingKey {
        case x, y
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

struct DraggableStickyNote: View {
    let note: StickyNote
    let isSelected: Bool
    let onTap: () -> Void
    let onMove: (CGPoint) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text(note.text)
                .font(.custom("Georgia", size: 12))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineLimit(6)
                .frame(maxWidth: 130, maxHeight: 120, alignment: .topLeading)
                .padding(10)
        }
        .frame(width: 150, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(note.color.color.opacity(0.9))
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                .shadow(radius: 4)
        )
        .position(note.position)
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