//
//  PokeCalendarDayCell.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 23/04/2026.
//


import Foundation
import SwiftDate

struct PokeCalendarDayCell: Hashable {
    let date: DateInRegion
    let pokemon: Pokemon?
    let statDay: PokeGameStatDay?
    let isInCurrentMonth: Bool
    let isBeforeRange: Bool
    let isAfterRange: Bool
    
    let gameMode: PokeGameMode

    var isFound: Bool {
        if gameMode == .silhouette {
            return statDay?.silhouetteFound ?? false
        } else {
            return false
        }
    }
    
    var dayNumber: Int { date.day }
}
