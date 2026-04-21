//
//  PokemonAbilityEntity.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

@Model
final class PokemonAbilityEntity {
    var name: String
    var isHidden: Bool
    
    init(name: String, isHidden: Bool) {
        self.name = name
        self.isHidden = isHidden
    }
}
