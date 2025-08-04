import SwiftUI
import EventKit

struct EventCreatorView: View {
    let date: Date
    @State private var eventTitle = ""
    @State private var eventTime = Date()
    @State private var isReminder = false
    @State private var eventStore = EKEventStore()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var permissionsManager: PermissionsManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Title", text: $eventTitle)
                    
                    DatePicker("Time", selection: $eventTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                    
                    Toggle("Create as Reminder", isOn: $isReminder)
                }
                
                Section(footer: Text(isReminder ? "This will be added to your Reminders app" : "This will be added to your Calendar app")) {
                    EmptyView()
                }
            }
            .navigationTitle(isReminder ? "New Reminder" : "New Event")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveEvent()
                }
                .disabled(eventTitle.isEmpty)
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Event Creation"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage.contains("successfully") {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
        .onAppear {
            // Check current permissions
            if isReminder && !permissionsManager.remindersAccess {
                Task {
                    await permissionsManager.requestRemindersAccess()
                }
            } else if !isReminder && !permissionsManager.calendarAccess {
                Task {
                    await permissionsManager.requestCalendarAccess()
                }
            }
        }
    }
    
    private func requestAccess() {
        if isReminder {
            eventStore.requestFullAccessToReminders { granted, error in
                DispatchQueue.main.async {
                    if !granted {
                        alertMessage = "Access to Reminders is required to create reminders."
                        showingAlert = true
                    }
                }
            }
        } else {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    if !granted {
                        alertMessage = "Access to Calendar is required to create events."
                        showingAlert = true
                    }
                }
            }
        }
    }
    
    private func saveEvent() {
        let calendar = Calendar.current
        let eventDate = calendar.date(bySettingHour: calendar.component(.hour, from: eventTime),
                                     minute: calendar.component(.minute, from: eventTime),
                                     second: 0,
                                     of: date) ?? date
        
        if isReminder {
            createReminder(title: eventTitle, date: eventDate)
        } else {
            createCalendarEvent(title: eventTitle, date: eventDate)
        }
    }
    
    private func createCalendarEvent(title: String, date: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            alertMessage = "Event created successfully in Calendar!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to create event: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func createReminder(title: String, date: Date) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(reminder, commit: true)
            alertMessage = "Reminder created successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to create reminder: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    EventCreatorView(date: Date())
}