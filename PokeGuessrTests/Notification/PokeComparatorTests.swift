//
//  PokeComparatorTests.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 20/04/2026.
//


import Testing
@testable import PokeGuessr

// MARK: - Test Doubles

private func makePokemon(
    names: [(name: String, languageCode: String)] = [],
    formSpecificNames: [(name: String, languageCode: String)] = []
) -> Pokemon {
    let pokemon = Pokemon(
        id: 0,
        name: "test",
        height: 0,
        weight: 0,
        baseExperience: nil,
        isLegendary: false,
        isMythical: false,
        isBaby: false,
        captureRate: 0,
        baseHappiness: 0,
        evolutionChainURL: ""
    )
    pokemon.names = names.map { PokemonNameEntity(name: $0.name, languageCode: $0.languageCode) }
    pokemon.formSpecificNames = formSpecificNames.map { PokemonNameEntity(name: $0.name, languageCode: $0.languageCode) }
    return pokemon
}

// MARK: - PokeComparator Tests

@Suite("PokeComparator")
struct PokeComparatorTests {
    
    @Suite("matchName(for:)")
    struct MatchName {
        
        let sut = PokeComparator()
        
        @Test("Exact name matches")
        func exactMatch() {
            let pikachu = makePokemon(names: [("Pikachu", "en")])
            #expect(sut.matchName("Pikachu", for: pikachu))
        }
        
        @Test("Wrong name is rejected")
        func wrongNameRejected() {
            let pikachu = makePokemon(names: [("Pikachu", "en")])
            #expect(!sut.matchName("Raichu", for: pikachu))
        }
        
        // MARK: - Case insensitivity
        
        @Test("Matching is case-insensitive", arguments: ["pikachu", "PIKACHU", "PiKaChU", "pikACHU"])
        func caseInsensitiveMatch(candidate: String) {
            let pikachu = makePokemon(names: [("Pikachu", "en")])
            #expect(sut.matchName(candidate, for: pikachu))
        }
        
        // MARK: - Diacritic insensitivity
        
        @Test("Flabébé matches without accents")
        func diacriticInsensitiveMatch() {
            let flabebe = makePokemon(names: [("Flabébé", "en")])
            #expect(sut.matchName("Flabebe", for: flabebe))
        }
        
        @Test("Candidate with diacritics matches stored plain name")
        func diacriticsInCandidateMatchPlainStored() {
            let pokemon = makePokemon(names: [("Flabebe", "en")])
            #expect(sut.matchName("Flabébé", for: pokemon))
        }
        
        @Test("Case and diacritics are both ignored simultaneously")
        func caseAndDiacriticInsensitiveCombined() {
            let flabebe = makePokemon(names: [("Flabébé", "en")])
            #expect(sut.matchName("FLABEBE", for: flabebe))
            #expect(sut.matchName("flabébé", for: flabebe))
            #expect(sut.matchName("FLABÉBÉ", for: flabebe))
        }
        
        // MARK: - Normalized insensitivity
        @Test("Normalized name matches")
        func normalizedMatch() {
            let pikachu = makePokemon(names: [("Pikachu", "en")])
            #expect(sut.matchName(" Pikachu  \n", for: pikachu))
        }
        
        // MARK: - Empty candidate guard
        
        @Test("Empty candidate always returns false without consulting names")
        func emptyStringReturnsFalseImmediately() {
            let pokemon = makePokemon(names: [("", "en"), ("Pikachu", "en")])
            #expect(!sut.matchName("", for: pokemon))
        }
        
        // MARK: - Language filtering still applies
        
        @Test("Name in unsupported language is rejected")
        func unsupportedLanguageRejected() {
            let pokemon = makePokemon(names: [("Ghost", "xx")])
            #expect(!sut.matchName("ghost", for: pokemon))
            #expect(!sut.matchName("Ghost", for: pokemon))
        }
        
        @Test("Language code lookup is case-insensitive")
        func languageCodeCaseInsensitive() {
            let pikachu = makePokemon(names: [("Pikachu", "EN")])
            #expect(sut.matchName("pikachu", for: pikachu))
        }
        
        // MARK: - Form-specific names
        
        @Test("Form-specific name matches case-insensitively")
        func formSpecificNameCaseInsensitive() {
            let rotom = makePokemon(formSpecificNames: [("Rotom-Wash", "en")])
            #expect(sut.matchName("rotom-wash", for: rotom))
            #expect(sut.matchName("ROTOM-WASH", for: rotom))
        }
        
        @Test("Both name and form-specific name matches case-insensitively")
        func bothNameCaseInsensitive() {
            let rotom = makePokemon(
                names: [("Rotom", "en")],
                formSpecificNames: [("Rotom-Wash", "en")]
            )
            #expect(sut.matchName("rotom", for: rotom))
            #expect(sut.matchName("ROTOM", for: rotom))
            #expect(sut.matchName("rotom-wash", for: rotom))
            #expect(sut.matchName("ROTOM-WASH", for: rotom))
        }
        
        // MARK: - Nameless Pokémon
        
        @Test("Pokémon with no names never matches")
        func namelessPokemonNeverMatches() {
            let missingNo = makePokemon()
            #expect(!sut.matchName("MissingNo", for: missingNo))
        }
    }
}
