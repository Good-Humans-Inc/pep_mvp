import SwiftUI
import ElevenLabsSDK

// MARK: - Exercise Feedback Data Model
struct ExerciseFeedbackData: Codable, Equatable {
    var generalFeeling: String
    var performanceQuality: String
    var painReport: String
    var completed: Bool
    var setsCompleted: Int
    var repsCompleted: Int
    var dayStreak: Int
    var motivationalMessage: String
    
    static let defaultData = ExerciseFeedbackData(
        generalFeeling: "No data collected for this session.",
        performanceQuality: "No quality assessment for this session.",
        painReport: "No pain report for this session.",
        completed: true,
        setsCompleted: 0,
        repsCompleted: 0,
        dayStreak: 1,
        motivationalMessage: "Great job completing your exercise! Keep up the good work to continue your recovery progress."
    )
}

struct ExerciseReportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Exercise Summary")
                .font(.title)
                .fontWeight(.bold)
            
            if let report = appState.currentReport {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        HeaderSection(exerciseName: report.exerciseName, date: report.timestamp)
                        
                        ExerciseStats(
                            duration: report.duration,
                            exercise: appState.currentExercise ?? Exercise(id: report.exerciseId, name: report.exerciseName, description: report.description, targetAreas: "", reps: report.repetitions, videoUrl: ""),
                            completed: report.completed,
                            setsCompleted: 1,
                            repsCompleted: report.repetitions
                        )
                        
                        if !report.feedback.isEmpty {
                            DetailRow(title: "Feedback", content: report.feedback)
                        }
                        
                        if !report.notes.isEmpty {
                            DetailRow(title: "Notes", content: report.notes)
                        }
                        
                        DetailRow(title: "Summary", content: report.summary)
                        
                        if let patientId = appState.patientId {
                            GeneratePTReportButton(
                                patientId: patientId,
                                exerciseId: report.exerciseId
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding()
            } else {
                Text("No report available")
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                dismiss()
                appState.showExerciseDetail = false
            }) {
                Text("Done")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct FeedbackSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            Text(content)
                .padding(.vertical, 5)
            Divider()
        }
    }
}

// MARK: - Supporting Views
struct HeaderSection: View {
    let exerciseName: String
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(exerciseName) Report")
                .font(.title)
                .bold()
            Text(date.formatted())
                .foregroundColor(.secondary)
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct DetailRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ExerciseStats: View {
    let duration: TimeInterval
    let exercise: Exercise
    let completed: Bool
    let setsCompleted: Int
    let repsCompleted: Int
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise Statistics")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(title: "Duration", value: formattedDuration)
                StatItem(title: "Sets", value: "\(setsCompleted)")
                StatItem(title: "Reps", value: "\(repsCompleted)")
            }
            
            HStack {
                Text("Completion:")
                Text(completed ? "Completed" : "Partial")
                    .foregroundColor(completed ? .green : .orange)
                    .fontWeight(.semibold)
            }
            .padding(.top, 4)
            
            Divider()
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
        }
    }
}

struct ProgressBoardSection: View {
    let dayStreak: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Progress Board")
                .font(.headline)
            
            HStack {
                VStack {
                    Text("\(dayStreak)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Day Streak")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.orange)
                    Text("Consistency")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("🏔️")
                        .font(.largeTitle)
                    Text("Goal Tracking")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            Divider()
        }
    }
}

struct MotivationalMessageSection: View {
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Motivation")
                .font(.headline)
            Text(message)
                .foregroundColor(.secondary)
                .italic()
            Divider()
        }
    }
}

struct GeneratePTReportButton: View {
    let patientId: String
    let exerciseId: String
    @State private var showingPTReportAlert = false
    @State private var isGenerating = false
    @State private var reportGenerated = false
    @State private var reportError: String? = nil
    @EnvironmentObject private var voiceManager: VoiceManager
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                showingPTReportAlert = true
            }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Generate PT Visit Report")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .foregroundColor(.blue)
            }
            .disabled(isGenerating)
            
            if isGenerating {
                ProgressView("Generating report...")
                    .padding(.top, 5)
            }
            
            if reportGenerated {
                Text("Report generated successfully!")
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(.top, 5)
            }
            
            if let error = reportError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
                    .multilineTextAlignment(.center)
            }
        }
        .alert(isPresented: $showingPTReportAlert) {
            Alert(
                title: Text("Generate PT Report"),
                message: Text("This will generate a comprehensive report based on your exercise session. Would you like to proceed?"),
                primaryButton: .default(Text("Generate")) {
                    generatePTReport()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func generatePTReport() {
        isGenerating = true
        reportGenerated = false
        reportError = nil
        
        // Get conversation history
        let conversationHistory = voiceManager.getConversationHistory()
        
        if conversationHistory.isEmpty {
            reportError = "No exercise session data available.\nPlease complete an exercise session first."
            isGenerating = false
            return
        }
        
        // Call the server API
        ServerAPI().generatePTReport(
            patientId: patientId,
            exerciseId: exerciseId,
            conversationHistory: conversationHistory
        ) { result in
            DispatchQueue.main.async {
                isGenerating = false
                
                switch result {
                case .success(let response):
                    if let status = response["status"] as? String,
                       status == "success",
                       let report = response["report"] as? [String: Any] {
                        
                        reportGenerated = true
                        
                        // Create feedback data
                        let feedbackData = ExerciseFeedbackData(
                            generalFeeling: report["general_feeling"] as? String ?? "No feeling data provided",
                            performanceQuality: report["performance_quality"] as? String ?? "No quality data provided",
                            painReport: report["pain_report"] as? String ?? "No pain data provided",
                            completed: report["completed"] as? Bool ?? true,
                            setsCompleted: report["sets_completed"] as? Int ?? 0,
                            repsCompleted: report["reps_completed"] as? Int ?? 0,
                            dayStreak: report["day_streak"] as? Int ?? 1,
                            motivationalMessage: report["motivational_message"] as? String ?? "Great job with your exercise today!"
                        )
                        
                        // Save the feedback data
                        if let encodedData = try? JSONEncoder().encode(feedbackData) {
                            UserDefaults.standard.set(encodedData, forKey: "LastExerciseFeedback")
                            
                            // Post notification to update UI
                            NotificationCenter.default.post(
                                name: Notification.Name("ExerciseFeedbackAvailable"),
                                object: nil,
                                userInfo: ["feedback": feedbackData]
                            )
                        }
                        
                    } else if let error = response["error"] as? String {
                        reportError = "Server error: \(error)"
                    } else {
                        reportError = "Unexpected server response"
                    }
                    
                case .failure(let error):
                    reportError = "Failed to generate report: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct CongratulationsOverlay: View {
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // You can implement a simple animation here
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
                    .scaleEffect(1.5)
                    .opacity(0.9)
                
                Text("Fantastic Work!")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                
                Text("Your exercise is complete!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete()
            }
        }
    }
}

// MARK: - Integration with Exercise Coach Agent
extension VoiceManager {
    func recordExerciseFeedback(feedbackData: [String: Any]) {
        guard let exerciseId = feedbackData["exercise_id"] as? String,
              let exerciseName = feedbackData["exercise_name"] as? String,
              let description = feedbackData["description"] as? String,
              let duration = feedbackData["duration"] as? TimeInterval,
              let repetitions = feedbackData["repetitions"] as? Int else {
            print("Error: Missing required feedback data")
            return
        }
        
        let report = ExerciseReport(
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            description: description,
            duration: duration,
            repetitions: repetitions,
            completed: feedbackData["completed"] as? Bool ?? true,
            notes: feedbackData["notes"] as? String ?? "",
            feedback: feedbackData["feedback"] as? String ?? "",
            score: feedbackData["score"] as? Int ?? 0,
            summary: feedbackData["summary"] as? String ?? ""
        )
        
        // Post notification that feedback is available
        NotificationCenter.default.post(
            name: Notification.Name("ExerciseFeedbackAvailable"),
            object: nil,
            userInfo: ["report": report]
        )
    }
}

// Helper to present the ExerciseReportView
extension View {
    func showExerciseReport() -> some View {
        self.sheet(isPresented: .constant(true)) {
            ExerciseReportView()
        }
    }
}

// Usage in your ExerciseDetailView
extension ExerciseDetailView {
    func presentExerciseReport(duration: TimeInterval) {
        // Check if feedback data is available
        var feedbackData: ExerciseFeedbackData? = nil
        
        if let storedFeedback = UserDefaults.standard.data(forKey: "LastExerciseFeedback"),
           let decodedFeedback = try? JSONDecoder().decode(ExerciseFeedbackData.self, from: storedFeedback) {
            feedbackData = decodedFeedback
        }
        
        // Present the report view
        let reportView = ExerciseReportView(
            exercise: exercise,
            duration: duration,
            feedbackData: feedbackData
        )
        
        // Use UIKit to present the view modally
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            let hostingController = UIHostingController(rootView: reportView)
            hostingController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            rootViewController.present(hostingController, animated: true)
        }
    }
}
