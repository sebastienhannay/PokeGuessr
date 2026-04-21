//
//  PokemonFormDTO.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 20/04/2026.
//

import Foundation

struct PokemonFormDTO: Codable {
    let id: Int
    let name: String
    let order: Int
    let formOrder: Int

    let isDefault: Bool
    let isBattleOnly: Bool
    let isMega: Bool

    let names: [LocalizedName]
}
