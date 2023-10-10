import AVFoundation

class SoundManager {
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        configureAudioPlayer()
    }
    
    private func configureAudioPlayer() {
        // Get the URL of the background music file
        if let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            do {
                // Initialize the audio player with the music file
                audioPlayer = try AVAudioPlayer(contentsOf: musicURL)
                
                // Configure audio player settings
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.volume = 0.5 // Adjust the volume as needed
            } catch {
                print("Error initializing audio player: \(error.localizedDescription)")
            }
        }
    }
    
    func playBackgroundMusic() {
        audioPlayer?.play()
    }
    
    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
