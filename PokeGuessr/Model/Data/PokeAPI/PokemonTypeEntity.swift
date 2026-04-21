//
//  PokemonTypeEntity.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

@Model
final class PokemonTypeEntity {
    var name: String
    var slot: Int
    
    init(name: String, slot: Int) {
        self.name = name
        self.slot = slot
    }
}
