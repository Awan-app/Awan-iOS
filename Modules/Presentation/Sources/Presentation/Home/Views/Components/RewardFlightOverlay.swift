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

    let onArrived: () -> Void
    let onFinished: () -> Void

    @State private var flying = false
    @State private var disappearing = false

    private let starCount = 6

    var body: some View {
        ZStack {
            ForEach(0..<starCount, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(
                        .system(
                            size: 15 + CGFloat(index % 3) * 3
                        )
                    )
                    .foregroundStyle(.yellow)
                    .position(
                        x: flying
                            ? destinationRect.midX
                                + CGFloat(index - 2) * 3
                            : sourceRect.midX
                                + CGFloat(index - 2) * 8,
                        y: flying
                            ? destinationRect.midY
                            : sourceRect.midY
                                - CGFloat(index % 3) * 8
                    )

                    // stays visible for almost the whole flight
                    .opacity(disappearing ? 0 : 1)

                    .scaleEffect(
                        disappearing ? 0.35 : 1
                    )

                    // movement
                    .animation(
                        .easeInOut(duration: 0.75)
                            .delay(Double(index) * 0.04),
                        value: flying
                    )

                    // only fade near destination
                    .animation(
                        .easeOut(duration: 0.14)
                            .delay(
                                0.64 + Double(index) * 0.04
                            ),
                        value: disappearing
                    )
            }
        }
        .allowsHitTesting(false)
        .task {
            // tiny delay so initial position gets rendered
            try? await Task.sleep(for: .milliseconds(30))

            flying = true
            disappearing = true

            // roughly when first stars hit first header
            try? await Task.sleep(for: .milliseconds(720))

            onArrived()

            try? await Task.sleep(for: .milliseconds(300))

            onFinished()
        }
    }
}
