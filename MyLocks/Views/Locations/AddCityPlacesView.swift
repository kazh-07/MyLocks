import SwiftUI
import SwiftData

/// Form view for adding places to visit in a city (wishlist places)
struct AddCityPlacesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var city: City
    
    @State private var placesText: String = ""
    @State private var editingPlaces: [String] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g., Bund, Yu Garden, French Concession", text: $placesText, axis: .vertical)
                        .lineLimit(5...10)
                } header: {
                    Text("Add Places to Visit")
                        .textCase(nil)
                } footer: {
                    Text("Enter places you want to visit in this city, separated by commas or new lines")
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                // Show existing wishlist places
                if !editingPlaces.isEmpty {
                    Section {
                        ForEach(editingPlaces, id: \.self) { place in
                            HStack {
                                Text(place)
                                    .font(AppFonts.body)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        editingPlaces.removeAll { $0 == place }
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(AppColors.tertiaryLabel)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } header: {
                        Text("Places to Visit")
                            .textCase(nil)
                    }
                    .listRowInsets(AddVisitStyles.rowInsets)
                }
            }
            .navigationTitle("Places to Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadExistingPlaces()
            }
        }
    }
    
    private func loadExistingPlaces() {
        // Get or create a wishlist for this city
        if let wishlist = city.wishlists.first {
            editingPlaces = wishlist.places ?? []
        }
    }
    
    private func saveChanges() {
        // Parse the text input
        let newPlaces = parsePlaces(from: placesText)
        
        // Combine with existing places
        var allPlaces = Set(editingPlaces)
        newPlaces.forEach { allPlaces.insert($0) }
        
        let sortedPlaces = Array(allPlaces).sorted()
        
        // Get or create wishlist
        if let existingWishlist = city.wishlists.first {
            // Update existing wishlist
            existingWishlist.places = sortedPlaces
        } else {
            // Create new wishlist
            let newWishlist = CityWishlist(
                city: city,
                note: nil,
                places: sortedPlaces
            )
            modelContext.insert(newWishlist)
        }
        
        // Save context
        do {
            try modelContext.save()
        } catch {
            print("Error saving places: \(error)")
        }
    }
    
    private func parsePlaces(from text: String) -> [String] {
        // Split by commas or newlines
        let separators = CharacterSet(charactersIn: ",\n")
        let components = text.components(separatedBy: separators)
        
        // Trim whitespace and filter empty strings
        return components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
