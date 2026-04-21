//
//  PokemonSpeciesDTO.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import Foundation

struct PokemonSpeciesDTO: Codable {
    let id: Int
    let name: String
    let order: Int
    
    let names: [LocalizedName]
    let genera: [Genus]
    let flavorTextEntries: [FlavorTextEntry]
    
    let color: NamedAPIResource
    let shape: NamedAPIResource?
    let habitat: NamedAPIResource?
    
    let isLegendary: Bool
    let isMythical: Bool
    let isBaby: Bool
    
    let genderRate: Int
    let captureRate: Int
    let baseHappiness: Int
    
    let hatchCounter: Int
    
    let eggGroups: [NamedAPIResource]
    
    let evolutionChain: APIResource
    
    let varieties: [PokemonSpeciesVariety]
}

struct LocalizedName: Codable {
    let name: String
    let language: NamedAPIResource
}

struct FlavorTextEntry: Codable {
    let flavorText: String
    let language: NamedAPIResource
    let version: NamedAPIResource
}

struct Genus: Codable {
    let genus: String
    let language: NamedAPIResource
}

struct PokemonSpeciesVariety: Codable {
    let isDefault: Bool
    let pokemon: NamedAPIResource
}
