//
//  CalendarButton.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 15/04/2026.
//

import SwiftUI

struct CalendarButton: View {
    
    @Environment(\.calendarPrimaryTint) private var primaryTint
    @Environment(\.calendarSecondaryTint) private var secondaryTint
    @Environment(\.calendarTertiaryTint) private var tertiaryTint
    
    let cornerRatio: CGFloat = 0.15
    let insetRatio: CGFloat = 0.05
    let heightRatio: CGFloat = 0.7
    
    let date: Date
    var action: () -> Void = { }

    private var day: String {
        DateFormatter.dayFormatter.string(from: date)
    }

    private var month: String {
        DateFormatter.monthFormatter.string(from: date)
    }

    var body: some View {
        Button(action: action) {
            GeometryReader { geo in
                let rect = geo.frame(in: .local)
                let cornerRadius = rect.width * cornerRatio
                let inset = rect.width * insetRatio
                
                let innerWidth = rect.width - 2 * inset
                let innerHeight = rect.height * heightRatio
                let innerX = inset
                let innerY = rect.height - innerHeight - inset
                
                let innerRect = CGRect(
                    x: innerX,
                    y: innerY,
                    width: innerWidth,
                    height: innerHeight
                )
                
                let innerCorner = cornerRadius * (innerHeight / rect.height)
                
                ZStack(alignment: .topLeading) {
                    Path { path in
                        path.addRoundedRect(
                            in: rect,
                            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
                        )
                        path.addRoundedRect(
                            in: innerRect,
                            cornerSize: CGSize(width: innerCorner, height: innerCorner)
                        )
                    }
                    .fill(primaryTint, style: FillStyle(eoFill: true))
                    
                    VStack(spacing: 0) {
                        Text(day)
                            .foregroundStyle(secondaryTint)
                            .font(.system(size: geo.size.width * 0.5, weight: .semibold))
                            .offset(y: geo.size.width * 0.04)
                        
                        Text(month)
                            .font(.system(size: geo.size.width * 0.25))
                            .foregroundStyle(tertiaryTint)
                            .offset(y: -geo.size.width * 0.1)
                    }
                    .frame(width: innerRect.width, height: innerRect.height)
                    .position(
                        x: innerRect.midX,
                        y: innerRect.midY
                    )
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

#Preview {
    let dates: [Date] = [
        Date(),
        Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1))!,
        Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 15))!,
        Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!
    ]
    
    let sizes: [CGFloat] = [40, 60, 80, 100]

    VStack(spacing: 20) {
        ForEach(dates, id: \.self) { date in
            HStack(spacing: 16) {
                ForEach(sizes, id: \.self) { size in
                    CalendarButton(date: date)
                        .frame(width: size, height: size)
                }
            }
        }
    }
    .padding()
}

private struct CalendarPrimaryTintKey: EnvironmentKey {
    static let defaultValue: Color = .accentColor
}

private struct CalendarSecondaryTintKey: EnvironmentKey {
    static let defaultValue: Color = .primary
}

private struct CalendarTertiaryTintKey: EnvironmentKey {
    static let defaultValue: Color = .secondary
}

extension EnvironmentValues {
    var calendarPrimaryTint: Color {
        get { self[CalendarPrimaryTintKey.self] }
        set { self[CalendarPrimaryTintKey.self] = newValue }
    }

    var calendarSecondaryTint: Color {
        get { self[CalendarSecondaryTintKey.self] }
        set { self[CalendarSecondaryTintKey.self] = newValue }
    }

    var calendarTertiaryTint: Color {
        get { self[CalendarTertiaryTintKey.self] }
        set { self[CalendarTertiaryTintKey.self] = newValue }
    }
}

extension View {
    func primaryTint(_ color: Color) -> some View {
        environment(\.calendarPrimaryTint, color)
    }

    func secondaryTint(_ color: Color) -> some View {
        environment(\.calendarSecondaryTint, color)
    }

    func tertiaryTint(_ color: Color) -> some View {
        environment(\.calendarTertiaryTint, color)
    }
}

private extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()
    
    static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f
    }()
}
