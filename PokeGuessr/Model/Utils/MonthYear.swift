//
//  MonthYear.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 23/04/2026.
//

import Foundation
import SwiftDate

struct MonthYear: Equatable, Hashable {
    var month: Int  // 1-12
    var year: Int
    
    /// Creates a MonthYear from the current date
    static var now: MonthYear {
        let today = Date()
        let calendar = Calendar.current
        return MonthYear(
            month: calendar.component(.month, from: today),
            year: calendar.component(.year, from: today)
        )
    }
    
    /// Validates that month is in range 1-12
    init(month: Int, year: Int) {
        self.month = max(1, min(12, month))
        self.year = year
    }
    
    /// Validates that month is in range 1-12
    init(date: Date) {
        self.month = date.month
        self.year = date.year
    }
    
    /// Converts to a Date (first day of the month)
    var asDate: Date {
        let date = Date(
            year: year,
            month: month,
            day: 15,
            hour: 0,
            minute: 0,
            region: Region.current
        )
        
        return date
    }
    
    /// Returns the next month
    func next() -> MonthYear {
        if month == 12 {
            return MonthYear(month: 1, year: year + 1)
        } else {
            return MonthYear(month: month + 1, year: year)
        }
    }
    
    /// Returns the previous month
    func previous() -> MonthYear {
        if month == 1 {
            return MonthYear(month: 12, year: year - 1)
        } else {
            return MonthYear(month: month - 1, year: year)
        }
    }
    
    func allDays() -> [Date] {
        let start = asDate
        let numberOfDays = start.monthDays
        
        return (0..<numberOfDays).compactMap {
            start + $0.days
        }
    }
}
