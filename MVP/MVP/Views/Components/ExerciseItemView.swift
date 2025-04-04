import SwiftUI
import SDWebImageSwiftUI

struct ExerciseItemView: View {
    let exercise: Exercise
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Image
            if let imageURL = exercise.imageURL {
                WebImage(url: imageURL)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(10)
            }
            
            // Exercise Details
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(exercise.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Target Joints
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.blue)
                    Text(exercise.targetJoints.map { $0.rawValue.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
        .onTapGesture {
            appState.setCurrentExercise(exercise)
        }
    }
}

#Preview {
    ExerciseItemView(exercise: Exercise.examples[0])
        .environmentObject(AppState())
        .padding()
        .background(Color(.systemGroupedBackground))
} 