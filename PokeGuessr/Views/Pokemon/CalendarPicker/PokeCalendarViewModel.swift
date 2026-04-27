//
//  PokeCalendarViewModel.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 23/04/2026.
//

import SwiftUI
import Observation
import SwiftData
import SwiftDate

// MARK: – Joined day data
struct PokeDayData {
    let pokemon: Pokemon
    let statDay: PokeGameStatDay?
}

@Observable
final class PokeCalendarViewModel {

    // MARK: – State
    var selectedMonth: MonthYear
    var selectedDate: Date
    var showingMonthYearPicker = false

    // MARK: – Config
    let gameMode: PokeGameMode
    let dateRange: ClosedRange<Date>?

    // MARK: – Injected context
    private var context: ModelContext?

    // MARK: – Derived joined data
    private(set) var dayData: [String: PokeDayData] = [:]

    private let generator = PokeRandomIdGenerator()

    // MARK: – Init
    init(selectedDate: Date,
         dateRange: ClosedRange<Date>? = nil,
         gameMode: PokeGameMode = .silhouette) {
        self.selectedDate = selectedDate.dateAt(.startOfDay)
        self.selectedMonth = MonthYear(date: selectedDate)
        self.dateRange = dateRange
        self.gameMode = gameMode
    }

    func configure(context: ModelContext) {
        self.context = context
        rebuildDayData()
    }

    // MARK: – Derived
    var monthTitle: String {
        return selectedMonth.asDate.toFormat("MMMM yyyy").capitalized
    }

    var weekdaySymbols: [String] {
        let cal = Region.current.calendar
        let symbols = cal.shortStandaloneWeekdaySymbols
        let shift = cal.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift]).map { String($0.prefix(2)) }
    }

    var canGoPrev: Bool { selectedMonth != MonthYear(date: lowerBound) }
    var canGoNext: Bool { selectedMonth != MonthYear(date: upperBound) }

    // MARK: – Actions
    func advanceMonth(by delta: Int) {
        selectedMonth = delta < 0 ? selectedMonth.previous() : selectedMonth.next()
        rebuildDayData()
    }

    func select(day: Date) {
        guard day >= lowerBound && day <= upperBound else { return }
        selectedDate = day
    }

    func syncMonthToSelectedDate() {
        let m = MonthYear(date: selectedDate)
        if m != selectedMonth {
            selectedMonth = m
            rebuildDayData()
        }
    }

    // MARK: – Week grid
    func weeks() -> [[PokeCalendarDayCell]] {
        let referenceDate = selectedMonth.asDate
        let startOfMonth = referenceDate.dateAt(.startOfMonth)
        let endOfMonth   = referenceDate.dateAt(.endOfMonth)
        let weekStart    = startOfMonth.dateAt(.startOfWeek)
        let days: [Date] = (0..<42).map { weekStart + $0.days }

        return stride(from: 0, to: 42, by: 7).map { offset in
            days[offset..<offset + 7].map { day in
                cell(for: day, startOfMonth: startOfMonth, endOfMonth: endOfMonth)
            }
        }
    }

    // MARK: – Private helpers
    private func cell(for day: Date,
                      startOfMonth: Date,
                      endOfMonth: Date) -> PokeCalendarDayCell {
        let inMonth = day.isInRange(date: startOfMonth, and: endOfMonth, orEqual: true)
        let data = day > lowerBound && day < upperBound ? dayData[formatter.string(from: day)] : nil

        return PokeCalendarDayCell(
            date: day,
            pokemon: data?.pokemon,
            statDay: data?.statDay,
            isInCurrentMonth: inMonth,
            isBeforeRange: day < lowerBound,
            isAfterRange: day > upperBound,
            gameMode: gameMode
        )
    }

    /// Fetches only the Pokemons and PokeGameStatDays needed for the current month
    /// and joins them into `dayData`.
    private func rebuildDayData() {
        guard let context else { return }
        
        let days = selectedMonth.allDays()

        guard !days.isEmpty else {
            dayData = [:]
            return
        }

        let requiredIds   = days.map { generator.daily(for: gameMode, at: $0.date) }

        // Fetch only the Pokemons whose id is in the required set.
        let pokemonFetch  = FetchDescriptor<Pokemon>(
            predicate: #Predicate { requiredIds.contains($0.id) }
        )

        // Fetch only the PokeGameStatDays that fall within the current month range.
        let month = selectedMonth.month
        let year = selectedMonth.year
        let statDayFetch = FetchDescriptor<PokeGameStatDay>(
            predicate: #Predicate { $0.month == month && $0.year == year }
        )

        let pokemons  = (try? context.fetch(pokemonFetch))  ?? []
        let statDays  = (try? context.fetch(statDayFetch))  ?? []

        let pokemonById = Dictionary(uniqueKeysWithValues: pokemons.map { ($0.id, $0) })

        dayData = days.reduce(into: [:]) { result, day in
            let date = day.date
            let id = generator.daily(for: gameMode, at: date)
            guard let pokemon = pokemonById[id] else { return }
            let statDay = statDays.first { $0.matches(date: date) }
            result[formatter.string(from: date)] = PokeDayData(pokemon: pokemon, statDay: statDay)
        }
    }
    
    private var formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter
    }()

    private var lowerBound: Date { dateRange?.lowerBound.dateAt(.startOfDay) ?? .distantPast }
    private var upperBound: Date { dateRange?.upperBound.dateAt(.endOfDay) ?? .distantFuture }
}
