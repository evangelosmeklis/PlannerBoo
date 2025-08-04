import SwiftUI
import EventKit

struct EventWidget: Identifiable, Codable {
    let id = UUID()
    var title: String
    var startTime: Date
    var endTime: Date
    var position: CGPoint
    var isReminder: Bool
    var isCompleted: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case title, startTime, endTime, position, isReminder, isCompleted
    }
    
    init(title: String, startTime: Date, endTime: Date, position: CGPoint, isReminder: Bool) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.position = position
        self.isReminder = isReminder
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        isReminder = try container.decode(Bool.self, forKey: .isReminder)
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        
        // Decode CGPoint manually
        let positionContainer = try container.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
        let x = try positionContainer.decode(CGFloat.self, forKey: .x)
        let y = try positionContainer.decode(CGFloat.self, forKey: .y)
        position = CGPoint(x: x, y: y)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(isReminder, forKey: .isReminder)
        try container.encode(isCompleted, forKey: .isCompleted)
        
        // Encode CGPoint manually
        var positionContainer = container.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
        try positionContainer.encode(position.x, forKey: .x)
        try positionContainer.encode(position.y, forKey: .y)
    }
    
    private enum PositionKeys: String, CodingKey {
        case x, y
    }
}

struct DraggableEventWidget: View {
    let eventWidget: EventWidget
    let isSelected: Bool
    let toolMode: ToolMode
    let onTap: () -> Void
    let onMove: (CGPoint) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleComplete: () -> Void
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: eventWidget.isReminder ? "bell.fill" : "calendar")
                        .foregroundColor(eventWidget.isReminder ? .orange : .blue)
                        .font(.caption)
                    
                    Text(eventWidget.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if eventWidget.isReminder {
                        Button(action: onToggleComplete) {
                            Image(systemName: eventWidget.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(eventWidget.isCompleted ? .green : .gray)
                                .font(.caption)
                        }
                    }
                }
                
                HStack {
                    Text(timeFormatter.string(from: eventWidget.startTime))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    if !eventWidget.isReminder {
                        Text("- \(timeFormatter.string(from: eventWidget.endTime))")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(8)
            .frame(width: 160, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(eventWidget.isReminder ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    .shadow(radius: 2)
            )
            .opacity(eventWidget.isCompleted ? 0.6 : 1.0)
            
            // Show controls when selected and in hand mode
            if isSelected && toolMode == .hand {
                VStack {
                    HStack {
                        Spacer()
                        // Delete button
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                                .background(Color.white.clipShape(Circle()))
                        }
                        .offset(x: 10, y: -10)
                    }
                    
                    Spacer()
                    
                    HStack {
                        // Edit button
                        Button(action: onEdit) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                                .background(Color.white.clipShape(Circle()))
                        }
                        .offset(x: -10, y: 10)
                        
                        Spacer()
                    }
                }
                .frame(width: 160, height: 60)
            }
        }
        .position(eventWidget.position)
        .onTapGesture {
            if toolMode == .hand {
                onTap()
            }
        }
        .gesture(
            DragGesture(minimumDistance: toolMode == .hand ? 5 : 1000)
                .onChanged { value in
                    if toolMode == .hand {
                        onMove(value.location)
                    }
                }
        )
        .contextMenu {
            Button("Edit") {
                onEdit()
            }
            Button("Delete", role: .destructive) {
                onDelete()
            }
            if eventWidget.isReminder {
                Button(eventWidget.isCompleted ? "Mark Incomplete" : "Mark Complete") {
                    onToggleComplete()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var toolMode: ToolMode = .hand
    
    DraggableEventWidget(
        eventWidget: EventWidget(
            title: "Team Meeting",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            position: CGPoint(x: 200, y: 200),
            isReminder: false
        ),
        isSelected: true,
        toolMode: toolMode,
        onTap: {},
        onMove: { _ in },
        onEdit: {},
        onDelete: {},
        onToggleComplete: {}
    )
    .frame(width: 400, height: 400)
    .background(Color.gray.opacity(0.1))
}