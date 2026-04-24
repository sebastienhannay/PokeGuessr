//
//  ArcMotionEffect.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 15/04/2026.
//

import SwiftUI

struct ArcMotionEffect: GeometryEffect {
    var progress: CGFloat
    var startX: CGFloat
    var startY: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = startX * (1 - progress)
        let arcHeight: CGFloat = -80
        let y = startY * (1 - progress) + arcHeight * sin(.pi * progress)
        return ProjectionTransform(CGAffineTransform(translationX: x, y: y))
    }
}
