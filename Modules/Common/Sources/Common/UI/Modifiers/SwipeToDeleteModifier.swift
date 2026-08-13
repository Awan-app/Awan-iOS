//
//  SwipeToDeleteModifier.swift
//  Awan
//

import SwiftUI

public struct SwipeToDeleteModifier: ViewModifier {
    let action: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    private let buttonWidth: CGFloat = 80
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {

            Button {
                withAnimation(.spring()) {
                    offset = 0
                    isSwiped = false
                }
                action()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.red)
                        .padding(.vertical, 2)
                    
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .frame(width: buttonWidth)
            .opacity(offset < -30 ? 1 : 0)
            

            content
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in

                            if value.translation.width < 0 {
                                if isSwiped {
                                    offset = value.translation.width - buttonWidth
                                } else {
                                    offset = value.translation.width
                                }
                            } else if value.translation.width > 0 && isSwiped {
                                offset = value.translation.width - buttonWidth
                                if offset > 0 { offset = 0 }
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if value.translation.width < -50 {
                                    isSwiped = true
                                    offset = -buttonWidth
                                } else {
                                    isSwiped = false
                                    offset = 0
                                }
                            }
                        }
                )
        }
    }
}

public extension View {
    func customSwipeToDelete(action: @escaping () -> Void) -> some View {
        modifier(SwipeToDeleteModifier(action: action))
    }
}
