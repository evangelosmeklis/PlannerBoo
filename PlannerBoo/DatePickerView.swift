import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @State private var tempDate = Date()
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                Text("Go to Date")
                    .font(.custom("Georgia", size: 28))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Calendar-style date picker
                VStack(spacing: 16) {
                    Text("Select a date to jump to")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    DatePicker(
                        "Select Date",
                        selection: $tempDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.98, green: 0.97, blue: 0.94))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                }
                .padding(.horizontal)
                
                // Quick date options
                VStack(spacing: 12) {
                    Text("Quick Navigation")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickDateButton(title: "Today", date: Calendar.current.startOfDay(for: Date())) {
                            let normalizedDate = Calendar.current.startOfDay(for: Date())
                            tempDate = normalizedDate
                            selectedDate = normalizedDate
                            isPresented = false
                        }
                        
                        QuickDateButton(title: "Tomorrow", date: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())) {
                            let normalizedDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
                            tempDate = normalizedDate
                            selectedDate = normalizedDate
                            isPresented = false
                        }
                        
                        QuickDateButton(title: "Next Week", date: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date())) {
                            let normalizedDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date())
                            tempDate = normalizedDate
                            selectedDate = normalizedDate
                            isPresented = false
                        }
                        
                        QuickDateButton(title: "Next Month", date: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date())) {
                            let normalizedDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date())
                            tempDate = normalizedDate
                            selectedDate = normalizedDate
                            isPresented = false
                        }
                        
                        QuickDateButton(title: "Birthday", date: Calendar.current.startOfDay(for: Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()), month: 6, day: 15)) ?? Date())) {
                            let normalizedDate = Calendar.current.startOfDay(for: Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()), month: 6, day: 15)) ?? Date())
                            tempDate = normalizedDate
                            selectedDate = normalizedDate
                            isPresented = false
                        }
                        
                        QuickDateButton(title: "New Year", date: Calendar.current.startOfDay(for: Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()) + 1, month: 1, day: 1)) ?? Date())) {
                            let normalizedDate = Calendar.current.startOfDay(for: Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()) + 1, month: 1, day: 1)) ?? Date())
                            tempDate = normalizedDate
                            selectedDate = normalizedDate
                            isPresented = false
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    
                    Button("Go to Date") {
                        let normalizedDate = Calendar.current.startOfDay(for: tempDate)
                        selectedDate = normalizedDate
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .onAppear {
                tempDate = Calendar.current.startOfDay(for: selectedDate)
            }
        }
    }
}

struct QuickDateButton: View {
    let title: String
    let date: Date
    let action: () -> Void
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(dateFormatter.string(from: date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.05))
            .cornerRadius(8)
        }
        .foregroundColor(.black)
    }
}

#Preview {
    DatePickerView(
        selectedDate: .constant(Date()),
        isPresented: .constant(true)
    )
}