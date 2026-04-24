//
//  DayCellView.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 23/04/2026.
//


import SwiftUI
import SDWebImageSwiftUI

struct PokeDayCellView: View {
    let cell: PokeCalendarDayCell
    let isSelected: Bool

    var body: some View {
        if !cell.isInCurrentMonth {
            Color.clear.aspectRatio(1, contentMode: .fit)
        } else if cell.isBeforeRange {
            PokemonText("\(cell.dayNumber)", fontSize: 14).opacity(0.5)
        } else {
            ZStack {
                if cell.isAfterRange {
                    Image("tall_grass")
                        .resizable()
                } else {
                    background
                }
                VStack { Spacer(); PokemonText("\(cell.dayNumber)", fontSize: 9) }
                if isSelected {
                    Circle().fill(.clear).stroke(.sunburstBack, lineWidth: 2)
                }
            }

            .opacity(cell.isAfterRange || cell.isBeforeRange ? 0.5 : 1)
        }
    }

    @ViewBuilder
    private var background: some View {
        if let pokemon = cell.pokemon, cell.isFound {
            ZStack {
                Circle().fill(.regularMaterial)
                WebImage(url: URL(string: pokemon.sprites?.officialArtwork ?? "")) { image in
                    image.spriteStyle(isRevealed: true, ratio: 1).shadow(radius: 5)
                } placeholder: { EmptyView() }
                .indicator(.activity)
            }
        } else if cell.pokemon != nil {
            Image("sun_fixed").resizable().aspectRatio(1, contentMode: .fit)
                .overlay {
                    GeometryReader { geo in
                        ZStack {
                            PokemonText("?", fontSize: geo.size.height * 0.8)
                                .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.8)
                                .lineLimit(1).minimumScaleFactor(0.1)
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
        } else {
            Image("pokeball").resizable().aspectRatio(1, contentMode: .fit)
        }
    }
}
