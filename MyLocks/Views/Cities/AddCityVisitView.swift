import SwiftUI
import SwiftData

/// Form view for adding a visit to a city
struct AddCityVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let city: City
    
    @State private var precision: DatePrecision = .exact
    @State private var visitDate: Date = Date()
    @State private var approxYear = Calendar.current.component(.year, from: Date())
    @State private var approxYearStart = Calendar.current.component(.year, from: Date())
    @State private var approxYearEnd = Calendar.current.component(.year, from: Date())
    @State private var companion: String = ""
    @State private var notes: String = ""
    @State private var places: String = ""
    
    // Transportation
    @State private var showAddTransportation = false
    @State private var pendingTransportation: Transportation?
    
    private let years = Array(1950...Calendar.current.component(.year, from: Date()))
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Precision", selection: $precision) {
                        ForEach(DatePrecision.allCases) { p in
                            Text(p.label)
                                .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch precision {
                    case .exact:
                        DatePicker(
                            "Visit Date",
                            selection: $visitDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                    case .month:
                        DatePicker(
                            "Month",
                            selection: $visitDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                    case .year:
                        Picker("Year", selection: $approxYear) {
                            ForEach(years.reversed(), id: \.self) { 
                                Text(String($0))
                                    .tag($0) 
                            }
                        }
                        .pickerStyle(.menu)
                    case .yearRange:
                        Picker("From year", selection: $approxYearStart) {
                            ForEach(years.reversed(), id: \.self) { 
                                Text(String($0))
                                    .tag($0) 
                            }
                        }
                        .pickerStyle(.menu)
                        Picker("To year", selection: $approxYearEnd) {
                            ForEach(years.reversed(), id: \.self) { 
                                Text(String($0))
                                    .tag($0) 
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("When did you visit?")
                        .textCase(nil)
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
        
        // Create new visit with appropriate date precision
        let newVisit = CityVisit(
            datePrecision: precision,
            date: (precision == .exact || precision == .month) ? visitDate : nil,
            approxYear: precision == .year ? approxYear : nil,
            approxYearStart: precision == .yearRange ? approxYearStart : nil,
            approxYearEnd: precision == .yearRange ? approxYearEnd : nil,
            companion: companion.isEmpty ? nil : companion,
            note: notes.isEmpty ? nil : notes,
            places: placesArray.isEmpty ? nil : placesArray,
            city: city
        )
        
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
