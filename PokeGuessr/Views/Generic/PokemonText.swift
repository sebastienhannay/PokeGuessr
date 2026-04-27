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
            .stroke(color: .border, width: fontSize * 0.06)
            .tracking(fontSize / 5)
    }
}

struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue

    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }

    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .padding(strokeSize * 2)
            .background(
                Rectangle()
                    .foregroundColor(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
            )
            .compositingGroup()
    }

    func mask(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            if let resolvedView = context.resolveSymbol(id: id) {
                context.draw(resolvedView, at: .init(x: size.width * 0.5, y: size.height * 0.5))
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize)
        }
    }
}


private extension View {
    
    func stroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }

}

#Preview {
    PokemonText("Pokémon", fontSize: 32)
    PokemonText("C'est Insolourdo !", fontSize: 128)
        .lineLimit(2)
        .multilineTextAlignment(.center)
}
