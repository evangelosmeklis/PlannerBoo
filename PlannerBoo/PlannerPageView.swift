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
                    .clipped() // Improve performance by clipping content
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.2), value: selectedDate) // Faster animation
            .onAppear {
                if !isInitialized {
                    selectedDate = normalizeDate(currentDate)
                    generatedDates = generateDates()
                    isInitialized = true
                }
            }
            .onChange(of: selectedDate) { newDate in
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
        
        // Generate only 2 weeks worth of dates for better performance
        // 1 week before, current, 1 week after
        for i in -7...7 {
            if let date = calendar.date(byAdding: .day, value: i, to: baseDate) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func checkAndRegenerateDates(for newDate: Date) {
        let calendar = Calendar.current
        
        // Check if we're getting close to the edges and need to regenerate
        guard let firstDate = generatedDates.first,
              let lastDate = generatedDates.last else { return }
        
        let daysBetweenNewAndFirst = calendar.dateComponents([.day], from: firstDate, to: newDate).day ?? 0
        let daysBetweenNewAndLast = calendar.dateComponents([.day], from: newDate, to: lastDate).day ?? 0
        
        // If we're within 2 days of either edge, regenerate around the new date
        if daysBetweenNewAndFirst <= 2 || daysBetweenNewAndLast <= 2 {
            let baseDate = calendar.startOfDay(for: newDate)
            var newDates: [Date] = []
            
            for i in -7...7 {
                if let date = calendar.date(byAdding: .day, value: i, to: baseDate) {
                    newDates.append(date)
                }
            }
            
            generatedDates = newDates
        }
    }
    
    private func normalizeDate(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
}

#Preview {
    PlannerPageView()
        .environmentObject(PermissionsManager())
}