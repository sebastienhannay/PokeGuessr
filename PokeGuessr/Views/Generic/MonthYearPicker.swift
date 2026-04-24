//
//  MonthYearPickerView.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 22/04/2026.
//

import SwiftUI
import SwiftDate

// MARK: - Public view

struct MonthYearPicker: View {

    @Binding var selection: MonthYear
    var range: ClosedRange<Date>?

    private let calendar  = Calendar.current
    private let rowHeight: CGFloat = 36

    private var years: [Int] {
        let lo = range?.lowerBound.year ?? 1970
        let hi = range?.upperBound.year ?? 2099
        return Array(lo...hi)
    }

    private var selectedMonth: Int { selection.month }
    private var selectedYear:  Int { selection.year }

    /// (year, month) tuple of the range bounds
    private var rangeYearMonth: (lo: (Int, Int), hi: (Int, Int))? {
        guard let range else { return nil }
        return ((range.lowerBound.year, range.lowerBound.month),
                (range.upperBound.year, range.upperBound.month))
    }

    private func commit(month: Int, year: Int) {
        selection = MonthYear(month: month, year: year)
    }

    private func isMonthEnabled(_ month: Int) -> Bool {
        guard let bounds = rangeYearMonth else { return true }
        // Compare (year, month) pairs lexicographically
        let candidate = (selectedYear, month)
        return candidate >= bounds.lo && candidate <= bounds.hi
    }

    private func isYearEnabled(_ year: Int) -> Bool {
        guard let bounds = rangeYearMonth else { return true }
        return year >= bounds.lo.0 && year <= bounds.hi.0
    }

    var body: some View {
        HStack(spacing: 0) {

            WheelColumn(
                items: Array(1...12),
                selectedItem: selectedMonth,
                rowHeight: rowHeight,
                label: { DateFormatter().monthSymbols[$0 - 1].capitalized },
                isEnabled: { isMonthEnabled($0) },
                onCommit: { commit(month: $0, year: selectedYear) }
            )
            .frame(maxWidth: .infinity)

            WheelColumn(
                items: years,
                selectedItem: selectedYear,
                rowHeight: rowHeight,
                label: { String($0) },
                isEnabled: { isYearEnabled($0) },
                onCommit: { commit(month: selectedMonth, year: $0) }
            )
            .frame(maxWidth: .infinity)
        }
        .frame(height: rowHeight * 5)
        .clipped()
        .overlay(alignment: .center) {
            Capsule()
                .fill(.regularMaterial.opacity(0.2))
                .frame(height: rowHeight)
                .allowsHitTesting(false)
        }
    }
}

// MARK: - Wheel column
private struct WheelColumn<Item: Hashable>: View {

    let items:       [Item]
    let selectedItem: Item
    let rowHeight:   CGFloat
    let label:       (Item) -> String
    let isEnabled:   (Item) -> Bool
    let onCommit:    (Item) -> Void

    @State private var offset:       CGFloat = 0
    @State private var dragStart:    CGFloat = 0
    @State private var isDragging:   Bool    = false

    // MARK: Derived helpers

    private var selectedIndex: Int {
        items.firstIndex(of: selectedItem) ?? 0
    }

    private var maxOffset: CGFloat {
        CGFloat(items.count - 1) * rowHeight
    }

    private func snap(_ raw: CGFloat) -> CGFloat {
        raw.clamped(to: 0...maxOffset)
    }

    private func nearestEnabledIndex(to raw: CGFloat) -> Int? {
        let ideal = Int((raw / rowHeight).rounded()).clamped(to: 0...(items.count - 1))
        for delta in 0...(items.count - 1) {
            for sign in (delta == 0 ? [0] : [-1, 1]) {
                let i = ideal + delta * sign
                guard i >= 0, i < items.count else { continue }
                if isEnabled(items[i]) { return i }
            }
        }
        return nil
    }

    // MARK: Body

    var body: some View {
        GeometryReader { geo in
            let midY    = geo.size.height / 2
            let visR    = Int(ceil(geo.size.height / rowHeight / 2)) + 1
            let centreI = Int((offset / rowHeight).rounded()).clamped(to: 0...(items.count - 1))
            let lo      = max(0, centreI - visR)
            let hi      = min(items.count - 1, centreI + visR)

            ZStack {
                if lo <= hi {
                    ForEach(lo...hi, id: \.self) { i in
                        let y    = midY + CGFloat(i) * rowHeight - offset
                        let dist = abs(y - midY)
                        let t    = (dist / (rowHeight * 2.5)).clamped(to: 0...1)
                        let opacity = Double(1 - t * t * t)

                        Text(label(items[i]))
                            .font(.system(size: 20))
                            .foregroundStyle(itemStyle(i))
                            .frame(maxWidth: .infinity)
                            .frame(height: rowHeight)
                            .opacity(opacity)
                            .position(x: geo.size.width / 2, y: y)
                    }
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { v in
                        if !isDragging {
                            isDragging = true
                            dragStart  = offset
                        }
                        offset = snap(dragStart - v.translation.height)
                    }
                    .onEnded { v in
                        isDragging = false
                        let projected = snap(dragStart - v.predictedEndTranslation.height)
                        if let landing = nearestEnabledIndex(to: projected) {
                            withAnimation(.interpolatingSpring(stiffness: 180, damping: 22)) {
                                offset = CGFloat(landing) * rowHeight
                            }
                            onCommit(items[landing])
                        } else {
                            withAnimation(.interpolatingSpring(stiffness: 180, damping: 22)) {
                                offset = CGFloat(selectedIndex) * rowHeight
                            }
                        }
                    }
            )
            .onAppear {
                offset = CGFloat(selectedIndex) * rowHeight
            }
            .onChange(of: selectedItem) { _, _ in
                guard !isDragging else { return }
                withAnimation(.snappy) {
                    offset = CGFloat(selectedIndex) * rowHeight
                }
            }
        }
    }

    // MARK: Item style

    private func itemStyle(_ i: Int) -> AnyShapeStyle {
        guard isEnabled(items[i]) else {
            return AnyShapeStyle(Color.secondary.opacity(0.35))
        }
        let centreI = Int((offset / rowHeight).rounded()).clamped(to: 0...(items.count - 1))
        return i == centreI
            ? AnyShapeStyle(Color.primary)
            : AnyShapeStyle(Color.secondary)
    }
}

// MARK: - Helpers

extension Comparable {
    fileprivate func clamped(to r: ClosedRange<Self>) -> Self {
        min(max(self, r.lowerBound), r.upperBound)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var monthYear = MonthYear.now
    MonthYearPicker(selection: $monthYear)
        .frame(width: 320)
        .padding()
}
