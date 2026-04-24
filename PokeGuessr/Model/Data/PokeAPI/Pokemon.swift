//
//  Item.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import Foundation
import SwiftData

@Model
final class Pokemon {
    @Attribute(.unique) var id: Int
    
    var name: String
    var height: Int
    var weight: Int
    var baseExperience: Int?
    
    // Species flags
    var isLegendary: Bool
    var isMythical: Bool
    var isBaby: Bool
    
    var captureRate: Int
    var baseHappiness: Int
    
    var evolutionChainURL: String
    
    // Relationships
    
    @Relationship(deleteRule: .cascade)
    var stats: [PokemonStatEntity]
    
    @Relationship(deleteRule: .cascade)
    var abilities: [PokemonAbilityEntity]
    
    @Relationship(deleteRule: .cascade)
    var types: [PokemonTypeEntity]
    
    @Relationship(deleteRule: .cascade)
    var names: [PokemonNameEntity]
    
    @Relationship(deleteRule: .cascade)
    var formSpecificNames: [PokemonNameEntity]
    
    @Relationship(deleteRule: .cascade)
    var genera: [PokemonGenusEntity]
    
    @Relationship(deleteRule: .cascade)
    var flavorTexts: [PokemonFlavorTextEntity]
    
    @Relationship(deleteRule: .cascade)
    var sprites: PokemonSpritesEntity?
    
    @Relationship(deleteRule: .cascade)
    var cries: PokemonCriesEntity?
    
    var artwork : URL? {
        guard let path = sprites?.officialArtwork ??
                sprites?.homeDefault ??
                sprites?.frontDefault
        else {
            return nil
        }
        return URL(string: path)
    }
    
    init(
        id: Int,
        name: String,
        height: Int,
        weight: Int,
        baseExperience: Int?,
        isLegendary: Bool,
        isMythical: Bool,
        isBaby: Bool,
        captureRate: Int,
        baseHappiness: Int,
        evolutionChainURL: String
    ) {
        self.id = id
        self.name = name
        self.height = height
        self.weight = weight
        self.baseExperience = baseExperience
        self.isLegendary = isLegendary
        self.isMythical = isMythical
        self.isBaby = isBaby
        self.captureRate = captureRate
        self.baseHappiness = baseHappiness
        self.evolutionChainURL = evolutionChainURL
        
        self.stats = []
        self.abilities = []
        self.types = []
        self.names = []
        self.formSpecificNames = []
        self.genera = []
        self.flavorTexts = []
    }
}

extension Pokemon {

    var localizedDescription: String? {
        localizedEntry(in: flavorTexts, value: \.text)
    }

    var localizedName: String {
        localizedEntry(in: formSpecificNames, value: \.name)
            ?? localizedEntry(in: names, value: \.name)
            ?? name
    }
    
    private static let pokeAPILanguages = PokeAPILanguages()

    private func localizedEntry<E, V>(in entries: [E], value: KeyPath<E, V>) -> V?
    where E: LanguageTagged {
        let codes = PokeAPILanguages.supportedCodes(for: .autoupdatingCurrent)
        return (entries.first(where: { codes.contains($0.languageCode.lowercased()) })
             ?? entries.first(where: { $0.languageCode.lowercased() == "en" }))
            .map { $0[keyPath: value] }
    }
}

extension Pokemon {
    static var missingNo: Pokemon {
        let p = Pokemon(
            id: -1,
            name: "MissingNo",
            height: 0,
            weight: 0,
            baseExperience: nil,
            isLegendary: false,
            isMythical: false,
            isBaby: false,
            captureRate: 0,
            baseHappiness: 0,
            evolutionChainURL: ""
        )
        p.stats = []
        p.abilities = []
        p.types = []
        p.names = [
            PokemonNameEntity(name: "MissingNo", languageCode: "en")
        ]
        p.genera = []
        p.flavorTexts = []
        p.sprites = nil
        p.cries = nil
        return p
    }
    
    static var pikachu: Pokemon {
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
        
        return pokemon
    }
}


extension Pokemon {
    
    static func fetchExisting(id: Int, in context: ModelContext) throws -> Pokemon? {
        let descriptor = FetchDescriptor<Pokemon>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }
    
}
