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
        isValidRange
    }
    
    // Duration preview for ranges
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
                Section {
                    // Precision picker
                    Picker("Precision", selection: $precision) {
                        ForEach(DatePrecision.allCases) { p in
                            Text(p.label)
                                .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Range toggle
                    Toggle(isOn: $isRange) {
                        Text(isRange ? precision.rangeLabel : "Single \(precision.label)")
                    }
                    
                    // Date pickers based on precision and range
                    switch precision {
                    case .exact:
                        if isRange {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .onChange(of: startDate) { _, newValue in
                                    if endDate < newValue { endDate = newValue }
                                }
                            
                            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .onChange(of: endDate) { _, newValue in
                                    if newValue < startDate { startDate = newValue }
                                }
                            
                            // Duration preview
                            if let duration = durationPreview {
                                Text(duration)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            DatePicker("Visit Date", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                        
                    case .year:
                        if isRange {
                            Picker("Start Year", selection: $startYear) {
                                ForEach(years.reversed(), id: \.self) {
                                    Text(String($0)).tag($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: startYear) { _, newValue in
                                if endYear < newValue { endYear = newValue }
                            }
                            
                            Picker("End Year", selection: $endYear) {
                                ForEach(years.reversed(), id: \.self) {
                                    Text(String($0)).tag($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: endYear) { _, newValue in
                                if newValue < startYear { startYear = newValue }
                            }
                            
                            // Preview
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
                            .pickerStyle(.menu)
                        }
                    }
                } header: {
                    Text("When did you visit?")
                        .textCase(nil)
                } footer: {
                    if isRange {
                        Text("Select the \(precision.label.lowercased()) range for your visit")
                            .font(.caption)
                    }
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                Section {
                    TextField("Companion", text: $companion)
                } header: {
                    Text("Who did you visit with? (Optional)")
                        .textCase(nil)
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                Section {
                    TextField("e.g., Bund, Yu Garden, French Concession", text: $places, axis: .vertical)
                        .lineLimit(AddVisitStyles.dishesLineLimit)
                } header: {
                    Text("Notable Places (Optional)")
                        .textCase(nil)
                } footer: {
                    Text("List any memorable places you visited")
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                // Transportation section
                Section {
                    if let transport = pendingTransportation {
                        HStack {
                            Label(transport.mode.label, systemImage: transport.mode.systemImage)
                            Spacer()
                            Text(transport.routeSummary)
                                .foregroundStyle(.secondary)
                        }
                        
                        Button("Edit Transportation") {
                            showAddTransportation = true
                        }
                        .foregroundStyle(.blue)
                    } else {
                        Button {
                            showAddTransportation = true
                        } label: {
                            HStack {
                                Image(systemName: "airplane.departure")
                                Text("Add Transportation")
                            }
                        }
                    }
                } header: {
                    Text("Transportation (Optional)")
                        .textCase(nil)
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
        let placesArray = places
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
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
                    city: city
                )
            } else {
                newVisit = CityVisit(
                    date: startDate,
                    companion: companion.isEmpty ? nil : companion,
                    note: notes.isEmpty ? nil : notes,
                    places: placesArray.isEmpty ? nil : placesArray,
                    city: city
                )
            }
            
        case .year:
            newVisit = CityVisit(
                startYear: startYear,
                endYear: isRange ? endYear : startYear,
                companion: companion.isEmpty ? nil : companion,
                note: notes.isEmpty ? nil : notes,
                places: placesArray.isEmpty ? nil : placesArray,
                city: city
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
