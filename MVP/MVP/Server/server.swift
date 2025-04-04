import Foundation

class ServerAPI {
    static let shared = ServerAPI()
    private let baseURL = "https://your-api-base-url.com"
    
    func processVoiceInput(audioData: Data, completion: @escaping (Result<Exercise, Error>) -> Void) {
        // Parse joint string to Joint enum
        func parseJoint(_ jointString: String) -> Joint? {
            switch jointString.lowercased() {
            case "knee":
                return .rightKnee // Default to right knee if side not specified
            case "hip":
                return .rightHip // Default to right hip if side not specified
            case "ankle":
                return .rightAnkle // Default to right ankle if side not specified
            default:
                return nil
            }
        }
        
        // Parse exercise data
        let id = UUID()
        let name = "Sample Exercise"
        let description = "Exercise description"
        let targetJoints: [Joint] = [.rightKnee, .rightAnkle] // Default joints
        let instructions = [
            "Step 1: Start position",
            "Step 2: Execute movement",
            "Step 3: Return to start"
        ]
        
        // Create exercise
        let exercise = Exercise(
            id: id,
            name: name,
            description: description,
            targetJoints: targetJoints,
            instructions: instructions
        )
        
        completion(.success(exercise))
    }
    
    func logExerciseSession(exerciseId: UUID, duration: TimeInterval, completed: Bool, notes: String = "") {
        guard let patientID = UserDefaults.standard.string(forKey: "PatientID") else { return }
        
        let url = URL(string: "\(baseURL)/api/log_exercise")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "patient_id": patientID,
            "exercise_id": exerciseId.uuidString,
            "duration": duration,
            "completed": completed,
            "notes": notes
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            // Handle response if needed
        }.resume()
    }
} 