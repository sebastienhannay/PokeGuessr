//
//  PokemonFlavorTextEntity.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftData

@Model
final class PokemonFlavorTextEntity : LanguageTagged {
    var text: String
    var languageCode: String
    var versionName: String
    
    init(text: String, languageCode: String, versionName: String) {
        self.text = text
        self.languageCode = languageCode
        self.versionName = versionName
    }
}
