//
//  PokemonStatEntity 2.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 16/04/2026.
//

import Foundation
import SwiftData
import SwiftDate

@Model
final class PokeGameStatDay {
    var day: Int
    var month: Int
    var year: Int
    
    var silhouetteFound: Bool = false
    var silhouetteAttempts: Int = 0
    
    init(date: Date = Date(), silhouetteFound: Bool = false, silhouetteAttempt: Int = 0) {
        year = date.year
        month = date.month
        day = date.day
        
        self.silhouetteFound = silhouetteFound
        self.silhouetteAttempts = silhouetteAttempt
    }
    
    func matches(date : Date) -> Bool {
        return year == date.year && month == date.month && day == date.day
    }
}

extension PokeGameStatDay {
    
    static func fetchOrCreatePokeGameStatDay(for date: Date, modelContext: ModelContext) -> PokeGameStatDay {
        let (day, month, year) = (date.day, date.month, date.year)
        
        let predicate = #Predicate<PokeGameStatDay> { stat in
            stat.day == day && stat.month == month && stat.year == year
        }
        let descriptor = FetchDescriptor<PokeGameStatDay>(predicate: predicate)
        
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        } else {
            let newStat = PokeGameStatDay(date: date)
            modelContext.insert(newStat)
            return newStat
        }
    }
    
}
