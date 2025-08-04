import SwiftUI

struct HealthDataView: View {
    let date: Date
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health & Fitness - \(dateFormatter.string(from: date))")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                Image(systemName: "heart.text.square")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                
                Text("Health integration coming soon")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Step count, workouts, and health metrics will be displayed here")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HealthDataView(date: Date())
}