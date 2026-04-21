//
//  PokemonViewModel.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import Foundation
import SwiftData
import Combine
import AVFoundation

@MainActor
final class SilhouetteViewModel: ObservableObject {
    
    @Published var pokemon: Pokemon?
    @Published var isLoading = false
    @Published var guessedName: String = ""
    @Published var isRevealed: Bool = false
    @Published var wrongAttempts: Int = 0
    
    private var context: ModelContext?
    private let client = PokeAPIClient()
    private var player: AVPlayer?
    
    var isMissingNo: Bool {
        return pokemon?.id == -1
    }
    
    func configure(context: ModelContext) {
        if self.context == nil {
            self.context = context
        }
    }
    
    func loadPokemon(id: Int) async {
        guard let context else { return }
        
        isLoading = true
        
        do {
            let descriptor = FetchDescriptor<Pokemon>(
                predicate: #Predicate { $0.id == id }
            )
            
            if let cached = try context.fetch(descriptor).first {
                self.pokemon = cached
                isLoading = false
                return
            }
            
            let fetched = try await client.getPokemon(id: id, in: context)
            self.pokemon = fetched
            
        } catch {
            self.pokemon = Pokemon.missingNo
        }
        
        isLoading = false
    }
    
    func update(from gameStat: PokeGameStatDay?) {
        isRevealed = isMissingNo || gameStat?.silhouetteFound ?? false
        let attempts = gameStat?.silhouetteAttempts ?? 0
        wrongAttempts = attempts - (isRevealed ? 1 : 0)
    }
    
    private var notificationTask: Task<Void, Never>?
    
    func validate(name: String, gameStat: inout PokeGameStatDay?) -> Bool {
        guard !name.isEmpty, !isRevealed, let pokemon else { return false }
        
        gameStat?.silhouetteAttempts += 1
        
        if PokeComparator().matchName(name, for: pokemon) {
            gameStat?.silhouetteFound = true
            isRevealed = true
            
            // schedule next notifications only if user correctly identify the pokemon (+ ask persmission)
            notificationTask?.cancel()
                    
            notificationTask = Task {
                try? await Task.sleep (nanoseconds: 2 * NSEC_PER_SEC)
                if Task.isCancelled { return }
                
                await PokeNotificationManager.shared.requestPermissionAndSchedule()
            }
        } else {
            guessedName = ""
            
            // the user interact with pokemon but today's notification not triggered yet -> cancel it
            Task {
                await PokeNotificationManager.shared.cancelToday()
            }
        }
        
        update(from: gameStat)
        return isRevealed
    }
    
    func playCry() {
        if let cryPath = pokemon?.cries?.latest,
           let cryUrl = URL(string: cryPath) {
            player = AVPlayer(url: cryUrl)
            player?.play()
        }
    }
}
