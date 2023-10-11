import UIKit
import AVFoundation
import SpriteKit

class ColorCascadeViewController: UIViewController, ColorCascadeModelDelegate {

    private var model = ColorCascadeModel()
    private var soundManager = SoundManager()
    private var backgroundMusicPlayer: AVAudioPlayer?
    var currentAlertController: UIAlertController?
    var gracePeriodTimer: Timer?
    var fadeTimer: Timer?
    let fadeDuration: TimeInterval = 2.0  // Adjust the duration as needed



    private var baseShapeView = UIView()
    //private var fallingShapeView = FallingShapeView()
    private let shapeSize: CGFloat = 60
    private var fallingShapeView = UIView()
    private var colorOptions = [UIView]()
    private var fallingColorOptions: [UIColor] = [.red, .yellow, .blue]
    private var scoreLabel = UILabel()
    private var comboLabel = UILabel()
    private var bottomColorView = UIView()
    private var startButton = UIButton(type: .system)
    private var isGameActive: Bool = false
    private var shapeTapped: Bool = false
    public var currentFallingShapeColor: UIColor = .clear
    private var score: Int = 0
    private var combo: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        model.delegate = self
        soundManager = SoundManager()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupBaseShapeView()
        setupFallingShapeView()
        setupColorOptionViews()
        setupLabels()
        setupBottomColorView()
        setupStartButton()
    }
    
    private func setupBaseShapeView() {
            // Set the frame, background color, and rounding for the base shape view
            baseShapeView.frame = CGRect(x: (view.bounds.width - shapeSize) / 2,
                                         y: view.bounds.height - shapeSize - 20,
                                         width: shapeSize,
                                         height: shapeSize)
            baseShapeView.backgroundColor = .white  // Or any color you prefer
            baseShapeView.layer.cornerRadius = shapeSize / 2
            baseShapeView.clipsToBounds = true
            
            view.addSubview(baseShapeView)
        }
    
    private func setupFallingShapeView() {
            // Set the frame, initial background color, and rounding for the falling shape view
            fallingShapeView.frame = CGRect(x: (view.bounds.width - shapeSize) / 2,
                                            y: -shapeSize,
                                            width: shapeSize,
                                            height: shapeSize)
            fallingShapeView.backgroundColor = model.shapeColors.randomElement() ?? .clear
            fallingShapeView.layer.cornerRadius = shapeSize / 2
            fallingShapeView.clipsToBounds = true
            
            view.addSubview(fallingShapeView)
        }
    
    private func setupColorOptionViews() {
        for color in model.shapeColors {
            let optionView = createColorOptionView(color: color)
            view.addSubview(optionView)
            colorOptions.append(optionView)
        }
    }
    
    private func createColorOptionView(color: UIColor) -> UIView {
        let optionView = UIView()
        optionView.backgroundColor = color
        optionView.layer.cornerRadius = shapeSize / 2
        optionView.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(colorOptionTapped(_:)))
        optionView.addGestureRecognizer(tapGesture)
        return optionView
    }
    
    private func setupLabels() {
        setupLabel(label: scoreLabel, fontSize: 24)
        setupLabel(label: comboLabel, fontSize: 18)
    }
    
    private func setupLabel(label: UILabel, fontSize: CGFloat) {
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize)
        view.addSubview(label)
    }
    
    private func setupBottomColorView() {
        bottomColorView.layer.cornerRadius = shapeSize / 2
        bottomColorView.clipsToBounds = true
        view.addSubview(bottomColorView)
    }
    
    private func setupStartButton() {
        startButton.setTitle("Start Game", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutColorOptionViews()
        layoutLabels()
        layoutBottomColorView()
        layoutStartButton()
    }
    
    private func layoutColorOptionViews() {
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        let spacing: CGFloat = 20
        let totalWidth = (shapeSize * CGFloat(colorOptions.count)) + (spacing * CGFloat(colorOptions.count - 1))
        let startX = (viewWidth - totalWidth) / 2

        for (index, optionView) in colorOptions.enumerated() {
            let xPosition = startX + (shapeSize + spacing) * CGFloat(index)
            optionView.frame = CGRect(x: xPosition, y: viewHeight - shapeSize - 60, width: shapeSize, height: shapeSize)
        }
    }
    
    private func layoutLabels() {
        let viewWidth = view.bounds.width
        scoreLabel.frame = CGRect(x: 10, y: 70, width: viewWidth - 20, height: 30)
        comboLabel.frame = CGRect(x: 10, y: 100, width: viewWidth - 20, height: 30)
    }
    
    private func layoutBottomColorView() {
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        bottomColorView.frame = CGRect(x: viewWidth - shapeSize, y: viewHeight - shapeSize, width: shapeSize, height: shapeSize)
    }
    
    private func layoutStartButton() {
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        startButton.frame = CGRect(x: (viewWidth - 120) / 2, y: viewHeight / 2 , width: 120, height: 40)
    }
    
    @objc private func startButtonTapped() {
        startButton.isHidden = true
        isGameActive = true
        startFallingAnimation()
        model.startGame()
        
        playBackgroundMusic()  // Start the background music
        startFadeIn()

    }
    
    private func startFallingAnimation() {
        fallingShapeView.frame.origin.y = -shapeSize
        currentFallingShapeColor = fallingColorOptions.randomElement() ?? .clear
        fallingShapeView.backgroundColor = currentFallingShapeColor

        UIView.animate(withDuration: 2.0, delay: 0, options: .curveLinear, animations: { [weak self] in
            guard let self = self else { return }
            self.fallingShapeView.frame.origin.y = self.view.bounds.height
        }) { [weak self] (_) in
            self?.shapeReachedBottom()
        }
    }
    
    private func shapeReachedBottom() {
        if isGameActive && !shapeTapped {
            combo = 0
            endGame()
        } else {
            shapeTapped = false
        }
    }
    
    @objc public func colorOptionTapped(_ sender: UITapGestureRecognizer) {
        guard isGameActive else { return }
        guard let index = colorOptions.firstIndex(of: sender.view!) else { return }
        let tappedColor = model.shapeColors[index]
        
        model.addSelectedColor(tappedColor)
        
        if gracePeriodTimer == nil {
            gracePeriodTimer = Timer.scheduledTimer(
                timeInterval: 0.1,
                target: self,
                selector: #selector(gracePeriodExpired),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    @objc func gracePeriodExpired() {
        gracePeriodTimer = nil  // Reset the timer
        
        if model.checkSelectedColors(for: currentFallingShapeColor) {
            animatePop(for: fallingShapeView)  // Add this line to trigger the pop animation
            score += 1
            combo += 1
            shapeTapped = true
            if score > 5 && fallingColorOptions.count == 3 {
                fallingColorOptions += [.purple, .orange, .green]
            }
        } else {
            combo = 0
            fallingColorOptions = [.red, .yellow, .blue]
            endGame()
        }

        updateLabels()
        startFallingAnimation()
    }
    
    private func updateLabels() {
        scoreLabel.text = "Score: \(score)"
        comboLabel.text = "Combo x\(combo)"
    }
    
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Could not find background music file.")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1  // Loop the music indefinitely
            backgroundMusicPlayer?.volume = 0  // Set initial volume to 0
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch let error {
            print("Error loading or playing background music: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer?.currentTime = 0  // Reset the playback time to the beginning
    }
    
    func startFadeIn() {
        fadeTimer?.invalidate()  // Cancel any existing timer
        fadeTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(fadeIn), userInfo: nil, repeats: true)
    }


    @objc func fadeIn() {
        guard let player = backgroundMusicPlayer else { return }
        
        if player.volume < 1.0 {
            player.volume += Float(0.05 / (fadeDuration / 0.05))
        } else {
            fadeTimer?.invalidate()
        }
    }
    
    func animatePop(for view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform(scaleX: 2, y: 2)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                view.transform = CGAffineTransform.identity
            }
        }
    }
    
    public func endGame() {
        isGameActive = false
        model.endGame()
        score = 0
        combo = 0
        fallingColorOptions = [.red, .yellow, .blue]
        stopBackgroundMusic()  // Stop the background music
    }
    
    func gameDidUpdate(score: Int, combo: Int) {}
    
    func gameDidEnd() {
            // Dismiss the current alert controller if there is one
            currentAlertController?.dismiss(animated: false, completion: nil)
            
            let alert = UIAlertController(title: "Game Over", message: "Your Score: \(score)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.startButton.isHidden = false
            }))
            
            present(alert, animated: true, completion: nil)
            currentAlertController = alert
        }
}
