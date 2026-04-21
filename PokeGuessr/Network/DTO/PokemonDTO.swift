//
//  PokemonDTO.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import Foundation

struct PokemonDTO: Codable {
    let id: Int
    let name: String
    let baseExperience: Int?
    let height: Int
    let weight: Int
    let isDefault: Bool
    let order: Int
    
    let species: NamedAPIResource
    
    let abilities: [PokemonAbility]
    let forms: [NamedAPIResource]
    let gameIndices: [GameIndex]
    let heldItems: [PokemonHeldItem]
    let locationAreaEncounters: String
    
    let moves: [PokemonMove]
    let stats: [PokemonStat]
    let types: [PokemonType]
    
    let sprites: PokemonSpritesRoot
    let cries: PokemonCries
}

struct PokemonCries: Codable {
    let latest: String
    let legacy: String?
}

struct PokemonSpritesRoot: Codable {
    let frontDefault: String?
    let frontShiny: String?
    let frontFemale: String?
    let frontShinyFemale: String?
    
    let backDefault: String?
    let backShiny: String?
    let backFemale: String?
    let backShinyFemale: String?
    
    let other: OtherSprites?
    let versions: VersionSprites?
}

struct PokemonSprites: Codable {
    let frontDefault: String?
    let frontShiny: String?
    let frontFemale: String?
    let frontShinyFemale: String?
    
    let backDefault: String?
    let backShiny: String?
    let backFemale: String?
    let backShinyFemale: String?
}

struct OtherSprites: Codable {
    let officialArtwork: PokemonSprites?
    let dreamWorld: PokemonSprites?
    let home: PokemonSprites?
    
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
        case dreamWorld
        case home
    }
}

struct VersionSprites: Codable {
    let generations: [String: GenerationSprites]?
}

struct GenerationSprites: Codable {
    let versions: [String: PokemonSprites]?
}

struct PokemonAbility: Codable {
    let isHidden: Bool
    let slot: Int
    let ability: NamedAPIResource
}

struct PokemonType: Codable {
    let slot: Int
    let type: NamedAPIResource
}

struct PokemonStat: Codable {
    let baseStat: Int
    let effort: Int
    let stat: NamedAPIResource
}

struct PokemonMove: Codable {
    let move: NamedAPIResource
    let versionGroupDetails: [MoveVersionDetail]
}

struct MoveVersionDetail: Codable {
    let levelLearnedAt: Int
    let moveLearnMethod: NamedAPIResource
    let versionGroup: NamedAPIResource
}

struct PokemonHeldItem: Codable {
    let item: NamedAPIResource
    let versionDetails: [HeldItemVersion]
}

struct HeldItemVersion: Codable {
    let rarity: Int
    let version: NamedAPIResource
}

struct GameIndex: Codable {
    let gameIndex: Int
    let version: NamedAPIResource
}
