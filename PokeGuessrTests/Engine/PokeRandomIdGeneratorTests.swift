//
//  PokeRandomIdGeneratorTests.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 20/04/2026.
//


import Testing
import Foundation
@testable import PokeGuessr

// MARK: - Test Suite

@Suite("PokeRandomIdGenerator")
struct PokeRandomIdGeneratorTests {

    // ─────────────────────────────────────────────
    // MARK: selectableIds
    // ─────────────────────────────────────────────

    @Suite("selectableIds(for:at:)")
    struct SelectableIds {

        let sut = PokeRandomIdGenerator()

        @Test("Returns base pool for all modes before the April-21 cutoff")
        func basePoolBeforeCutoff() {
            let before = Date.on(year: 2026, month: 4, day: 20)

            for mode in PokeGameMode.allCases {
                let ids = sut.selectableIds(for: mode, at: before)
                #expect(ids == Array(1...1025),
                        "Expected only 1–1025 for \(mode) before cutoff")
            }
        }

        @Test("Silhouette mode gains extended pool on/after April-21 2026")
        func silhouetteModeGainsExtendedPool() {
            let after = Date.on(year: 2026, month: 4, day: 21)
            let ids = sut.selectableIds(for: .silhouette, at: after)

            #expect(ids.contains(10001))
            #expect(ids.contains(10325))
            #expect(ids.count == 1294,
                    "Expected 1025 base + 269 extended = 1294 ids")
        }

        /*@Test("Non-silhouette modes do NOT gain the extended pool after cutoff")
        func otherModesUnaffectedAfterCutoff() {
            let after = Date.on(year: 2026, month: 4, day: 21)
            let excludedModes = PokeGameMode.allCases.filter { $0 != .silhouette }

            for mode in excludedModes {
                let ids = sut.selectableIds(for: mode, at: after)
                #expect(!ids.contains(10001),
                        "\(mode) should not include extended IDs")
                #expect(ids.count == 1025)
            }
        }*/

        @Test("Returns empty for a date before any entry")
        func returnsEmptyForVeryEarlyDate() {
            let ancient = Date(timeIntervalSinceReferenceDate: -1)
            let ids = sut.selectableIds(for: .silhouette, at: ancient)
            #expect(ids.isEmpty)
        }

        @Test("Result contains no duplicates")
        func noDuplicatesInPool() {
            let after = Date.on(year: 2026, month: 4, day: 22)
            for mode in PokeGameMode.allCases {
                let ids = sut.selectableIds(for: mode, at: after)
                #expect(ids.count == Set(ids).count, "Duplicates found for \(mode)")
            }
        }
    }

    // ─────────────────────────────────────────────
    // MARK: daily(for:at:)
    // ─────────────────────────────────────────────

    @Suite("daily(for:at:)")
    struct Daily {

        let sut = PokeRandomIdGenerator()

        @Test("Same date always returns the same Pokémon")
        func deterministic() {
            let date = Date.on(year: 2025, month: 8, day: 14)
            let first  = sut.daily(for: .silhouette, at: date)
            let second = sut.daily(for: .silhouette, at: date)
            #expect(first == second)
        }

        @Test("Different dates return different Pokémon (statistically)")
        func differsByDate() {
            let dates = (0..<7).map { Date.on(year: 2025, month: 1, day: 1 + $0) }
            let results = dates.map { sut.daily(for: .silhouette, at: $0) }
            let unique = Set(results)
            #expect(unique.count > 1, "All daily picks were identical across a week")
        }

        @Test("Result is always within the selectable pool for that date")
        func resultInPool() {
            let dates = [
                Date.on(year: 2025, month: 3, day: 15),
                Date.on(year: 2026, month: 4, day: 22),
                Date.on(year: 2027, month: 12, day: 31),
            ]

            for date in dates {
                for mode in PokeGameMode.allCases {
                    let pool = sut.selectableIds(for: mode, at: date)
                    guard !pool.isEmpty else { continue }
                    let pick = sut.daily(for: mode, at: date)
                    #expect(pool.contains(pick),
                            "\(pick) not in pool for \(mode) on \(date)")
                }
            }
        }

        @Test("Returns valid ID even on year-boundary (Dec 31 → Jan 1)")
        func yearBoundary() {
            let dec31 = Date.on(year: 2025, month: 12, day: 31)
            let jan1  = Date.on(year: 2026, month:  1, day:  1)

            let pool = sut.selectableIds(for: .silhouette, at: jan1)
            let pickDec = sut.daily(for: .silhouette, at: dec31)
            let pickJan = sut.daily(for: .silhouette, at: jan1)

            #expect(pool.contains(pickDec))
            #expect(pool.contains(pickJan))
            #expect(pickDec != pickJan, "Year boundary should produce a different daily")
        }

        @Test("Index arithmetic never goes out-of-bounds (spot-check 365 days)")
        func noOutOfBoundsOver365Days() {
            let start = Date.on(year: 2025, month: 1, day: 1)
            for day in 0..<365 {
                let date = start.addingTimeInterval(Double(day) * 86_400)
                for mode in PokeGameMode.allCases {
                    let pool = sut.selectableIds(for: mode, at: date)
                    guard !pool.isEmpty else { continue }
                    let pick = sut.daily(for: mode, at: date)
                    #expect(pool.contains(pick))
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // MARK: random(for:)
    // ─────────────────────────────────────────────

    @Suite("random(for:)")
    struct Random {

        let sut = PokeRandomIdGenerator()

        @Test("Returns a value within the current selectable pool")
        func resultInCurrentPool() {
            for mode in PokeGameMode.allCases {
                let pick = sut.random(for: mode)
                let pool = sut.selectableIds(for: mode)
                #expect(pool.contains(pick),
                        "\(pick) not in pool for mode \(mode)")
            }
        }

        @Test("Produces variance across many calls (not stuck on one value)")
        func producesVariance() {
            let picks = Set((0..<50).map { _ in sut.random(for: .silhouette) })
            #expect(picks.count > 1, "random() returned the same value 50 times in a row")
        }
    }
}
