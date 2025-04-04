import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("userId") private var userId: String?
    
    var body: some View {
        Group {
            if let _ = userId {
                // Returning user - go directly to exercise
                ExerciseDetailView()
            } else {
                // New user - go to onboarding
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

