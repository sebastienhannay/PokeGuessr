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
}

extension ModelContainer {
        
    static var preview: ModelContainer {
        let container = inMemory
        insertPreviewData(into: container.mainContext)
        return container
    }

    // MARK: - Preview Data

    private static func insertPreviewData(into context: ModelContext) {
        context.insert(Pokemon.pikachu)
    }
}
