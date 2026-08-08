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

                    .opacity(disappearing ? 0 : 1)

                    .scaleEffect(
                        disappearing ? 0.35 : 1
                    )

                    .animation(
                        .easeInOut(duration: 0.75)
                            .delay(Double(index) * 0.04),
                        value: flying
                    )

                    .animation(
                        .easeOut(duration: 0.18),
                        value: disappearing
                    )
            }
        }
        .allowsHitTesting(false)
        .task {
            try? await Task.sleep(for: .milliseconds(30))

            flying = true

            try? await Task.sleep(for: .milliseconds(600))

            disappearing = true

            try? await Task.sleep(for: .milliseconds(120))

            onArrived()

            try? await Task.sleep(for: .milliseconds(320))

            onFinished()
        }
    }
}
