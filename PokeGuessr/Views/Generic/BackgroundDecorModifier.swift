//
//  RedBackgroundDecorModifier.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 15/04/2026.
//


import SwiftUI

struct BackgroundDecorModifier: ViewModifier {
    let backgroundColor: Color
    let angle: Double = 18
    let count: Int = 120

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geo in
                    ZStack {
                        backgroundColor

                        ForEach(0..<count, id: \.self) { i in
                            streak(in: geo.size, index: i)
                        }
                    }
                }
            }
            .ignoresSafeArea()
    }

    private func streak(in size: CGSize, index: Int) -> some View {
        let seed = Double(index)

        // pseudo-random but stable distribution
        let x = (sin(seed * 12.9898) * 43758.5453).truncatingRemainder(dividingBy: 1).magnitude
        let y = (sin(seed * 78.233) * 12345.6789).truncatingRemainder(dividingBy: 1).magnitude

        let width = 80 + (sin(seed * 3.1) * 0.5 + 0.5) * 220
        let height = 6 + (sin(seed * 5.7) * 0.5 + 0.5) * 10

        let opacity = 0.06 + (sin(seed * 9.3) * 0.5 + 0.5) * 0.12

        return RoundedRectangle(cornerRadius: 999)
            .fill(Color.white.opacity(opacity))
            .frame(width: width, height: height)
            .rotationEffect(.degrees(angle))
            .position(
                x: CGFloat(x) * size.width,
                y: CGFloat(y) * size.height
            )
    }
}

extension View {
    func backgroundDecor(_ color: Color) -> some View {
        self.modifier(BackgroundDecorModifier(backgroundColor: color))
    }
}
