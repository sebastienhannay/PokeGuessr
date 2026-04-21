//
//  ModelContainer+Utils.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

extension ModelContainer {

    // MARK: - Schema

    static let appSchema = Schema([
        PokeGameStatDay.self,
        Pokemon.self,
        PokemonStatEntity.self,
        PokemonTypeEntity.self,
        PokemonAbilityEntity.self,
        PokemonNameEntity.self,
        PokemonGenusEntity.self,
        PokemonFlavorTextEntity.self,
        PokemonSpritesEntity.self,
        PokemonCriesEntity.self
    ])

    // MARK: - Containers

    static let shared: ModelContainer = {
        let config = ModelConfiguration(schema: appSchema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: appSchema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static var inMemory: ModelContainer {
        let config = ModelConfiguration(schema: appSchema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: appSchema, configurations: [config])
        return container
    }
    
    static var preview: ModelContainer {
        let container = inMemory
        insertPreviewData(into: container.mainContext)
        return container
    }

    // MARK: - Preview Data

    private static func insertPreviewData(into context: ModelContext) {
        let pokemon = Pokemon(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            baseExperience: 112,
            isLegendary: false,
            isMythical: false,
            isBaby: false,
            captureRate: 190,
            baseHappiness: 70,
            evolutionChainURL: ""
        )

        pokemon.sprites = PokemonSpritesEntity(
            frontDefault: nil,
            frontShiny: nil,
            backDefault: nil,
            backShiny: nil,
            officialArtwork: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png",
            officialArtworkShiny: nil,
            homeDefault: nil,
            homeShiny: nil,
            dreamWorld: nil
        )

        pokemon.cries = PokemonCriesEntity(
            latest: "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/25.ogg",
            legacy: "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/legacy/25.ogg"
        )

        context.insert(pokemon)
    }
}
