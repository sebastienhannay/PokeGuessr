//
//  PokeGuessrApp.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftUI
import SwiftData

var releaseDate: Date = ISO8601DateFormatter().date(from: "2026-04-13T00:00:00Z")!

@main
struct PokeGuessrApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(.shared)
    }
}
