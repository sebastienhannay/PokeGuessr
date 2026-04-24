//
//  SpriteStyle.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 22/04/2026.
//

import SwiftUI

extension Image {
    
    func spriteStyle(
        isRevealed: Bool = false,
        pokeballVisible: Bool = false,
        isPressed: Bool = false,
        ratio: CGFloat = 0.7
    ) -> some View {
        GeometryReader { geo in
            let base = min(geo.size.width, geo.size.height)

            let shadowRadius = base * (isPressed ? 0.002 : 0.004)
            let shadowX = base * (isPressed ? -0.008 : -0.012)
            let shadowY = base * (isPressed ? 0.005 : 0.009)

            self
                .renderingMode(!pokeballVisible && isRevealed ? .original : .template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(pokeballVisible ? .clear : .unknown)
                .frame(width: geo.size.width * ratio,
                       height: geo.size.height * ratio)
                .shadow(
                    color: .black.opacity(0.5),
                    radius: shadowRadius,
                    x: shadowX,
                    y: shadowY
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(pokeballVisible ? 0.5 : 1)
                .scaleEffect(isPressed ? 0.92 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.5),
                           value: isPressed)
                .animation(.spring(response: 0.4, dampingFraction: 0.6),
                           value: pokeballVisible)
        }
    }
}
