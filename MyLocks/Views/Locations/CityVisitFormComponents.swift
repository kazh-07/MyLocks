import SwiftUI
import SwiftData

// MARK: - Shared Date Selection Section

struct DateSelectionSection: View {
    @Binding var precision: DatePrecision
    @Binding var isRange: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var startYear: Int
    @Binding var endYear: Int
    
    let years = Array(1950...Calendar.current.component(.year, from: Date()))
    
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
}

// MARK: - Companion Section

struct CompanionSection: View {
    @Binding var companion: String
    
    var body: some View {
        Section {
            TextField("Companion", text: $companion)
        } header: {
            Text("Travel Companion (Optional)")
        }
    }
}

// MARK: - Places Section

struct PlacesSection: View {
    @Binding var placesText: String
    let mode: VisitEntryMode
    
    var body: some View {
        Section {
            TextField(
                mode == .visit ? "e.g., Eiffel Tower, Louvre" : "Places you want to visit",
                text: $placesText,
                axis: .vertical
            )
            .lineLimit(3...6)
        } header: {
            Text(mode == .visit ? "Notable Places (Optional)" : "Wishlist Places (Optional)")
        } footer: {
            Text("Separate multiple places with commas")
        }
    }
}

// MARK: - Transportation Section

struct TransportationSection: View {
    @Binding var transportation: Transportation?
    @Binding var showAddTransportation: Bool
    
    var body: some View {
        Section {
            if let transport = transportation {
                HStack {
                    Label(transport.mode.label, systemImage: transport.mode.systemImage)
                    Spacer()
                    Text(transport.routeSummary)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Button("Edit Transportation") {
                    showAddTransportation = true
                }
                .foregroundStyle(AppColors.label)
            } else {
                Button {
                    showAddTransportation = true
                } label: {
                    Label("Add Transportation", systemImage: "airplane.departure")
                }
            }
        } header: {
            Text("Transportation (Optional)")
        }
    }
}

// MARK: - Notes Section

struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        Section {
            TextField("Notes", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Notes (Optional)")
        }
    }
}

// MARK: - Visit Entry Mode

enum VisitEntryMode {
    case visit
    case wishlist
}

// MARK: - Date Validation Helper

struct DateRangeValidator {
    let precision: DatePrecision
    let isRange: Bool
    let startDate: Date
    let endDate: Date
    let startYear: Int
    let endYear: Int
    
    var isValid: Bool {
        if !isRange { return true }
        
        switch precision {
        case .exact:
            return endDate >= startDate
        case .year:
            return endYear >= startYear
        }
    }
}

// MARK: - Places Parser

struct PlacesParser {
    static func parse(_ text: String) -> [String] {
        text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
