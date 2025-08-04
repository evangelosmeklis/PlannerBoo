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
                
                Text("Track your daily wellness")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Record your mood, energy level, and daily reflections")
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