import Foundation
import UIKit

protocol ColorCascadeModelDelegate: AnyObject {
    func gameDidUpdate(score: Int, combo: Int)
    func gameDidEnd()
}

class ColorCascadeModel {
    
    weak var delegate: ColorCascadeModelDelegate?
    
    private var score = 0
    private var combo = 0
    private var currentColorIndex = 0
    private var timer: Timer?
    public var selectedColors: Set<UIColor> = []

    public let shapeColors: [UIColor] = [.red, .yellow, .blue]
    
    public func startGame() {
        dropColor()
    }
    
    private func startGameTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dropColor), userInfo: nil, repeats: true)
    }
    
    @objc private func dropColor() {
        let randomIndex = Int.random(in: 0..<shapeColors.count)
        currentColorIndex = randomIndex
        delegate?.gameDidUpdate(score: score, combo: combo)
    }
    
    private func determineRequiredColors(for shapeColor: UIColor) -> [UIColor] {
        switch shapeColor {
        case .purple: 
            return [.red, .blue]
        case .orange: 
            return [.red, .yellow]
        case .green: 
            return [.yellow, .blue]
        case .red, .blue, .yellow: 
            return [shapeColor]
        default: return []
        }
    }
    
    public func isMatchingColor(_ tappedColor: UIColor, _ currentFallingShapeColor: UIColor) -> Bool {
        let requiredColors = determineRequiredColors(for: currentFallingShapeColor)
        selectedColors.insert(tappedColor)
        return selectedColors.isSuperset(of: requiredColors)
    }

    public func addSelectedColor(_ color: UIColor) {
        selectedColors.insert(color)
    }
    
    public func checkSelectedColors(for fallingShapeColor: UIColor) -> Bool {
        let requiredColors = determineRequiredColors(for: fallingShapeColor)
        let isMatching = selectedColors.isSuperset(of: requiredColors)
        selectedColors.removeAll()  // Reset selected colors for the next falling shape
        return isMatching
    }
    
    private func restartGameTimer() {
        timer?.invalidate()
        startGameTimer()
    }
    
    public func endGame() {
        timer?.invalidate()
        delegate?.gameDidEnd()
        resetGameStats()
    }
    
    private func resetGameStats() {
        score = 0
        combo = 0
    }
}
