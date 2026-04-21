//
//  PokemonGenusEntity.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

@Model
final class PokemonGenusEntity {
    var genus: String
    var languageCode: String
    
    init(genus: String, languageCode: String) {
        self.genus = genus
        self.languageCode = languageCode
    }
}
