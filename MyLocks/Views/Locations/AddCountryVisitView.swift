import SwiftUI
import SwiftData

struct AddCountryVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    let country: Country
    
    @State private var visitDate = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                        // Country info
                        HStack(spacing: AppSpacing.md) {
                            if let flag = country.flagEmoji {
                                Text(flag)
                                    .font(.system(size: 24))
                            }
                            
                            Text(country.localizedName(language: selectedLanguage))
                                .font(AppFonts.headline)
                                .foregroundStyle(AppColors.label)
                        }
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                        
                        // Visit date
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Visit Date")
                                .font(AppFonts.callout)
                                .foregroundStyle(AppColors.label)
                            
                            DatePicker(
                                "Date",
                                selection: $visitDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                        }
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Notes (Optional)")
                                .font(AppFonts.callout)
                                .foregroundStyle(AppColors.label)
                            
                            TextField("Add notes about your visit", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                        
                        Spacer(minLength: AppSpacing.paddingBottom)
                    }
                    .padding(.top, AppSpacing.pageTop)
                }
            }
            .navigationTitle("Add Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addVisit()
                    }
                }
            }
        }
    }
    
    private func addVisit() {
        let visit = CountryVisit(
            country: country,
            date: visitDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(visit)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving visit: \(error)")
        }
    }
}
