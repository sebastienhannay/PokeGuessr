//
//  PokemonText.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftUI

struct PokemonText: View {
    let text: LocalizedStringKey
    var fontSize: CGFloat = 32
    
    init(_ text: LocalizedStringKey, fontSize: CGFloat = 32) {
        self.text = text
        self.fontSize = fontSize
    }

    var body: some View {
        Text(text)
            .font(.custom("Pokemon Solid", size: fontSize, relativeTo: .title))
            .foregroundStyle(.font)
            .textBorder(color: .border, fontSize: fontSize)
            .tracking(fontSize / 5)
    }
}

private extension Text {

    func textBorder(color: Color, fontSize: CGFloat) -> some View {
        let maxOffset = fontSize / 30
        let step: CGFloat = maxOffset / 2
        let angles: [CGFloat] = Array(stride(from: 0, to: 360, by: 45))

        return Array(stride(from: step, through: maxOffset, by: step))
            .reduce(AnyView(self)) { view, radius in
                angles.reduce(view) { innerView, angle in
                    let rad = angle * .pi / 180
                    return AnyView(
                        innerView.shadow(
                            color: color,
                            radius: 0.2,
                            x: cos(rad) * radius,
                            y: sin(rad) * radius
                        )
                    )
                }
            }
    }

}

#Preview {
    PokemonText("Pokémon", fontSize: 32)
    PokemonText("Pokémon", fontSize: 128)
}
