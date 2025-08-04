import SwiftUI

struct PlannerPageView: View {
    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedDate) {
                ForEach(generateDates(), id: \.self) { date in
                    DailyPlannerPage(date: date)
                        .tag(date)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                selectedDate = normalizeDate(currentDate)
            }
            .onChange(of: selectedDate) {
                // Ensure the selected date is normalized and exists in our date range
                let normalized = normalizeDate(selectedDate)
                if selectedDate != normalized {
                    selectedDate = normalized
                }
            }
            
            // Date navigation overlay
            VStack {
                HStack {
                    Spacer()
                    
                    // Date picker button
                    Button(action: { showDatePicker = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text("Go to Date")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 50) // Below status bar
                }
                
                Spacer()
                
                // Navigation hint at bottom
                HStack {
                    Text("← Swipe to navigate between days →")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerView(selectedDate: $selectedDate, isPresented: $showDatePicker)
        }
    }
    
    private func generateDates() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        // Normalize current date to start of day
        let baseDate = calendar.startOfDay(for: currentDate)
        
        // Generate full year (365 days: 180 before, current, 184 after)
        for i in -180...184 {
            if let date = calendar.date(byAdding: .day, value: i, to: baseDate) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func normalizeDate(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
}

#Preview {
    PlannerPageView()
        .environmentObject(PermissionsManager())
}