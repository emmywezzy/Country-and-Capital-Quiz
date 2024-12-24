//
//  ConfettiView.swift
//  CapitalQuiz
//
//  Created by Emmanuel Yusuf on 2024-10-06.
//

// ConfettiView.swift
import SwiftUI

struct ConfettiView: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50) { index in
                Circle()
                    .foregroundColor(randomColor())
                    .frame(width: 10, height: 10)
                    .position(x: CGFloat.random(in: 0...geometry.size.width),
                              y: isAnimating ? geometry.size.height + 50 : -50)
                    .animation(
                        Animation.linear(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...2)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    func randomColor() -> Color {
        let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange]
        return colors.randomElement() ?? .white
    }
}
