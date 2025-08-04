import SwiftUI
import EventKit

struct EventWidgetOverlay: View {
    @State private var eventWidgets: [EventWidget] = []
    @State private var selectedEventId: UUID?
    @State private var showingEventEditor = false
    @State private var editingEvent: EventWidget?
    
    let date: Date
    @Binding var toolMode: ToolMode
    
    var body: some View {
        ZStack {
            // Transparent background for deselecting events
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if toolMode == .hand {
                        selectedEventId = nil
                    }
                }
                .allowsHitTesting(toolMode == .hand)
            
            // Event widgets
            ForEach(eventWidgets) { widget in
                DraggableEventWidget(
                    eventWidget: widget,
                    isSelected: selectedEventId == widget.id,
                    toolMode: toolMode,
                    onTap: {
                        if toolMode == .hand {
                            selectedEventId = selectedEventId == widget.id ? nil : widget.id
                        }
                    },
                    onMove: { newPosition in
                        updateEventPosition(id: widget.id, position: newPosition)
                    },
                    onEdit: {
                        editingEvent = widget
                        showingEventEditor = true
                    },
                    onDelete: {
                        deleteEvent(id: widget.id)
                        selectedEventId = nil
                    },
                    onToggleComplete: {
                        toggleEventCompletion(id: widget.id)
                    }
                )
            }
        }
        .onAppear {
            loadEvents()
        }
        .onReceive(NotificationCenter.default.publisher(for: .eventCreated)) { notification in
            if let userInfo = notification.userInfo,
               let title = userInfo["title"] as? String,
               let startTime = userInfo["startTime"] as? Date,
               let endTime = userInfo["endTime"] as? Date,
               let isReminder = userInfo["isReminder"] as? Bool,
               let notificationDate = userInfo["date"] as? Date,
               Calendar.current.isDate(notificationDate, inSameDayAs: date) {
                addEvent(title: title, startTime: startTime, endTime: endTime, isReminder: isReminder)
            }
        }
        .sheet(isPresented: $showingEventEditor) {
            if let event = editingEvent {
                EventEditorView(
                    event: event,
                    onSave: { updatedEvent in
                        updateEvent(updatedEvent)
                        showingEventEditor = false
                        editingEvent = nil
                    },
                    onCancel: {
                        showingEventEditor = false
                        editingEvent = nil
                    }
                )
            }
        }
    }
    
    private func addEvent(title: String, startTime: Date, endTime: Date, isReminder: Bool) {
        let newEvent = EventWidget(
            title: title,
            startTime: startTime,
            endTime: endTime,
            position: CGPoint(x: 200, y: 300),
            isReminder: isReminder
        )
        eventWidgets.append(newEvent)
        saveEvents()
    }
    
    private func updateEventPosition(id: UUID, position: CGPoint) {
        if let index = eventWidgets.firstIndex(where: { $0.id == id }) {
            eventWidgets[index].position = position
            saveEvents()
        }
    }
    
    private func updateEvent(_ updatedEvent: EventWidget) {
        if let index = eventWidgets.firstIndex(where: { $0.id == updatedEvent.id }) {
            eventWidgets[index] = updatedEvent
            saveEvents()
        }
    }
    
    private func deleteEvent(id: UUID) {
        eventWidgets.removeAll { $0.id == id }
        saveEvents()
    }
    
    private func toggleEventCompletion(id: UUID) {
        if let index = eventWidgets.firstIndex(where: { $0.id == id }) {
            eventWidgets[index].isCompleted.toggle()
            saveEvents()
        }
    }
    
    private func saveEvents() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let eventsURL = documentsPath.appendingPathComponent("events_\(dateKey).json")
        
        if let data = try? JSONEncoder().encode(eventWidgets) {
            try? data.write(to: eventsURL)
        }
    }
    
    private func loadEvents() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let eventsURL = documentsPath.appendingPathComponent("events_\(dateKey).json")
        
        if let data = try? Data(contentsOf: eventsURL),
           let events = try? JSONDecoder().decode([EventWidget].self, from: data) {
            eventWidgets = events
        } else {
            eventWidgets = []
        }
    }
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

extension Notification.Name {
    static let eventCreated = Notification.Name("eventCreated")
}

#Preview {
    @Previewable @State var toolMode: ToolMode = .hand
    
    EventWidgetOverlay(date: Date(), toolMode: $toolMode)
        .frame(width: 400, height: 600)
        .background(Color.gray.opacity(0.1))
}