//
//  PokeComparator.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 20/04/2026.
//

import Foundation

struct PokeComparator {

    func matchName(_ candidate: String, for pokemon: Pokemon) -> Bool {
        let candidate = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        if candidate.isEmpty {
            return false
        }
        return acceptedNames(for: pokemon).contains { $0.compare(candidate, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }
    }

    private func acceptedNames(for pokemon: Pokemon) -> Set<String> {
        let languages = preferredPokeAPILanguageCodes()
        return Set(
            (pokemon.formSpecificNames + pokemon.names)
                .filter { languages.contains($0.languageCode.lowercased()) }
                .map(\.name)
        )
    }

    private func preferredPokeAPILanguageCodes() -> Set<String> {
        var codes = PokeAPILanguages.supportedCodes(for: .autoupdatingCurrent)
        codes.insert("en")
        return codes
    }
}
