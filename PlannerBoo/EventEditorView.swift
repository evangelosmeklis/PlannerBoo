import SwiftUI

struct EventEditorView: View {
    @State private var title: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var isReminder: Bool
    @State private var isCompleted: Bool
    
    let event: EventWidget
    let onSave: (EventWidget) -> Void
    let onCancel: () -> Void
    
    init(event: EventWidget, onSave: @escaping (EventWidget) -> Void, onCancel: @escaping () -> Void) {
        self.event = event
        self.onSave = onSave
        self.onCancel = onCancel
        
        _title = State(initialValue: event.title)
        _startTime = State(initialValue: event.startTime)
        _endTime = State(initialValue: event.endTime)
        _isReminder = State(initialValue: event.isReminder)
        _isCompleted = State(initialValue: event.isCompleted)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    
                    DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                    
                    if !isReminder {
                        DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                    
                    Toggle("Is Reminder", isOn: $isReminder)
                    
                    if isReminder {
                        Toggle("Completed", isOn: $isCompleted)
                    }
                }
            }
            .navigationTitle("Edit \(isReminder ? "Reminder" : "Event")")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCancel()
                },
                trailing: Button("Save") {
                    saveEvent()
                }
                .disabled(title.isEmpty)
            )
        }
        .onChange(of: isReminder) { oldValue, newValue in
            if newValue {
                // When switching to reminder, set end time to start time
                endTime = startTime
            } else {
                // When switching to event, set end time to 1 hour after start
                endTime = Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
            }
        }
    }
    
    private func saveEvent() {
        var updatedEvent = event
        updatedEvent.title = title
        updatedEvent.startTime = startTime
        updatedEvent.endTime = isReminder ? startTime : endTime
        updatedEvent.isReminder = isReminder
        updatedEvent.isCompleted = isCompleted
        
        onSave(updatedEvent)
    }
}

#Preview {
    EventEditorView(
        event: EventWidget(
            title: "Sample Event",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            position: CGPoint(x: 100, y: 100),
            isReminder: false
        ),
        onSave: { _ in },
        onCancel: {}
    )
}