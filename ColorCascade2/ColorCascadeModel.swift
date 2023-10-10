import Foundation
import UIKit

protocol ColorCascadeModelDelegate: AnyObject {
    func gameDidUpdate(score: Int, combo: Int)
    func gameDidEnd()
}

class ColorCascadeModel {
    
    weak var delegate: ColorCascadeModelDelegate?
    
    private var score: Int = 0
    private var combo: Int = 0
    
    private var currentColorIndex: Int = 0
    
    private let colorOptions: [UIColor] = [.red, .yellow, .blue, .purple, .orange, .green]
    
    private var timer: Timer?
    
    init() {
        // Start the game timer
        startGameTimer()
    }
    
    private func startGameTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dropColor), userInfo: nil, repeats: true)
    }
    
    @objc private func dropColor() {
        // Randomly select a color to drop
        let randomIndex = Int.random(in: 0..<colorOptions.count)
        currentColorIndex = randomIndex
        
        // Notify the delegate to update the falling color
        delegate?.gameDidUpdate(score: score, combo: combo)
    }
    
    private func determineRequiredColors(for shapeColor: UIColor) -> [UIColor] {
        switch shapeColor {
        case .purple:
            // For a purple shape, require red and blue to be clicked
            return [.red, .blue]
        case .orange:
            // For an orange shape, require red and yellow to be clicked
            return [.red, .yellow]
        case .green:
            // For a green shape, require yellow and blue to be clicked
            return [.yellow, .blue]
        // Add cases for other shape colors and their required combinations...
        case .red:
            
            return [.red]
            
        case .blue:
            
            return [.blue]
            
        case .yellow:
            
            return [.yellow]
            
        default:
            // For unknown or unexpected colors, return an empty array
            return []
        }
    }
    
    public func isMatchingColor(_ tappedColor: UIColor, _ currentFallingShapeColor: UIColor) -> Bool {
        let requiredColors = determineRequiredColors(for: currentFallingShapeColor)
        return requiredColors.contains(tappedColor)
    }


    
    func didSelectColor(at index: Int) {
        // Check if the selected color matches the current falling color
        if index == currentColorIndex {
            // Correct color selected
            score += 1
            combo += 1
        } else {
            // Incorrect color selected, end the game
            endGame()
            return
        }
        
        // Notify the delegate to update the score and combo
        delegate?.gameDidUpdate(score: score, combo: combo)
        
        // Restart the game timer for the next color drop
        timer?.invalidate()
        startGameTimer()
    }
    
    func gameDidUpdate(score: Int, combo: Int) {
        // Update game state only if the game is active

    }

    func gameDidEnd(score: Int) {
        // Handle game over logic here
    }
    
    public func endGame() {
        // Stop the game timer
        timer?.invalidate()
        
        // Notify the delegate that the game has ended
        delegate?.gameDidEnd()
        
        // Reset the score and combo
        score = 0
        combo = 0
    }
    
    func startGame() {
        // Start a new game by dropping the first color
        dropColor()
    }
}
