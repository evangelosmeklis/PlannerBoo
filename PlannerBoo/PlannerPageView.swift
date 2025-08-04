import SwiftUI

struct PlannerPageView: View {
    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    
    var body: some View {
        TabView(selection: $selectedDate) {
            ForEach(generateDates(), id: \.self) { date in
                DailyPlannerPage(date: date)
                    .tag(date)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear {
            selectedDate = currentDate
        }
    }
    
    private func generateDates() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        // Generate 60 days (30 before, current, 29 after)
        for i in -30...29 {
            if let date = calendar.date(byAdding: .day, value: i, to: currentDate) {
                dates.append(date)
            }
        }
        
        return dates
    }
}

#Preview {
    PlannerPageView()
        .environmentObject(PermissionsManager())
}