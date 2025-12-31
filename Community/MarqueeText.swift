//
//  MarqueeText.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

/// Simple horizontal marquee for a single line.
/// - Works best inside a fixed-height container.
/// - If text fits, it won't animate.
struct MarqueeText: View {

    let text: String
    var font: Font = .footnote
    var speed: Double = 35       // points per second
    var startDelay: Double = 0.8 // seconds
    var fadeWidth: CGFloat = 18

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var animating: Bool = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack {
                // Fading edges (nice UX)
                HStack {
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemBackground).opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: fadeWidth)

                    Spacer()

                    LinearGradient(
                        colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: fadeWidth)
                }
                .allowsHitTesting(false)

                HStack(spacing: 24) {
                    Text(text)
                        .font(font)
                        .lineLimit(1)
                        .background(
                            GeometryReader { tGeo in
                                Color.clear
                                    .onAppear {
                                        textWidth = tGeo.size.width
                                        containerWidth = w
                                        configureAnimationIfNeeded()
                                    }
                                    .onChange(of: text) { _ in
                                        // recompute on new text
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                            configureAnimationIfNeeded()
                                        }
                                    }
                            }
                        )

                    // duplicate text to create seamless loop when needed
                    if textWidth > w {
                        Text(text)
                            .font(font)
                            .lineLimit(1)
                    }
                }
                .offset(x: offsetX)
                .onAppear {
                    containerWidth = w
                    configureAnimationIfNeeded()
                }
                .onChange(of: w) { newW in
                    containerWidth = newW
                    configureAnimationIfNeeded()
                }
            }
        }
        .frame(height: 18)
        .clipped()
    }

    private func configureAnimationIfNeeded() {
        // If text fits, stop animation & reset
        guard textWidth > containerWidth, textWidth > 0, containerWidth > 0 else {
            animating = false
            offsetX = 0
            return
        }

        // Avoid restarting too often
        if animating { return }
        animating = true

        // Start slightly off-screen to the right
        offsetX = 0

        let distance = textWidth + 24 // + spacing to the duplicated text
        let duration = distance / max(speed, 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                offsetX = -distance
            }
        }
    }
}
