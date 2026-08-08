//
//  RewardFlightOverlay.swift
//  Presentation
//
//  Created by Eslam Elnady on 08/08/2026.
//
import SwiftUI

struct RewardFlightOverlay: View {
    let sourceRect: CGRect
    let destinationRect: CGRect
    let points: Int
    let onFinished: () -> Void

    @State private var animate = false

    private let starCount = 6

    var body: some View {
        ZStack {
            ForEach(0..<starCount, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: 12 + CGFloat(index % 3) * 3))
                    .foregroundStyle(.yellow)
                    .position(
                        x: animate
                            ? destinationRect.midX + CGFloat(index - 2) * 3
                            : sourceRect.midX + CGFloat(index - 2) * 8,
                        y: animate
                            ? destinationRect.midY
                            : sourceRect.midY - CGFloat(index % 3) * 8
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.6 : 1)
                    .animation(
                        .easeInOut(duration: 0.7)
                            .delay(Double(index) * 0.04),
                        value: animate
                    )
            }
        }
        .allowsHitTesting(false)
        .task {
            try? await Task.sleep(for: .milliseconds(250)) // wait for points fade
            animate = true

            try? await Task.sleep(for: .milliseconds(1000))
            onFinished()
        }
    }
}
