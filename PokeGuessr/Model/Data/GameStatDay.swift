//
//  PokemonStatEntity 2.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 16/04/2026.
//

import Foundation
import SwiftData

@Model
final class PokeGameStatDay {
    var day: Int
    var month: Int
    var year: Int
    
    var silhouetteFound: Bool = false
    var silhouetteAttempts: Int = 0
    
    init(date: Date = Date(), silhouetteFound: Bool = false, silhouetteAttempt: Int = 0) {
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month, .day], from: date)
        
        year = components.year  ?? 0
        month = components.month ?? 0
        day = components.day   ?? 0
        
        self.silhouetteFound = silhouetteFound
        self.silhouetteAttempts = silhouetteAttempt
    }
}

extension PokeGameStatDay {
    
    static func fetchOrCreatePokeGameStatDay(for date: Date, modelContext: ModelContext) -> PokeGameStatDay {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        let (day, month, year) = (c.day ?? 0, c.month ?? 0, c.year ?? 0)
        
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
