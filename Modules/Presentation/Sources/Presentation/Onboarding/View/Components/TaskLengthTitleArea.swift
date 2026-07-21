//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 20/07/2026.
//

import SwiftUI
import Common

 struct TaskLengthTitleArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How long do you like\nto focus in one go?")
                .font(AppFonts.nudgeSymbol)
                .foregroundColor(AppColors.brandDarkBlue)
                .lineSpacing(4)

            ChangeAnytimeTag()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}

//#Preview {
//    TaskLengthTitleArea()
//}
