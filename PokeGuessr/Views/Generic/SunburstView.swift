//
//  SunburstView.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import SwiftUI

struct SunburstView: View {
    let color: Color
    let lineCount: Int
    let lineWidth: CGFloat
    let minLengthPercent: CGFloat
    let maxLengthPercent: CGFloat

    private let randomFactors: [CGFloat]

    init(color: Color, lineCount: Int, lineWidth: CGFloat = 4, minLengthPercent: CGFloat = 0.3, maxLengthPercent: CGFloat = 0.6) {
        self.color = color
        self.lineCount = lineCount
        self.lineWidth = lineWidth
        self.minLengthPercent = minLengthPercent
        self.maxLengthPercent = maxLengthPercent
        self.randomFactors = (0..<lineCount).map { _ in CGFloat.random(in: 0...1) }
    }

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let maxDimension = max(size.width, size.height)

            var path = Path()

            for i in 0..<lineCount {
                let angle = Double(i) * (2 * .pi / Double(lineCount))
                let length = (minLengthPercent + randomFactors[i] * (maxLengthPercent - minLengthPercent)) * maxDimension

                let baseHalf = lineWidth * CGFloat.random(in: 0.5...1.5) * 0.5

                let perpX = -sin(angle)
                let perpY =  cos(angle)

                let baseLeft  = CGPoint(x: center.x + perpX * baseHalf,
                                        y: center.y + perpY * baseHalf)
                let baseRight = CGPoint(x: center.x - perpX * baseHalf,
                                        y: center.y - perpY * baseHalf)
                let tip       = CGPoint(x: center.x + cos(angle) * length,
                                        y: center.y + sin(angle) * length)

                path.move(to: baseLeft)
                path.addLine(to: tip)
                path.addLine(to: baseRight)
                path.closeSubpath()
            }

            context.fill(path, with: .color(color))
        }
        .blur(radius: CGFloat(lineCount) / lineWidth)
    }
}

#Preview {
    VStack {
        ZStack {
            SunburstView(color: .sunburstBack, lineCount: 72, lineWidth: 36, minLengthPercent: 0.35, maxLengthPercent: 0.5)
            SunburstView(color: .white, lineCount: 36, lineWidth: 24, minLengthPercent: 0.35, maxLengthPercent: 0.45)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}
