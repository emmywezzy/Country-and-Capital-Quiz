// ContentView.swift
import SwiftUI
import AVFoundation

struct ContentView: View {
    @AppStorage("highScore") private var highScore = 0
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("difficultyLevel") private var difficultyLevel = "Normal"
    
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var lives = 5
    @State private var isGameOver = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var feedbackMessage = ""
    @State private var showConfetti = false
    @State private var livesAnimation = false
    
    let feedbackMessages = [
        "Don't give up! Try again to beat your score.",
        "Great effort! Practice makes perfect.",
        "Keep going! You'll get it next time.",
        "Nice try! Challenge yourself to improve.",
        "Well played! See if you can score higher."
    ]
    
    init() {
        _questions = State(initialValue: generateSampleData(difficulty: difficultyLevel).shuffled())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Game Title
                    Text("Capital Quiz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    // Score and Lives or High Score
                    HStack {
                        Text("Score: \(score)")
                        Spacer()
                        Text("High Score: \(highScore)")
                    }
                    .font(.headline)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                    .animation(.easeInOut, value: score)
                    
                    // Lives Icons
                    HStack(spacing: 5) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < lives ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .scaleEffect(livesAnimation && index == lives ? 1.5 : 1.0)
                                .opacity(livesAnimation && index == lives ? 0.0 : 1.0)
                                .animation(.easeInOut(duration: 0.5), value: livesAnimation)
                        }
                    }
                    .onChange(of: livesAnimation) { newValue in
                        if livesAnimation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                livesAnimation = false
                            }
                        }
                    }
                    
                    ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                        .padding(.horizontal)
                    
                    if !isGameOver {
                        if currentQuestionIndex < questions.count {
                            let currentQuestion = questions[currentQuestionIndex]
                            Text("What is the capital of \(currentQuestion.country)?")
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding()
                                .foregroundColor(.white)
                            
                            ForEach(currentQuestion.options, id: \.self) { option in
                                AnimatedButton(option: option) {
                                    self.optionTapped(option)
                                }
                            }
                        }
                    } else {
                        // Game Over Screen
                        ZStack {
                            VStack {
                                Spacer()
                                Text("Game Over!")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .padding()
                                
                                Text("Your final score is \(score).")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                
                                Text("High Score: \(highScore)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                
                                // Feedback Message
                                Text(feedbackMessage)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: restartQuiz) {
                                    Text("Restart Quiz")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.green)
                                        )
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                                Spacer()
                            }
                            
                            if showConfetti {
                                ConfettiView()
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), dismissButton: .default(Text("OK"), action: {
                    if isGameOver {
                        // Do nothing, the game over screen will be displayed
                    } else {
                        nextQuestion()
                    }
                }))
            }
            .onChange(of: difficultyLevel) { newDifficulty in
                questions = generateSampleData(difficulty: newDifficulty).shuffled()
                restartQuiz()
            }
        }
    }
    
    func optionTapped(_ selectedOption: String) {
        let currentQuestion = questions[currentQuestionIndex]
        if selectedOption == currentQuestion.capital {
            score += 1
            alertTitle = "Correct!"
            playSound("correct")
        } else {
            lives -= 1
            livesAnimation = true
            alertTitle = "Wrong! The correct answer is \(currentQuestion.capital)."
            playSound("wrong")
        }
        
        if lives <= 0 || currentQuestionIndex == questions.count - 1 {
            if score > highScore {
                highScore = score
                showConfetti = true
            }
            isGameOver = true
            feedbackMessage = feedbackMessages.randomElement() ?? ""
            playSound("game_over")
        }
        showingAlert = true
    }
    
    func nextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex == questions.count {
            if score > highScore {
                highScore = score
                showConfetti = true
            }
            isGameOver = true
            feedbackMessage = feedbackMessages.randomElement() ?? ""
            playSound("game_over")
        }
    }
    
    func restartQuiz() {
        if score > highScore {
            highScore = score
        }
        showConfetti = false
        score = 0
        lives = 5
        currentQuestionIndex = 0
        questions.shuffle()
        isGameOver = false
    }
    
    func playSound(_ soundName: String) {
        if soundEnabled {
            if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
                var player: AVAudioPlayer?
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.play()
                } catch {
                    print("Error playing sound.")
                }
            }
        }
    }
}

struct AnimatedButton: View {
    let option: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(option)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                )
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .scaleEffect(self.isPressed ? 0.95 : 1.0)
        .animation(.spring(), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in self.isPressed = true })
                .onEnded({ _ in self.isPressed = false })
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
