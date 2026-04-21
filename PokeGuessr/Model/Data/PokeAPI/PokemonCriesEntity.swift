//
//  PokemonCriesEntity.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

@Model
final class PokemonCriesEntity {
    var latest: String
    var legacy: String?
    
    init(latest: String, legacy: String?) {
        self.latest = latest
        self.legacy = legacy
    }
}
