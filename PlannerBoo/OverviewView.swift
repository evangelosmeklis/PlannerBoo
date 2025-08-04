import SwiftUI

struct OverviewView: View {
    @State private var selectedSegment = 0
    @State private var selectedDate = Date()
    @Environment(\.presentationMode) var presentationMode
    let onDateSelected: ((Date) -> Void)?
    
    private let segments = ["Week", "Month", "Year"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segment control
                Picker("View Type", selection: $selectedSegment) {
                    ForEach(0..<segments.count, id: \.self) { index in
                        Text(segments[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selection
                Group {
                    if selectedSegment == 0 {
                        WeekOverviewView(selectedDate: $selectedDate, onDateSelected: onDateSelected)
                    } else if selectedSegment == 1 {
                        MonthOverviewView(selectedDate: $selectedDate, onDateSelected: onDateSelected)
                    } else {
                        YearOverviewView(selectedDate: $selectedDate, onDateSelected: onDateSelected)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WeekOverviewView: View {
    @Binding var selectedDate: Date
    let onDateSelected: ((Date) -> Void)?
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var weekDays: [Date] {
        var startOfWeek: Date
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) {
            startOfWeek = weekInterval.start
        } else {
            startOfWeek = selectedDate
        }
        
        var days: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(day)
            }
        }
        return days
    }
    
    private var weekDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var numberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Week navigation
                HStack {
                    Button(action: { 
                        if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(weekDateFormatter.string(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                
                // Week view
                if !weekDays.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(weekDays, id: \.self) { date in
                            WeekDayCard(date: date, onDateSelected: onDateSelected)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Unable to load week data")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical)
        }
    }
}

struct WeekDayCard: View {
    let date: Date
    let onDateSelected: ((Date) -> Void)?
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var numberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: {
            onDateSelected?(date)
        }) {
            VStack(spacing: 8) {
                Text(dayFormatter.string(from: date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(numberFormatter.string(from: date))
                    .font(.title2)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(isToday ? .white : .primary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isToday ? Color.blue : Color.clear)
                    )
                
                // Placeholder for activities/notes indicator
                Circle()
                    .fill(hasContent ? Color.green : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var hasContent: Bool {
        // Simple check - always show false for now until we implement content checking
        false
    }
}

struct MonthOverviewView: View {
    @Binding var selectedDate: Date
    let onDateSelected: ((Date) -> Void)?
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else { 
            return []
        }
        
        let startOfMonth = monthInterval.start
        var startOfCalendar: Date
        
        // Get start of the week containing the first day of the month
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: startOfMonth) {
            startOfCalendar = weekInterval.start
        } else {
            startOfCalendar = startOfMonth
        }
        
        var days: [Date] = []
        var currentDate = startOfCalendar
        
        // Show 6 weeks (42 days) to cover the full month view
        for _ in 0..<42 {
            days.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return days
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Month navigation
                HStack {
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(monthDateFormatter.string(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                
                // Day headers
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Month calendar
                if !daysInMonth.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                        ForEach(daysInMonth, id: \.self) { date in
                            MonthDayCard(date: date, currentMonth: selectedDate, onDateSelected: onDateSelected)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Unable to load month data")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical)
        }
    }
}

struct MonthDayCard: View {
    let date: Date
    let currentMonth: Date
    let onDateSelected: ((Date) -> Void)?
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: {
            onDateSelected?(date)
        }) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.caption)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(isCurrentMonth ? (isToday ? .white : .primary) : .secondary)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(isToday ? Color.blue : Color.clear)
                    )
                
                // Activity indicators
                HStack(spacing: 2) {
                    if hasDrawings {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 4, height: 4)
                    }
                    if hasText {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 4, height: 4)
                    }
                    if hasPhotos {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 8)
            }
            .frame(minHeight: 40)
            .opacity(isCurrentMonth ? 1.0 : 0.3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Simplified content checking - always false for now
    private var hasDrawings: Bool { false }
    private var hasText: Bool { false }
    private var hasPhotos: Bool { false }
}

struct YearOverviewView: View {
    @Binding var selectedDate: Date
    let onDateSelected: ((Date) -> Void)?
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
    
    private var monthsInYear: [Date] {
        let year = calendar.component(.year, from: selectedDate)
        return (1...12).compactMap { month in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1
            return calendar.date(from: components)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Year navigation
                HStack {
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .year, value: -1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(yearFormatter.string(from: selectedDate))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .year, value: 1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                
                // Year grid (3x4 months)
                if !monthsInYear.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach(monthsInYear, id: \.self) { month in
                            YearMonthCard(month: month, onDateSelected: onDateSelected)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Unable to load year data")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical)
        }
    }
}

struct YearMonthCard: View {
    let month: Date
    let onDateSelected: ((Date) -> Void)?
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month)
    }
    
    var body: some View {
        Button(action: {
            onDateSelected?(month)
        }) {
            VStack(spacing: 8) {
                Text(monthFormatter.string(from: month))
                    .font(.headline)
                    .fontWeight(isCurrentMonth ? .bold : .medium)
                    .foregroundColor(isCurrentMonth ? .blue : .primary)
                
                // Mini calendar preview
                MiniMonthCalendar(month: month)
                
                // Activity summary
                HStack(spacing: 8) {
                    ActivitySummaryDot(color: .orange, count: daysWithDrawings)
                    ActivitySummaryDot(color: .green, count: daysWithText)
                    ActivitySummaryDot(color: .blue, count: daysWithPhotos)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCurrentMonth ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Simplified content summary - always 0 for now
    private var daysWithDrawings: Int { 0 }
    private var daysWithText: Int { 0 }
    private var daysWithPhotos: Int { 0 }
}

struct MiniMonthCalendar: View {
    let month: Date
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        
        let startOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty days for the beginning of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add actual days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
            ForEach(0..<daysInMonth.count, id: \.self) { index in
                if let date = daysInMonth[index] {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.caption2)
                        .foregroundColor(Calendar.current.isDateInToday(date) ? .white : .primary)
                        .frame(width: 16, height: 16)
                        .background(
                            Circle()
                                .fill(Calendar.current.isDateInToday(date) ? Color.blue : Color.clear)
                        )
                } else {
                    Text("")
                        .frame(width: 16, height: 16)
                }
            }
        }
    }
}

struct ActivitySummaryDot: View {
    let color: Color
    let count: Int
    
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(count)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    OverviewView(onDateSelected: nil)
}