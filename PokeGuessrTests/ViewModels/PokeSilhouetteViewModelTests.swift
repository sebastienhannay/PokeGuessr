//
//  PokeSilhouetteViewModelTests.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 24/04/2026.
//


//
//  PokeSilhouetteViewModelTests.swift
//  PokeGuessrTests
//

import Testing
import Foundation
@testable import PokeGuessr

// MARK: - Tests

@Suite("PokeSilhouetteViewModel")
@MainActor
struct PokeSilhouetteViewModelTests {
    
    private func makeSUT() -> PokeSilhouetteViewModel {
        PokeSilhouetteViewModel()
    }

    @Test("isMissingNo is true only when pokemon id is -1")
    func isMissingNo() {
        let sut = makeSUT()

        sut.pokemon = Pokemon.pikachu
        #expect(sut.isMissingNo == false)

        sut.pokemon = Pokemon.missingNo
        #expect(sut.isMissingNo == true)
    }

    @Test("update(from:) sets isRevealed and wrongAttempts from gameStat")
    func updateFromGameStat() {
        let sut = makeSUT()
        sut.pokemon = Pokemon.pikachu

        // Not yet found: 3 attempts, none successful
        let stat = PokeGameStatDay()
        stat.silhouetteAttempts = 3
        stat.silhouetteFound = false
        sut.update(from: stat)

        #expect(sut.isRevealed == false)
        #expect(sut.wrongAttempts == 3)

        // Found: 4th attempt was correct → wrongAttempts excludes the winning guess
        stat.silhouetteAttempts = 4
        stat.silhouetteFound = true
        sut.update(from: stat)

        #expect(sut.isRevealed == true)
        #expect(sut.wrongAttempts == 3) // 4 attempts - 1 correct
    }

    @Test("update(from:) forces isRevealed when pokemon is MissingNo")
    func updateForcesRevealForMissingNo() {
        let sut = makeSUT()
        sut.pokemon = Pokemon.missingNo

        sut.update(from: nil)

        #expect(sut.isRevealed == true)
    }

    @Test("validate returns false and is a no-op for empty name, already revealed, or no pokemon")
    func validateGuards() {
        let sut = makeSUT()
        sut.pokemon = Pokemon.pikachu
        var stat: PokeGameStatDay? = PokeGameStatDay()

        // Empty name
        #expect(sut.validate(name: "", gameStat: &stat) == false)

        // Already revealed
        sut.isRevealed = true
        #expect(sut.validate(name: "pikachu", gameStat: &stat) == false)

        // No pokemon
        sut.isRevealed = false
        sut.pokemon = nil
        #expect(sut.validate(name: "pikachu", gameStat: &stat) == false)
    }

    @Test("validate increments attempts and reveals on correct name")
    func validateCorrectGuess() {
        let sut = makeSUT()
        sut.pokemon = Pokemon.pikachu
        var stat: PokeGameStatDay? = PokeGameStatDay()

        let result = sut.validate(name: "pikachu", gameStat: &stat)

        #expect(result == true)
        #expect(sut.isRevealed == true)
        #expect(stat?.silhouetteFound == true)
        #expect(stat?.silhouetteAttempts == 1)
    }

    @Test("validate increments attempts and clears guessedName on wrong name")
    func validateWrongGuess() {
        let sut = makeSUT()
        sut.pokemon = Pokemon.pikachu
        sut.guessedName = "ronflex"
        var stat: PokeGameStatDay? = PokeGameStatDay()

        let result = sut.validate(name: "ronflex", gameStat: &stat)

        #expect(result == false)
        #expect(sut.isRevealed == false)
        #expect(sut.guessedName == "")
        #expect(stat?.silhouetteFound == false)
        #expect(stat?.silhouetteAttempts == 1)
    }
}
