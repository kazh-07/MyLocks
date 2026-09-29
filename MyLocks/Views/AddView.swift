import SwiftUI

struct AddView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                Text("Add")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.titleText)
            }
            .navigationTitle("Add")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
