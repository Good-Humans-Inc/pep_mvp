import SwiftUI
import AVFoundation
import SDWebImageSwiftUI

struct ExerciseDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var cameraManager: CameraManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCameraSetup = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var exerciseStartTime: Date?
    @State private var showingReport = false
    @State private var currentInstructionIndex = 0
    
    var body: some View {
        VStack {
            if let exercise = appState.currentExercise {
                ScrollView {
                    VStack(spacing: 20) {
                        Text(exercise.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        if let imageURL = exercise.imageURL {
                            WebImage(url: imageURL)
                                .resizable()
                                .indicator(.activity)
                                .transition(.fade(duration: 0.5))
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        }
                        
                        // Camera preview
                        CameraPreviewView()
                            .frame(height: 300)
                            .cornerRadius(10)
                            .padding()
                        
                        // Exercise info
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Description:")
                                .font(.headline)
                            Text(exercise.description)
                            
                            Text("Target Joints:")
                                .font(.headline)
                            Text(exercise.targetJoints.map { $0.rawValue.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", "))
                            
                            Text("Instructions:")
                                .font(.headline)
                            ForEach(exercise.instructions.indices, id: \.self) { index in
                                HStack(alignment: .top) {
                                    Text("\(index + 1).")
                                        .foregroundColor(.blue)
                                    Text(exercise.instructions[index])
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding()
                        
                        Button(action: finishExercise) {
                            Text("Finish Exercise")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                ProgressView("Loading exercise...")
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            setupExercise()
        }
        .onDisappear {
            cleanup()
        }
        .sheet(isPresented: $showingReport) {
            if let report = generateReport() {
                ExerciseReportView(report: report)
            }
        }
    }
    
    private func setupExercise() {
        exerciseStartTime = Date()
        voiceManager.currentAgentType = .exerciseCoach
        voiceManager.startSession()
        cameraManager.startSession()
    }
    
    private func cleanup() {
        voiceManager.endElevenLabsSession()
        cameraManager.stopSession()
    }
    
    private func finishExercise() {
        showingReport = true
    }
    
    private func generateReport() -> ExerciseReport? {
        guard let exercise = appState.currentExercise,
              let startTime = exerciseStartTime else { return nil }
        
        let duration = Date().timeIntervalSince(startTime)
        
        return ExerciseReport(
            exerciseId: exercise.id.uuidString,
            exerciseName: exercise.name,
            description: exercise.description,
            duration: duration
        )
    }
}

#Preview {
    ExerciseDetailView()
        .environmentObject(AppState())
        .environmentObject(VoiceManager(appState: AppState()))
        .environmentObject(CameraManager(appState: AppState(), visionManager: VisionManager(appState: AppState())))
}
