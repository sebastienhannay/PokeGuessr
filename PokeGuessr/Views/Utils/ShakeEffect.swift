//
//  ShakeEffect.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import Foundation
import SwiftUI

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: sin(animatableData * .pi * 4) * 10,
                y: 0
            )
        )
    }
}
