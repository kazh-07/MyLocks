import SwiftUI
import SwiftUI
import SwiftData

struct AddCountryVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    let country: Country
    
    // Mode selection
    enum VisitMode: String, CaseIterable, Identifiable {
        case visit = "Visit"
        case wishlist = "Wishlist"
        
        var id: String { rawValue }
    }
    
    @State private var mode: VisitMode = .visit
    
    // Date precision
    @State private var precision: DatePrecision = .exact
    @State private var isRange: Bool = false
    
    // Exact date precision
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    // Year precision
    @State private var startYear = Calendar.current.component(.year, from: Date())
    @State private var endYear = Calendar.current.component(.year, from: Date())
    
    // Country visit notes
    @State private var notes = ""
    
    // City selection and management
    @Query private var allCities: [City]
    @State private var selectedCities: [CityVisitEntry] = []
    @State private var showAddCity = false
    @State private var editingCityIndex: Int?
    
    private var countryCities: [City] {
        let citiesInCountry = allCities.filter { $0.country?.id == country.id }
        
        // For wishlist mode, only show cities that haven't been visited or wishlisted yet
        if mode == .wishlist {
            return citiesInCountry.filter { $0.wishlistStatus == .notVisited }
        }
        
        return citiesInCountry
    }
    
    private let years = Array(1950...Calendar.current.component(.year, from: Date()))
    
    // Validation
    private var isValidRange: Bool {
        if !isRange { return true }
        
        switch precision {
        case .exact:
            return endDate >= startDate
        case .year:
            return endYear >= startYear
        }
    }
    
    private var canSave: Bool {
        // Can save if the date range is valid
        // Cities are now optional - can save even without cities
        isValidRange
    }
    
    // Duration preview
    private var durationPreview: String? {
        guard isRange else { return nil }
        
        switch precision {
        case .exact:
            let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            if days == 0 { return "Same day" }
            if days == 1 { return "2 days, 1 night" }
            return "\(days + 1) days, \(days) nights"
            
        case .year:
            let years = endYear - startYear
            if years == 0 { return "Same year" }
            if years == 1 { return "2 years" }
            return "\(years + 1) years"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Mode picker
                Section {
                    Picker("Mode", selection: $mode) {
                        ForEach(VisitMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("What would you like to add?")
                }
                
                // Date precision section (only for visits)
                if mode == .visit {
                    Section {
                        Picker("Precision", selection: $precision) {
                            ForEach(DatePrecision.allCases) { p in
                                Text(p.label).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Toggle(isOn: $isRange) {
                            Text(isRange ? precision.rangeLabel : "Single \(precision.label)")
                        }
                        
                        // Date pickers
                        switch precision {
                        case .exact:
                            if isRange {
                                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                    .onChange(of: startDate) { _, newValue in
                                        if endDate < newValue { endDate = newValue }
                                    }
                                
                                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                    .onChange(of: endDate) { _, newValue in
                                        if newValue < startDate { startDate = newValue }
                                    }
                                
                                if let duration = durationPreview {
                                    Text(duration)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                DatePicker("Visit Date", selection: $startDate, displayedComponents: .date)
                            }
                            
                        case .year:
                            if isRange {
                                Picker("Start Year", selection: $startYear) {
                                    ForEach(years.reversed(), id: \.self) {
                                        Text(String($0)).tag($0)
                                    }
                                }
                                .onChange(of: startYear) { _, newValue in
                                    if endYear < newValue { endYear = newValue }
                                }
                                
                                Picker("End Year", selection: $endYear) {
                                    ForEach(years.reversed(), id: \.self) {
                                        Text(String($0)).tag($0)
                                    }
                                }
                                .onChange(of: endYear) { _, newValue in
                                    if newValue < startYear { startYear = newValue }
                                }
                                
                                if startYear == endYear {
                                    Text("Single year: \(startYear)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Range: \(startYear)–\(endYear) (\(endYear - startYear + 1) years)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Picker("Year", selection: $startYear) {
                                    ForEach(years.reversed(), id: \.self) {
                                        Text(String($0)).tag($0)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("When did you visit?")
                    } footer: {
                        if isRange {
                            Text("Select the \(precision.label.lowercased()) range for your trip")
                        }
                    }
                }
                
                // Cities section
                Section {
                    if selectedCities.isEmpty {
                        Text("No cities added yet")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    } else {
                        ForEach(Array(selectedCities.enumerated()), id: \.element.id) { index, entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.city.localizedName(language: selectedLanguage))
                                        .font(.body)
                                    
                                    if mode == .visit {
                                        if let companion = entry.companion, !companion.isEmpty {
                                            Text("With: \(companion)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        if let places = entry.places, !places.isEmpty {
                                            Text(places.joined(separator: ", "))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    } else {
                                        if let wishPlaces = entry.wishlistPlaces, !wishPlaces.isEmpty {
                                            Text(wishPlaces.joined(separator: ", "))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    editingCityIndex = index
                                    showAddCity = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundStyle(.blue)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .onDelete { indexSet in
                            selectedCities.remove(atOffsets: indexSet)
                        }
                    }
                    
                    Button {
                        editingCityIndex = nil
                        showAddCity = true
                    } label: {
                        Label("Add City", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text(mode == .visit ? "Cities Visited (Optional)" : "Cities to Visit (Optional)")
                } footer: {
                    Text("Optionally add cities you \(mode == .visit ? "visited" : "want to visit") in \(country.localizedName(language: selectedLanguage))")
                }
                
                // Notes section
                Section {
                    TextField("Notes about your trip", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Trip Notes (Optional)")
                }
            }
            .navigationTitle(mode == .visit ? "Add Visit" : "Add to Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode == .visit ? "Save" : "Add") {
                        saveTrip()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showAddCity) {
                if let editIndex = editingCityIndex {
                    CityEntrySheet(
                        mode: mode,
                        availableCities: countryCities,
                        selectedLanguage: selectedLanguage,
                        existingEntry: selectedCities[editIndex]
                    ) { updatedEntry in
                        selectedCities[editIndex] = updatedEntry
                        editingCityIndex = nil
                    }
                } else {
                    CityEntrySheet(
                        mode: mode,
                        availableCities: countryCities,
                        selectedLanguage: selectedLanguage,
                        existingEntry: nil
                    ) { newEntry in
                        selectedCities.append(newEntry)
                    }
                }
            }
        }
    }
    
    private func saveTrip() {
        if mode == .visit {
            saveVisit()
        } else {
            saveWishlist()
        }
    }
    
    private func saveVisit() {
        // Determine the date for the country visit
        var visitDate: Date
        
        if selectedCities.isEmpty {
            // No cities selected - use the country-level date selection
            switch precision {
            case .exact:
                visitDate = startDate
            case .year:
                visitDate = Calendar.current.date(from: DateComponents(year: startYear, month: 1, day: 1)) ?? Date()
            }
        } else {
            // Determine the earliest date from all city visits for the country visit
            var earliestDate: Date?
            
            for entry in selectedCities {
                let entryDate: Date?
                
                if let precision = entry.precision {
                    switch precision {
                    case .exact:
                        entryDate = entry.startDate
                    case .year:
                        if let year = entry.startYear {
                            entryDate = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))
                        } else {
                            entryDate = nil
                        }
                    }
                } else {
                    entryDate = nil
                }
                
                if let date = entryDate {
                    if earliestDate == nil || date < earliestDate! {
                        earliestDate = date
                    }
                }
            }
            
            visitDate = earliestDate ?? Date()
        }
        
        // Create country visit
        let countryVisit = CountryVisit(
            country: country,
            date: visitDate,
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(countryVisit)
        
        // Create city visits with individual date information (if any cities were selected)
        for entry in selectedCities {
            let cityVisit: CityVisit
            
            let precision = entry.precision ?? .exact
            let isRange = entry.isRange ?? false
            
            switch precision {
            case .exact:
                if isRange {
                    cityVisit = CityVisit(
                        startDate: entry.startDate ?? Date(),
                        endDate: entry.endDate ?? Date(),
                        companion: entry.companion,
                        note: entry.notes,
                        places: entry.places,
                        city: entry.city,
                        parentCountryVisit: countryVisit
                    )
                } else {
                    cityVisit = CityVisit(
                        date: entry.startDate ?? Date(),
                        companion: entry.companion,
                        note: entry.notes,
                        places: entry.places,
                        city: entry.city,
                        parentCountryVisit: countryVisit
                    )
                }
                
            case .year:
                cityVisit = CityVisit(
                    startYear: entry.startYear ?? Calendar.current.component(.year, from: Date()),
                    endYear: isRange ? (entry.endYear ?? entry.startYear ?? Calendar.current.component(.year, from: Date())) : (entry.startYear ?? Calendar.current.component(.year, from: Date())),
                    companion: entry.companion,
                    note: entry.notes,
                    places: entry.places,
                    city: entry.city,
                    parentCountryVisit: countryVisit
                )
            }
            
            // Insert the city visit - SwiftData will handle the relationships through inverse definitions
            modelContext.insert(cityVisit)
        }
        
        // Save the context
        saveContext()
    }
    
    private func saveWishlist() {
        // Create wishlist entries for each city
        for entry in selectedCities {
            let wishlist = CityWishlist(
                city: entry.city,
                note: entry.notes,
                places: entry.wishlistPlaces
            )
            modelContext.insert(wishlist)
        }
        
        saveContext()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving: \(error)")
        }
    }
}

// MARK: - City Entry Model

struct CityVisitEntry: Identifiable {
    let id = UUID()
    let city: City
    var companion: String?
    var notes: String?
    var places: [String]?
    var wishlistPlaces: [String]?
    
    // Date tracking properties
    var precision: DatePrecision?
    var isRange: Bool?
    var startDate: Date?
    var endDate: Date?
    var startYear: Int?
    var endYear: Int?
}

// MARK: - City Entry Sheet

struct CityEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let mode: AddCountryVisitView.VisitMode
    let availableCities: [City]
    let selectedLanguage: String
    let existingEntry: CityVisitEntry?
    let onSave: (CityVisitEntry) -> Void
    
    @State private var selectedCity: City?
    @State private var companion = ""
    @State private var notes = ""
    @State private var placesText = ""
    
    // Date tracking
    @State private var precision: DatePrecision = .exact
    @State private var isRange: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var startYear: Int
    @State private var endYear: Int
    
    private let years = Array(1950...Calendar.current.component(.year, from: Date()))
    
    init(
        mode: AddCountryVisitView.VisitMode,
        availableCities: [City],
        selectedLanguage: String,
        existingEntry: CityVisitEntry?,
        onSave: @escaping (CityVisitEntry) -> Void
    ) {
        self.mode = mode
        self.availableCities = availableCities
        self.selectedLanguage = selectedLanguage
        self.existingEntry = existingEntry
        self.onSave = onSave
        
        let currentYear = Calendar.current.component(.year, from: Date())
        
        if let entry = existingEntry {
            _selectedCity = State(initialValue: entry.city)
            _companion = State(initialValue: entry.companion ?? "")
            _notes = State(initialValue: entry.notes ?? "")
            
            if mode == .visit {
                _placesText = State(initialValue: entry.places?.joined(separator: ", ") ?? "")
                _precision = State(initialValue: entry.precision ?? .exact)
                _isRange = State(initialValue: entry.isRange ?? false)
                _startDate = State(initialValue: entry.startDate ?? Date())
                _endDate = State(initialValue: entry.endDate ?? Date())
                _startYear = State(initialValue: entry.startYear ?? currentYear)
                _endYear = State(initialValue: entry.endYear ?? currentYear)
            } else {
                _placesText = State(initialValue: entry.wishlistPlaces?.joined(separator: ", ") ?? "")
                _startYear = State(initialValue: currentYear)
                _endYear = State(initialValue: currentYear)
            }
        } else {
            _startYear = State(initialValue: currentYear)
            _endYear = State(initialValue: currentYear)
        }
    }
    
    private var canSave: Bool {
        selectedCity != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("City", selection: $selectedCity) {
                        Text("Select a city").tag(nil as City?)
                        ForEach(availableCities, id: \.id) { city in
                            Text(city.localizedName(language: selectedLanguage))
                                .tag(city as City?)
                        }
                    }
                } header: {
                    Text("City")
                }
                
                if mode == .visit {
                    Section {
                        Picker("Precision", selection: $precision) {
                            ForEach(DatePrecision.allCases) { p in
                                Text(p.label).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Toggle(isOn: $isRange) {
                            Text(isRange ? precision.rangeLabel : "Single \(precision.label)")
                        }
                        
                        // Date pickers
                        switch precision {
                        case .exact:
                            if isRange {
                                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                    .onChange(of: startDate) { _, newValue in
                                        if endDate < newValue { endDate = newValue }
                                    }
                                
                                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                    .onChange(of: endDate) { _, newValue in
                                        if newValue < startDate { startDate = newValue }
                                    }
                            } else {
                                DatePicker("Visit Date", selection: $startDate, displayedComponents: .date)
                            }
                            
                        case .year:
                            if isRange {
                                Picker("Start Year", selection: $startYear) {
                                    ForEach(years.reversed(), id: \.self) {
                                        Text(String($0)).tag($0)
                                    }
                                }
                                .onChange(of: startYear) { _, newValue in
                                    if endYear < newValue { endYear = newValue }
                                }
                                
                                Picker("End Year", selection: $endYear) {
                                    ForEach(years.reversed(), id: \.self) {
                                        Text(String($0)).tag($0)
                                    }
                                }
                                .onChange(of: endYear) { _, newValue in
                                    if newValue < startYear { startYear = newValue }
                                }
                            } else {
                                Picker("Year", selection: $startYear) {
                                    ForEach(years.reversed(), id: \.self) {
                                        Text(String($0)).tag($0)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("When did you visit?")
                    }
                    
                    Section {
                        TextField("Companion", text: $companion)
                    } header: {
                        Text("Travel Companion (Optional)")
                    }
                }
                
                Section {
                    TextField(mode == .visit ? "e.g., Eiffel Tower, Louvre" : "Places you want to visit", text: $placesText, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text(mode == .visit ? "Notable Places (Optional)" : "Wishlist Places (Optional)")
                } footer: {
                    Text("Separate multiple places with commas")
                }
                
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes (Optional)")
                }
            }
            .navigationTitle(existingEntry == nil ? "Add City" : "Edit City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func save() {
        guard let city = selectedCity else { return }
        
        let placesArray = placesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let entry = CityVisitEntry(
            city: city,
            companion: mode == .visit && !companion.isEmpty ? companion : nil,
            notes: !notes.isEmpty ? notes : nil,
            places: mode == .visit && !placesArray.isEmpty ? placesArray : nil,
            wishlistPlaces: mode == .wishlist && !placesArray.isEmpty ? placesArray : nil,
            precision: mode == .visit ? precision : nil,
            isRange: mode == .visit ? isRange : nil,
            startDate: mode == .visit ? startDate : nil,
            endDate: mode == .visit ? endDate : nil,
            startYear: mode == .visit ? startYear : nil,
            endYear: mode == .visit ? endYear : nil
        )
        
        onSave(entry)
        dismiss()
    }
}
