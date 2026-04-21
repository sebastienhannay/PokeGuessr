//
//  PokemonStatEntity.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

@Model
final class PokemonStatEntity {
    var name: String
    var value: Int
    
    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}
