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
        // Check if we have permission first
        eventStore.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if granted {
                    let event = EKEvent(eventStore: self.eventStore)
                    event.title = title
                    event.startDate = date
                    event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
                    
                    // Try to get default calendar, if nil use first available calendar
                    if let defaultCalendar = self.eventStore.defaultCalendarForNewEvents {
                        event.calendar = defaultCalendar
                    } else {
                        // Get first writable calendar
                        let calendars = self.eventStore.calendars(for: .event).filter { $0.allowsContentModifications }
                        if let firstCalendar = calendars.first {
                            event.calendar = firstCalendar
                        } else {
                            self.alertMessage = "No writable calendar found. Please check your Calendar app settings."
                            self.showingAlert = true
                            return
                        }
                    }
                    
                    do {
                        try self.eventStore.save(event, span: .thisEvent)
                        self.alertMessage = "Event created successfully in Calendar!"
                        self.showingAlert = true
                    } catch {
                        self.alertMessage = "Failed to create event: \(error.localizedDescription)"
                        self.showingAlert = true
                    }
                } else {
                    self.alertMessage = "Calendar access is required to create events. Please enable it in Settings > Privacy & Security > Calendars."
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func createReminder(title: String, date: Date) {
        // Check if we have permission first
        eventStore.requestFullAccessToReminders { granted, error in
            DispatchQueue.main.async {
                if granted {
                    let reminder = EKReminder(eventStore: self.eventStore)
                    reminder.title = title
                    reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    // Try to get default calendar, if nil use first available calendar
                    if let defaultCalendar = self.eventStore.defaultCalendarForNewReminders() {
                        reminder.calendar = defaultCalendar
                    } else {
                        // Get first writable reminder list
                        let calendars = self.eventStore.calendars(for: .reminder).filter { $0.allowsContentModifications }
                        if let firstCalendar = calendars.first {
                            reminder.calendar = firstCalendar
                        } else {
                            self.alertMessage = "No writable reminder list found. Please check your Reminders app settings."
                            self.showingAlert = true
                            return
                        }
                    }
                    
                    do {
                        try self.eventStore.save(reminder, commit: true)
                        self.alertMessage = "Reminder created successfully!"
                        self.showingAlert = true
                    } catch {
                        self.alertMessage = "Failed to create reminder: \(error.localizedDescription)"
                        self.showingAlert = true
                    }
                } else {
                    self.alertMessage = "Reminders access is required to create reminders. Please enable it in Settings > Privacy & Security > Reminders."
                    self.showingAlert = true
                }
            }
        }
    }
}

#Preview {
    EventCreatorView(date: Date())
}