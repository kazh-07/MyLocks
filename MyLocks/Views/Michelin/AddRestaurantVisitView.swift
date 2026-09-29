import SwiftUI
import SwiftData

/// Form view for adding a visit to a restaurant
struct AddRestaurantVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let restaurant: MichelinRestaurant
    
    @State private var visitDate: Date = Date()
    @State private var companion: String = ""
    @State private var notes: String = ""
    @State private var rating: Int? = nil
    @State private var signatureDishes: String = ""
    
    // Rating heart selection
    private let ratingOptions = [1, 2, 3, 4, 5]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Visit Date",
                        selection: $visitDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                } header: {
                    Text("When did you visit?")
                        .textCase(nil)
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                Section {
                    TextField("Companion's Name", text: $companion)
                } header: {
                    Text("Who did you go with? (Optional)")
                        .textCase(nil)
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                Section {
                    TextField("Rating (1-10)", value: $rating, format: .number)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Your Rating (Optional)")
                        .textCase(nil)
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                Section {
                    TextField("e.g., Truffle Pasta, Wagyu Steak", text: $signatureDishes, axis: .vertical)
                        .lineLimit(AddVisitStyles.dishesLineLimit)
                } header: {
                    Text("Signature Dishes (Optional)")
                        .textCase(nil)
                } footer: {
                    Text("List any memorable dishes you had")
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(AddVisitStyles.notesLineLimit)
                } header: {
                    Text("Notes (Optional)")
                        .textCase(nil)
                } footer: {
                    Text("Share your thoughts about this visit")
                }
                .listRowInsets(AddVisitStyles.rowInsets)
            }
            .formStyle(.grouped)
            .environment(\.defaultMinListRowHeight, 0)
            .navigationTitle("Add Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVisit()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveVisit() {
        // Parse signature dishes (comma separated)
        let dishesArray = signatureDishes
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Create new visit
        let newVisit = RestaurantVisit(
            date: visitDate,
            companion: companion.isEmpty ? nil : companion,
            note: notes.isEmpty ? nil : notes,
            rating: rating,
            signatureDishes: dishesArray.isEmpty ? nil : dishesArray,
            restaurant: restaurant
        )
        
        // Insert into context
        modelContext.insert(newVisit)
        
        // Add to restaurant's visits
        restaurant.visits.append(newVisit)
        
        // Save context
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving visit: \(error)")
        }
    }
}
