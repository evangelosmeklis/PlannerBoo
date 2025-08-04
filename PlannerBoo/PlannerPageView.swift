import SwiftUI

struct PlannerPageView: View {
    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    @State private var generatedDates: [Date] = []
    @State private var isInitialized = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedDate) {
                ForEach(generatedDates, id: \.self) { date in
                    DailyPlannerPage(date: date, onDateSelected: { newDate in
                        selectedDate = normalizeDate(newDate)
                    })
                    .tag(date)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                if !isInitialized {
                    selectedDate = normalizeDate(currentDate)
                    generatedDates = generateDates()
                    isInitialized = true
                }
            }
            .onChange(of: selectedDate) { newDate in
                print("Selected date changed to: \(newDate)")
                // Only check for regeneration if we're initialized and not currently regenerating
                if isInitialized {
                    checkAndRegenerateDates(for: newDate)
                }
            }
            
            // Navigation hint overlay
            VStack {
                Spacer()
                
                // Navigation and usage hints at bottom
                VStack(spacing: 8) {
                    Text("← Swipe to navigate between days →")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                    
                    Text("Tap to add text • Double tap for sticky notes")
                        .font(.caption2)
                        .foregroundColor(.black.opacity(0.4))
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(6)
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private func generateDates() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        // Use currentDate as the base for initial generation
        let baseDate = calendar.startOfDay(for: currentDate)
        
        // Generate 3 years worth of dates (much larger buffer for smoother experience)
        // 1.5 years before, current, 1.5 years after
        for i in -547...547 {
            if let date = calendar.date(byAdding: .day, value: i, to: baseDate) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func checkAndRegenerateDates(for newDate: Date) {
        // Completely disable regeneration to ensure smooth swiping
        // The 3-year buffer should be more than enough for normal usage
        return
    }
    
    private func normalizeDate(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
}

#Preview {
    PlannerPageView()
        .environmentObject(PermissionsManager())
}