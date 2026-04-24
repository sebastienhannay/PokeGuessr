//
//  RandomPokemonIdGenerator.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import Foundation

extension Date {
    static func on(year: Int, month: Int, day: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        c.hour = 0; c.minute = 0; c.second = 0; c.nanosecond = 0
        return Calendar.current.date(from: c)!
    }
}

struct PokeRandomIdGenerator {
        
    private var selectableIdsByDate: [(date: Date, gameMode: [PokeGameMode], ids: [Int])] = [
        // base pokemon
        (Date(timeIntervalSinceReferenceDate: 0), PokeGameMode.allCases, Array(1...1025)),
        // added pokemon forms and removing some too redundant + missing artwork
        (Date.on(year: 2026, month: 4, day: 21), [.silhouette], [
            10001...10026,
            10033...10079,
            10086...10092,
            10100...10127,
            10147...10181,
            10184...10254,
            10256...10256,
            10258...10259,
            10263...10263,
            10272...10317,
            10319...10321,
            10324...10325
        ].flatMap { $0 })
    ]
    
    func selectableIds(for mode: PokeGameMode, at date: Date = .now) -> [Int] {
        return Set(selectableIdsByDate
            .filter { $0.date <= date && $0.gameMode.contains(mode) }
            .flatMap { $0.ids }
        ).sorted()
    }
    
    private static let prime: Int = 1_000_003
    
    // MARK: - Fully Random
    func random(for mode: PokeGameMode) -> Int {
        return selectableIds(for: mode).randomElement() ?? -1
    }
    
    // MARK: - Daily Seed
    func daily(for mode: PokeGameMode, at date: Date = .now) -> Int {
        let selectableIds = selectableIds(for: mode, at: date)
        let dayNumber = Self.dayNumber(from: date)
        let index = (dayNumber * Self.prime) % selectableIds.count
        return selectableIds[index]
    }
    
    // MARK: - Private Helpers
    private static func dayNumber(from date: Date) -> Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month, .day], from: date)
        let y = components.year  ?? 0
        let m = components.month ?? 0
        let d = components.day   ?? 0
        return y * 10_000 + m * 100 + d
    }
}
