import SwiftUI

struct PlaceholderPage: View {
    let title: String

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            Text(title)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.titleText)
        }
    }
}
