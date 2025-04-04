import SwiftUI
import Combine

class AppState: ObservableObject {
    // MARK: - Published Properties
    @Published var isOnboardingComplete: Bool = false
    @Published var patientId: String? = nil
    @Published var exercises: [Exercise] = []
    @Published var currentExercise: Exercise?
    @Published var currentReport: ExerciseReport?
    @Published var showExerciseDetail = false
    @Published var isExerciseActive: Bool = false
    
    // MARK: - Camera State
    struct CameraState {
        var isSessionRunning: Bool = false
        var isCameraAuthorized: Bool = false
        var cameraError: String?
    }
    @Published var cameraState = CameraState()
    
    init() {
        // Load example exercise for testing
        if exercises.isEmpty {
            self.currentExercise = Exercise.examples.first
        }
    }
    
    // MARK: - Exercise Management
    func setCurrentExercise(_ exercise: Exercise) {
        currentExercise = exercise
        showExerciseDetail = true
    }
    
    func completeExercise(with report: ExerciseReport) {
        currentReport = report
        isExerciseActive = false
        showExerciseDetail = false
    }
}
