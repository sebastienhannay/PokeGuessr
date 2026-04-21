//
//  PokemonNameEntity.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

@Model
final class PokemonNameEntity : LanguageTagged {
    var name: String
    var languageCode: String
    
    init(name: String, languageCode: String) {
        self.name = name
        self.languageCode = languageCode
    }
}
