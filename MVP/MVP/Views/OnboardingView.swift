import SwiftUI
import AVKit
import ElevenLabsSDK

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceManager: VoiceManager
    @Environment(\EnvironmentValues.dismiss) private var dismiss
    
    @State private var animationState: AnimationState = .idle
    
    var body: some View {
        VStack {
            DogAnimation(state: $animationState)
                .frame(height: 200)
                .padding()
            
            if let exercise = appState.currentExercise {
                Text(exercise.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(exercise.description)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let videoId = exercise.videoId {
                    VideoPlayer(player: AVPlayer(url: URL(string: "https://your-video-url/\(videoId)")!))
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Button(action: startExercise) {
                    Text("Start Exercise")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                ProgressView("Loading exercise...")
            }
        }
        .padding()
        .onAppear {
            setupVoiceAgent()
        }
        .onDisappear {
            if voiceManager.isSessionActive {
                voiceManager.endElevenLabsSession()
            }
        }
        .onChange(of: voiceManager.isSpeaking) { isSpeaking in
            withAnimation {
                animationState = isSpeaking ? .speaking : .idle
            }
        }
        .onChange(of: voiceManager.isListening) { isListening in
            withAnimation {
                if isListening && !voiceManager.isSpeaking {
                    animationState = .listening
                } else if !isListening && !voiceManager.isSpeaking {
                    animationState = .idle
                }
            }
        }
    }
    
    private func setupVoiceAgent() {
        voiceManager.currentAgentType = .onboarding
        voiceManager.startSession()
    }
    
    private func startExercise() {
        guard appState.currentExercise != nil else { return }
        appState.showExerciseDetail = true
        dismiss()
    }
}

// Preview provider
#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(VoiceManager(appState: AppState()))
}
