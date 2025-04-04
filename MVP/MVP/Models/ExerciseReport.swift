import Foundation

struct ExerciseReport: Codable {
    let exerciseId: String
    let exerciseName: String
    let description: String
    let duration: TimeInterval
    let completed: Bool
    let notes: String
    let feedback: String
    let score: Int
    let summary: String
    
    init(exerciseId: String,
         exerciseName: String,
         description: String,
         duration: TimeInterval,
         completed: Bool = true,
         notes: String = "",
         feedback: String = "Exercise completed successfully",
         score: Int = 100,
         summary: String = "You've completed the exercise session.") {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.description = description
        self.duration = duration
        self.completed = completed
        self.notes = notes
        self.feedback = feedback
        self.score = score
        self.summary = summary
    }
} 
