//
//  PokeCalendarPicker.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 23/04/2026.
//

import SwiftUI
import SwiftData
import SwiftDate

struct PokeCalendarPicker: View {

    // MARK: – Environment
    @Environment(\.modelContext) private var context

    // MARK: – Public interface
    @Binding private var selection: Date

    // MARK: – Private state
    @State private var vm: PokeCalendarViewModel

    // MARK: – Init
    init(selection: Binding<Date>,
         in dateRange: ClosedRange<Date>? = nil,
         gameMode: PokeGameMode = .silhouette) {
        _selection = selection
        _vm = State(wrappedValue: PokeCalendarViewModel(
            selectedDate: selection.wrappedValue,
            dateRange: dateRange,
            gameMode: gameMode
        ))
    }

    var body: some View {
        VStack {
            headerRow
            if vm.showingMonthYearPicker {
                MonthYearPicker(selection: $vm.selectedMonth, range: vm.dateRange)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity.combined(with: .scale))
                Spacer()
            } else {
                calendarGrid
                Spacer()
            }
        }
        .padding()
        .task {
            vm.configure(context: context)
        }
        .onChange(of: selection) {
            vm.selectedDate = DateInRegion(selection)
            vm.syncMonthToSelectedDate()
        }
        .onChange(of: vm.selectedDate) {
            selection = vm.selectedDate.date
        }
    }

    // MARK: – Subviews
    private var headerRow: some View {
        HStack {
            Button {
                vm.showingMonthYearPicker.toggle()
            } label: {
                HStack(spacing: 6) {
                    Text(vm.monthTitle).font(.headline).fontWeight(.semibold)
                    Image(systemName: vm.showingMonthYearPicker ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            Spacer()
            Button { vm.advanceMonth(by: -1) } label: {
                Image(systemName: "chevron.left").font(.headline.weight(.semibold)).padding(8)
            }
            .buttonStyle(.plain).disabled(!vm.canGoPrev)
            Button { vm.advanceMonth(by: 1) } label: {
                Image(systemName: "chevron.right").font(.headline.weight(.semibold)).padding(8)
            }
            .buttonStyle(.plain).disabled(!vm.canGoNext)
        }
        .padding(.horizontal, 4).padding(.bottom, 4)
    }

    private var calendarGrid: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            GridRow {
                ForEach(vm.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol.uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            ForEach(vm.weeks(), id: \.self) { week in
                GridRow {
                    ForEach(week, id: \.self) { cell in
                        let isSelected = (cell.date.year, cell.date.month, cell.date.day) ==
                        (vm.selectedDate.year, vm.selectedDate.month, vm.selectedDate.day)
                        PokeDayCellView(
                            cell: cell,
                            isSelected: isSelected
                                
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture { vm.select(day: cell.date) }
                    }
                }
            }
        }
    }
}

#Preview {
    PokeCalendarPicker(
        selection: .constant(Date()),
        in: (Date() - 2.months)...Date(),
        gameMode: .silhouette
    )
    .modelContainer(.preview)
    .frame(width: 320, height: 320)
    .background(RoundedRectangle(cornerRadius: 16).fill(.gray.opacity(0.1)))
}
