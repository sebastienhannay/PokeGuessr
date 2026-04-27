//
//  PokeCalendarViewModelTests.swift
//  PokeGuessrTests
//

import Foundation
import Testing
import SwiftDate
@testable import PokeGuessr

// MARK: - Fixtures

private var jan15: Date {
    Date(components: .init(year: 2025, month: 1, day: 15), region: .current)!.date
}

private func makeSUT(
    date: Date? = nil,
    range: ClosedRange<Date>? = nil,
    mode: PokeGameMode = .silhouette
) -> PokeCalendarViewModel {
    PokeCalendarViewModel(selectedDate: date ?? jan15, dateRange: range, gameMode: mode)
}

// MARK: - Tests

@Suite("PokeCalendarViewModel")
struct PokeCalendarViewModelTests {

    @Test("Init floors selectedDate to start of day, stores month and gameMode")
    func initialState() {
        let noon = Calendar.current.date(bySettingHour: 13, minute: 37, second: 0, of: jan15)!
        let sut = makeSUT(date: noon, mode: .silhouette)

        #expect(sut.selectedDate == noon.dateAt(.startOfDay))
        #expect(sut.selectedMonth.month == 1)
        #expect(sut.selectedMonth.year == 2025)
        #expect(sut.gameMode == .silhouette)
    }

    @Test("monthTitle contains the year, weekdaySymbols returns 7 symbols of ≤2 chars")
    func derivedDisplayProperties() {
        let sut = makeSUT()

        #expect(sut.monthTitle.contains("2025"))
        #expect(sut.weekdaySymbols.count == 7)
        #expect(sut.weekdaySymbols.allSatisfy { $0.count <= 2 })
    }

    @Test("advanceMonth navigates forward, backward, and wraps across year boundary")
    func monthNavigation() {
        let sut = makeSUT() // Jan 2025

        sut.advanceMonth(by: 1)
        #expect(sut.selectedMonth.month == 2)

        sut.advanceMonth(by: -1) // back to Jan
        sut.advanceMonth(by: -1) // Dec 2024
        #expect(sut.selectedMonth.month == 12)
        #expect(sut.selectedMonth.year == 2024)

        for _ in 0..<13 { sut.advanceMonth(by: 1) } // Jan 2026
        #expect(sut.selectedMonth.month == 1)
        #expect(sut.selectedMonth.year == 2026)
    }

    @Test("canGoPrev / canGoNext respect the dateRange bounds")
    func navigationBounds() {
        let prev = Calendar.current.date(byAdding: .month, value: -1, to: jan15)!
        let next = Calendar.current.date(byAdding: .month, value:  1, to: jan15)!

        #expect(makeSUT(range: jan15...next).canGoPrev == false)  // at lower bound
        #expect(makeSUT(range: prev...jan15).canGoNext == false)  // at upper bound
        #expect(makeSUT(range: prev...next).canGoPrev == true)
        #expect(makeSUT(range: prev...next).canGoNext == true)
    }

    @Test("select(day:) updates selectedDate only when the day is within the range")
    func daySelection() {
        let lower = Calendar.current.date(byAdding: .day, value: -5, to: jan15)!
        let upper = Calendar.current.date(byAdding: .day, value:  5, to: jan15)!
        let sut = makeSUT(date: jan15, range: lower...upper)
        let original = sut.selectedDate

        // Valid day — should update
        let inRange = jan15.dateAt(.startOfDay) + 2.days
        sut.select(day: inRange)
        #expect(sut.selectedDate == inRange)

        // Before range — should be a no-op
        sut.select(day: lower.dateAt(.startOfDay) - 1.days)
        #expect(sut.selectedDate == inRange)

        // After range — should be a no-op
        sut.select(day: upper.dateAt(.startOfDay) + 1.days)
        #expect(sut.selectedDate == inRange)

        _ = original // silence unused warning
    }

    @Test("syncMonthToSelectedDate aligns selectedMonth with selectedDate")
    func monthSync() {
        let sut = makeSUT() // Jan 2025
        let before = sut.selectedMonth

        sut.syncMonthToSelectedDate()
        #expect(sut.selectedMonth == before)

        sut.selectedDate = Date(
            components: .init(year: 2025, month: 3, day: 10), region: .current
        )!.dateAt(.startOfDay)
        sut.syncMonthToSelectedDate()
        #expect(sut.selectedMonth.month == 3)
        #expect(sut.selectedMonth.year == 2025)
    }

    @Test("weeks() returns a 6×7 grid with correct in-month/out-of-month counts and chronological order")
    func weeksGrid() {
        let weeks = makeSUT().weeks() // January 2025
        let cells = weeks.flatMap { $0 }

        #expect(weeks.count == 6)
        #expect(weeks.allSatisfy { $0.count == 7 })
        #expect(cells.filter(\.isInCurrentMonth).count == 31)
        #expect(cells.filter { !$0.isInCurrentMonth }.count == 11) // 42 - 31

        let dates = cells.map(\.date.date)
        #expect(dates == dates.sorted())
    }
}
