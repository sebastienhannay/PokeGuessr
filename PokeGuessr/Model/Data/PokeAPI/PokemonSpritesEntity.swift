//
//  PokemonSpritesEntity.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

@Model
final class PokemonSpritesEntity {
    
    // Default sprites
    var frontDefault: String?
    var frontShiny: String?
    var backDefault: String?
    var backShiny: String?
    
    // Artwork
    var officialArtwork: String?
    var officialArtworkShiny: String?
    
    // Home sprites
    var homeDefault: String?
    var homeShiny: String?
    
    // Dream world
    var dreamWorld: String?
    
    init(
        frontDefault: String?,
        frontShiny: String?,
        backDefault: String?,
        backShiny: String?,
        officialArtwork: String?,
        officialArtworkShiny: String?,
        homeDefault: String?,
        homeShiny: String?,
        dreamWorld: String?
    ) {
        self.frontDefault = frontDefault
        self.frontShiny = frontShiny
        self.backDefault = backDefault
        self.backShiny = backShiny
        self.officialArtwork = officialArtwork
        self.officialArtworkShiny = officialArtworkShiny
        self.homeDefault = homeDefault
        self.homeShiny = homeShiny
        self.dreamWorld = dreamWorld
    }
}
