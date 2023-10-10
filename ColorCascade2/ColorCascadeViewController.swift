import UIKit
import AVFoundation
import SpriteKit


class ColorCascadeViewController: UIViewController, ColorCascadeModelDelegate {
    
    private var model: ColorCascadeModel!
    private var soundManager: SoundManager!
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    private var fallingShapeView: UIView!
    private var colorOptions: [UIView] = []
    private var scoreLabel: UILabel!
    private var comboLabel: UILabel!
    private var bottomColorView: UIView!
    private var startButton: UIButton!
    private var isGameActive: Bool = false
    private var shapeTapped: Bool = false
    



    // Array of possible colors for falling shapes
    private let shapeColors: [UIColor] = [.red, .green, .blue]
    
    // Property to store the current falling shape color
    private var currentFallingShapeColor: UIColor = .clear
    
    private var score: Int = 0
    private var combo: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupModel()
        setupSoundManager()
    }
    private func setupSoundManager() {
        soundManager = SoundManager()// Load the sound effect for a correct color match
    }


    private func setupUI() {
        view.backgroundColor = .white
        
        // Create and configure the falling shape view
        let shapeSize: CGFloat = 50
        fallingShapeView = UIView()
        fallingShapeView.frame = CGRect(x: (view.bounds.width - shapeSize) / 2, y: -shapeSize, width: shapeSize, height: shapeSize)
        fallingShapeView.backgroundColor = shapeColors.randomElement() ?? .clear
        fallingShapeView.layer.cornerRadius = shapeSize / 2
        fallingShapeView.clipsToBounds = true
        view.addSubview(fallingShapeView)
        
        // Create color option views
        for color in shapeColors {
            let optionView = UIView()
            optionView.backgroundColor = color
            optionView.layer.cornerRadius = shapeSize / 2
            optionView.clipsToBounds = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(colorOptionTapped(_:)))
            optionView.addGestureRecognizer(tapGesture)
            view.addSubview(optionView)
            colorOptions.append(optionView)
        }
        
        scoreLabel = UILabel()
        scoreLabel.textColor = .black
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(scoreLabel)
        
        comboLabel = UILabel()
        comboLabel.textColor = .black
        comboLabel.textAlignment = .center
        comboLabel.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(comboLabel)
        
        bottomColorView = UIView()
        bottomColorView.layer.cornerRadius = shapeSize / 2
        bottomColorView.clipsToBounds = true
        view.addSubview(bottomColorView)
        
        startButton = UIButton(type: .system)
        startButton.setTitle("Start Game", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
       
        
    
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Get the view dimensions
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height

        // Define the shape size and spacing
        let shapeSize: CGFloat = 50
        let spacing: CGFloat = 20

        // Calculate the total width required for the shapes and spacing
        let totalWidth = (shapeSize * CGFloat(colorOptions.count)) + (spacing * CGFloat(colorOptions.count - 1))

        // Calculate the starting x-position to center the shapes
        let startX = (viewWidth - totalWidth) / 2

        // Position and size the color options
        for (index, optionView) in colorOptions.enumerated() {
            let xPosition = startX + (shapeSize + spacing) * CGFloat(index)
            optionView.frame = CGRect(x: xPosition, y: viewHeight - shapeSize - 60, width: shapeSize, height: shapeSize)
        }

        // Rest of your layout code remains the same
        scoreLabel.frame = CGRect(x: 10, y: 70, width: viewWidth - 20, height: 30)
        comboLabel.frame = CGRect(x: 10, y: 100, width: viewWidth - 20, height: 30)
        bottomColorView.frame = CGRect(x: viewWidth - shapeSize, y: viewHeight - shapeSize, width: shapeSize, height: shapeSize)
        startButton.frame = CGRect(x: (viewWidth - 120) / 2, y: viewHeight - 100, width: 120, height: 40)
    }

    
    private func startFallingAnimation() {
        let shapeSize: CGFloat = 50
        fallingShapeView.frame.origin.y = -shapeSize

        // Randomly select a color for the falling shape
        currentFallingShapeColor = shapeColors.randomElement() ?? .clear
        fallingShapeView.backgroundColor = currentFallingShapeColor

        UIView.animate(withDuration: 2.0, delay: 0, options: .curveLinear, animations: { [weak self] in
            guard let self = self else { return }
            self.fallingShapeView.frame.origin.y = self.view.bounds.height
        }) { [weak self] (_) in
            // Handle shape reaching the bottom or game logic here
            self?.shapeReachedBottom()
        }
    }

    private func shapeReachedBottom() {
        // Check if the game is still active and a shape has not been tapped
        if isGameActive && !shapeTapped {
            // Handle the case when the shape reaches the bottom without being tapped
            combo = 0 // Reset the combo (you can adjust this logic as needed)
            endGame() // End the game if a shape reaches the bottom without being tapped
        } else {
            // Reset the shapeTapped flag
            shapeTapped = false
        }
    }

    private func setupModel() {
        model = ColorCascadeModel()
        model.delegate = self
    }
    
    public func endGame() {
        isGameActive = false
        // Implement any additional logic for ending the game here
        model.endGame() // Notify the model that the game has ended
        score = 0
        combo = 0
    }
    
    // Handle the start button tap
    @objc private func startButtonTapped() {
        startButton.isHidden = true
        isGameActive = true
        startFallingAnimation()
        model.startGame()
    }
    
    // Handle color option tap
    @objc public func colorOptionTapped(_ sender: UITapGestureRecognizer) {
        guard isGameActive else { return } // Ignore taps if the game is not active

        guard let index = colorOptions.firstIndex(of: sender.view!) else { return }
        let tappedColor = shapeColors[index]

        if tappedColor == currentFallingShapeColor {
            // Handle a correct color match (e.g., update score and combo)
            score += 1
            combo += 1

            shapeTapped = true


        } else {
            // Handle an incorrect color match (if needed)
            combo = 0
            endGame()
        }

        // Update UI labels
        scoreLabel.text = "Score: \(score)"
        comboLabel.text = "Combo x\(combo)"

        startFallingAnimation()
    }
    
    // MARK: - ColorCascadeModelDelegate
    
    func gameDidUpdate(score: Int, combo: Int) {
        // This method can be left empty if you don't have specific game update logic here
    }
    
    func gameDidEnd() {
        let alert = UIAlertController(title: "Game Over", message: "Your Score: \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.startButton.isHidden = false
        }))
        present(alert, animated: true, completion: nil)
    }
    
}
