//
//  PokemonView.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import AVFoundation
import SwiftUI
import SwiftData
import SDWebImageSwiftUI

private enum AnimationPhase {
    case pokeballEntering
    case pokeballExiting
    case contentVisible
}

struct PokeSilhouetteView: View {
    
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModel: PokeSilhouetteViewModel

    @State private var animationPhase: AnimationPhase = .pokeballEntering
    
    @Binding var gameStat: PokeGameStatDay?
    
    var pokemonId: Int
    
    init(pokemonId: Int, gameStat: Binding<PokeGameStatDay?>, viewModel: PokeSilhouetteViewModel? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel ?? PokeSilhouetteViewModel())
        self.pokemonId = pokemonId
        self._gameStat = gameStat
    }
    
    private var shouldPlayCry: Bool {
        
        viewModel.isRevealed && animationPhase == .contentVisible
    }
    
    var body: some View {
        ZStack {
            pokemonZone
            fieldZone
        }
        .frame(maxHeight: .infinity)
        .task {
            viewModel.configure(context: context)
            viewModel.update(from: gameStat)
            await viewModel.loadPokemon(id: pokemonId)
            viewModel.update(from: gameStat)
        }
        .onChange(of: gameStat) { _, newValue in
            viewModel.update(from: newValue)
        }
        .onChange(of: shouldPlayCry) {_, newValue in
            if newValue {
                viewModel.playCry()
            }
        }
    }
    
    private var pokemonZone: some View {
        VStack {
            PokemonText("pokemonView.whosThatPokemon", fontSize: 32)
                .shadow(color: .black.opacity(0.5),
                        radius: 1,
                        x: -5,
                        y: 3)
                .scaleEffect(animationPhase == .contentVisible ? 1 : 1.5)
                .opacity(animationPhase == .contentVisible ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.2), value: animationPhase)
            
            pokemonSilhouette
            
            Group {
                if !viewModel.isRevealed {
                    PokemonText("pokemonView.interrogationMark", fontSize: 48)
                } else {
                    PokemonText("pokemonView.its.\(viewModel.pokemon?.localizedName ?? "")!", fontSize: 48)
                }
            }
            .shadow(color: .black.opacity(0.5),
                    radius: 1,
                    x: -5,
                    y: 3)
            .scaleEffect(animationPhase == .contentVisible ? 1 : 1.5)
            .opacity(animationPhase == .contentVisible ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.4), value: animationPhase)
            .transition(.fade)
            .animation(.easeInOut(duration: 0.4), value: viewModel.isRevealed)
        }
        .multilineTextAlignment(.center)
        .lineLimit(2, reservesSpace: true)
        .minimumScaleFactor(0.5)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundDecor(.redBackground)
        .ignoresSafeArea(.keyboard)
    }
    
    
    @State private var isPokemonPressed = false
    
    private var pokemonSilhouette: some View {
        ZStack {
            Group {
                TimelineView(.periodic(from: .now, by: 0.2)) { _ in
                    ZStack {
                        SunburstView(color: .sunburstBack, lineCount: 72, lineWidth: 64, minLengthPercent: 0.4, maxLengthPercent: 0.5)
                        SunburstView(color: .white, lineCount: 42, lineWidth: 28, minLengthPercent: 0.35, maxLengthPercent: 0.45)
                    }
                }
                .opacity(animationPhase == .contentVisible ? 1 : 0)
                
                if viewModel.isMissingNo {
                    Image("MissingNo")
                        .spriteStyle(
                            isRevealed: viewModel.isRevealed,
                            pokeballVisible: animationPhase != .contentVisible,
                            isPressed: isPokemonPressed
                        )
                } else {
                    WebImage(url: URL(string: viewModel.pokemon?.sprites?.officialArtwork ?? "")) { image in
                        image
                            .spriteStyle(
                                isRevealed: viewModel.isRevealed,
                                pokeballVisible: animationPhase != .contentVisible,
                                isPressed: isPokemonPressed
                            )
                    } placeholder: {
                        EmptyView()
                    }
                    .indicator(.activity)
                }
            }
            .onTapGesture {
                guard viewModel.isRevealed && animationPhase == .contentVisible else { return }

                isPokemonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPokemonPressed = false
                }

                viewModel.playCry()
            }
            
            pokeball
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var fieldZone: some View {
        VStack {
            Spacer()
            
            if viewModel.isMissingNo {
                if animationPhase == .contentVisible {
                    Text("error.missing.try.later")
                    .multilineTextAlignment(.center)
                    .padding()
                    .glassEffect()
                    .opacity(viewModel.isRevealed ? 1 : 0)
                }
            } else {
                if viewModel.pokemon != nil && !viewModel.isRevealed {
                    TextField("pokemonView.textField.placeholder", text: $viewModel.guessedName)
                        .padding()
                        .disableAutocorrection(true)
                        .glassEffect()
                        .modifier(ShakeEffect(animatableData: CGFloat(viewModel.wrongAttempts)))
                        .padding()
                        .onSubmit {
                            withAnimation {
                                let _ = viewModel.validate(name: viewModel.guessedName, gameStat: &gameStat)
                            }
                        }
                }
            }
        }
    }
    
    var pokeball: some View {
        Group {
            if animationPhase != .contentVisible {
                GeometryReader { geo in
                    let startX = geo.size.width - geo.size.width / 2
                    let startY = geo.size.height - geo.size.height / 2
                    
                    Image("pokeball")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(animationPhase != .pokeballEntering ? 0 : -20))
                        .scaleEffect(animationPhase != .pokeballEntering ? 0.5 : 1)
                        .modifier(ArcMotionEffect(
                            progress: animationPhase != .pokeballEntering ? 1 : 0,
                            startX: startX,
                            startY: startY
                        ))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                animationPhase = .pokeballExiting
                            } completion: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    animationPhase = .contentVisible
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview("Normal") {
    @Previewable @State var gameStat = Optional(PokeGameStatDay())
    PokeSilhouetteView(pokemonId: 25, gameStat: $gameStat)
        .modelContainer(.preview)
}

#Preview("Regional form") {
    @Previewable @State var gameStat = Optional(PokeGameStatDay())
    PokeSilhouetteView(pokemonId: 10167, gameStat: $gameStat)
        .modelContainer(.preview)
}

#Preview("MissingNo") {
    @Previewable @State var gameStat = Optional(PokeGameStatDay())
    let vm = PokeSilhouetteViewModel()
    vm.pokemon = Pokemon.missingNo
    vm.update(from: gameStat)
    return PokeSilhouetteView(pokemonId: -1, gameStat: $gameStat, viewModel: vm)
        .modelContainer(.preview)
}

#Preview("Already solved") {
    @Previewable @State var gameStat: PokeGameStatDay? = {
        var stat = PokeGameStatDay()
        stat.silhouetteFound = true
        stat.silhouetteAttempts = 3
        return stat
    }()
    PokeSilhouetteView(pokemonId: 25, gameStat: $gameStat)
        .modelContainer(.preview)
}
