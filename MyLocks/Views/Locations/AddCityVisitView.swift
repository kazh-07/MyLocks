import SwiftUI
import SwiftData

/// Form view for adding a visit to a city
struct AddCityVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let city: City
    
    @State private var precision: DatePrecision = .exact
    @State private var isRange: Bool = false  // NEW: Toggle for single vs range
    
    // Exact date precision
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    // Year precision
    @State private var startYear = Calendar.current.component(.year, from: Date())
    @State private var endYear = Calendar.current.component(.year, from: Date())
    
    @State private var companion: String = ""
    @State private var notes: String = ""
    @State private var places: String = ""
    
    // Transportation
    @State private var showAddTransportation = false
    @State private var pendingTransportation: Transportation?
    
    private let years = Array(1950...Calendar.current.component(.year, from: Date()))
    
    // Validation
    private var validator: DateRangeValidator {
        DateRangeValidator(
            precision: precision,
            isRange: isRange,
            startDate: startDate,
            endDate: endDate,
            startYear: startYear,
            endYear: endYear
        )
    }
    
    private var canSave: Bool {
        validator.isValid
    }
    
    var body: some View {
        NavigationStack {
            Form {
                DateSelectionSection(
                    precision: $precision,
                    isRange: $isRange,
                    startDate: $startDate,
                    endDate: $endDate,
                    startYear: $startYear,
                    endYear: $endYear
                )
                .listRowInsets(AddVisitStyles.rowInsets)
                
                CompanionSection(companion: $companion)
                    .listRowInsets(AddVisitStyles.rowInsets)
                
                PlacesSection(placesText: $places, mode: .visit)
                    .listRowInsets(AddVisitStyles.rowInsets)
                
                TransportationSection(
                    transportation: $pendingTransportation,
                    showAddTransportation: $showAddTransportation
                )
                .listRowInsets(AddVisitStyles.rowInsets)
                
                NotesSection(notes: $notes)
                    .listRowInsets(AddVisitStyles.rowInsets)
            }
            .formStyle(.grouped)
            .environment(\.defaultMinListRowHeight, 0)
            .navigationTitle("Add Visit")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddTransportation) {
                AddTransportationView(
                    onSave: { transportation in
                        pendingTransportation = transportation
                    }
                )
            }
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
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func saveVisit() {
        // Parse notable places (comma separated)
        let placesArray = PlacesParser.parse(places)
        
        // REQUIRED: Create a parent CountryVisit first
        guard let country = city.country else {
            print("Error: City has no country")
            return
        }
        
        let countryVisit = CountryVisit(
            country: country,
            date: precision == .exact ? startDate : Calendar.current.date(from: DateComponents(year: startYear, month: 1, day: 1)) ?? Date(),
            notes: nil  // Country visit notes can be added separately
        )
        modelContext.insert(countryVisit)
        
        // Create new visit based on precision and range settings
        let newVisit: CityVisit
        
        switch precision {
        case .exact:
            if isRange {
                newVisit = CityVisit(
                    startDate: startDate,
                    endDate: endDate,
                    companion: companion.isEmpty ? nil : companion,
                    note: notes.isEmpty ? nil : notes,
                    places: placesArray.isEmpty ? nil : placesArray,
                    city: city,
                    parentCountryVisit: countryVisit
                )
            } else {
                newVisit = CityVisit(
                    date: startDate,
                    companion: companion.isEmpty ? nil : companion,
                    note: notes.isEmpty ? nil : notes,
                    places: placesArray.isEmpty ? nil : placesArray,
                    city: city,
                    parentCountryVisit: countryVisit
                )
            }
            
        case .year:
            newVisit = CityVisit(
                startYear: startYear,
                endYear: isRange ? endYear : startYear,
                companion: companion.isEmpty ? nil : companion,
                note: notes.isEmpty ? nil : notes,
                places: placesArray.isEmpty ? nil : placesArray,
                city: city,
                parentCountryVisit: countryVisit
            )
        }
        
        // Insert into context
        modelContext.insert(newVisit)
        
        // Link pending transportation to this visit
        if let transport = pendingTransportation {
            transport.cityVisit = newVisit
            modelContext.insert(transport)
        }
        
        // Add to city's visits
        city.visits.append(newVisit)
        
        // Save context
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving visit: \(error)")
        }
    }
}
