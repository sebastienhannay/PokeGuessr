//
//  ContentView.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var date = Date()
    @State private var showCalendar = false
    @State private var gameStat: PokeGameStatDay?
    
    @Namespace private var namespace
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            SilhouetteView(
                pokemonId: PokeRandomIdGenerator().daily(for: .silhouette, at: date),
                gameStat: $gameStat
            )
            .id(date)
            .toolbar {
                ToolbarItem {
                    CalendarButton(date: date, action: {
                        showCalendar = true
                    })
                        .matchedTransitionSource(id: "MENUCONTENT", in: namespace)
                        .primaryTint(.secondary)
                        .popover(isPresented: $showCalendar) {
                            DatePicker(
                                "datePicker.pickADate",
                                selection: $date,
                                in: releaseDate...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .accentColor(.redBackground)
                            .frame(width: 320, height: 320)
                            .presentationCompactAdaptation(.popover)
                            .navigationTransition(.zoom(sourceID: "MENUCONTENT", in: namespace))
                        }
                }
            }
            .onAppear {
                self.gameStat = PokeGameStatDay.fetchOrCreatePokeGameStatDay(for: date, modelContext: modelContext)
            }
            .onChange(of: date) { _, newValue in
                showCalendar = false
                self.gameStat = PokeGameStatDay.fetchOrCreatePokeGameStatDay(for: newValue, modelContext: modelContext)
            }
        }
    }
}

#Preview {
    let container : ModelContainer = .preview
    ContentView()
        .modelContainer(container)
}
