import SwiftUI
import SwiftData

/// Form view for adding transportation to a city visit
struct AddTransportationView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (Transportation) -> Void
    
    @State private var mode: TransportMode = .flight
    @State private var precision: DatePrecision = .exact
    @State private var date = Date()
    @State private var approxYear = Calendar.current.component(.year, from: Date())
    
    @State private var fieldA = ""
    @State private var fieldB = ""
    @State private var fromValue = ""
    @State private var toValue = ""
    
    private let years = Array(1950...Calendar.current.component(.year, from: Date()))
    
    var body: some View {
        NavigationStack {
            Form {
                // Mode selection
                Section {
                    Picker("Mode", selection: $mode) {
                        ForEach(TransportMode.allCases) { m in
                            Label(m.label, systemImage: m.systemImage)
                                .tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Transportation Mode")
                        .textCase(nil)
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                // Mode-specific details
                Section {
                    TextField(fieldALabel, text: $fieldA)
                    
                    // Flight gets an extra field for flight number
                    if mode == .flight {
                        TextField("Flight number (optional)", text: $fieldB)
                    }
                    // Cruise gets ship name
                    else if mode == .cruise {
                        TextField("Ship name (optional)", text: $fieldB)
                    }
                    
                    TextField(fromLabel, text: $fromValue)
                    TextField(toLabel, text: $toValue)
                } header: {
                    Text("Route Details")
                        .textCase(nil)
                }
                .listRowInsets(AddVisitStyles.rowInsets)
                
                // Date/time section
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
                            "Date",
                            selection: $date,
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
                    }
                } header: {
                    Text("When")
                        .textCase(nil)
                }
                .listRowInsets(AddVisitStyles.rowInsets)
            }
            .formStyle(.grouped)
            .environment(\.defaultMinListRowHeight, 0)
            .navigationTitle("Add Transportation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTransportation()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var fieldALabel: String {
        switch mode {
        case .flight: return "Airline (optional)"
        case .train: return "Operator (optional)"
        case .cruise: return "Cruise line (optional)"
        case .car: return "Vehicle type (optional)"
        }
    }
    
    private var fromLabel: String {
        switch mode {
        case .flight: return "From (city or airport)"
        case .train: return "From station"
        case .cruise: return "From port"
        case .car: return "From city"
        }
    }
    
    private var toLabel: String {
        switch mode {
        case .flight: return "To (city or airport)"
        case .train: return "To station"
        case .cruise: return "To port"
        case .car: return "To city"
        }
    }
    
    private func saveTransportation() {
        // Create transportation record with simplified structure
        let transportation = Transportation(
            mode: mode,
            precision: precision,
            date: (precision == .exact) ? date : nil,
            approxYear: (precision == .year) ? approxYear : nil,
            fromLocation: fromValue.isEmpty ? nil : fromValue,
            toLocation: toValue.isEmpty ? nil : toValue,
            carrier: fieldA.isEmpty ? nil : fieldA,
            identifier: fieldB.isEmpty ? nil : fieldB,
            cityVisit: nil  // Will be set by parent view
        )
        
        // Pass to callback
        onSave(transportation)
        dismiss()
    }
}

#Preview {
    AddTransportationView(onSave: { _ in })
}
