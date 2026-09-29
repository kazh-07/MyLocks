import SwiftUI

/// Displays a single transportation record with delete functionality
struct TransportationRecord: View {
    let transportation: Transportation
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Header with mode icon and date
            HStack(spacing: AppSpacing.sm) {
                // Mode icon
                Image(systemName: transportation.mode.systemImage)
                    .font(AppFonts.iconSmall)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 24)
                
                // Date
                Text(transportation.displayDateString)
                    .font(AppFonts.bodyEmphasis)
                    .foregroundStyle(AppColors.titleText)
                
                Spacer()
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(AppFonts.iconSmall)
                        .foregroundStyle(AppColors.quaternaryText)
                }
            }
            
            // Route summary
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(AppColors.quaternaryText)
                
                Text(transportation.routeSummary)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            // Mode-specific details
            if let details = transportationDetails {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(AppColors.quaternaryText)
                    
                    Text(details)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppDimensions.radiusMD)
                .fill(AppColors.cardBackground)
        )
    }
    
    private var transportationDetails: String? {
        let hasCarrier = transportation.carrier != nil && !(transportation.carrier?.isEmpty ?? true)
        let hasIdentifier = transportation.identifier != nil && !(transportation.identifier?.isEmpty ?? true)
        
        // Format details based on mode and available information
        switch transportation.mode {
        case .flight:
            // For flights: "Airline FlightNumber" or just "Airline"
            if hasCarrier && hasIdentifier {
                return "\(transportation.carrier!) \(transportation.identifier!)"
            } else if hasCarrier {
                return transportation.carrier
            }
            
        case .train:
            // For trains: "Operator" (identifier could be train number)
            if hasCarrier && hasIdentifier {
                return "\(transportation.carrier!) \(transportation.identifier!)"
            } else if hasCarrier {
                return transportation.carrier
            }
            
        case .cruise:
            // For cruises: "Cruise Line - Ship Name" or just "Cruise Line"
            if hasCarrier && hasIdentifier {
                return "\(transportation.carrier!) - \(transportation.identifier!)"
            } else if hasCarrier {
                return transportation.carrier
            }
            
        case .car:
            // For cars: show vehicle type (identifier) or carrier
            if hasIdentifier {
                return transportation.identifier
            } else if hasCarrier {
                return transportation.carrier
            }
        }
        
        return nil
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        // Flight example
        TransportationRecord(
            transportation: {
                let t = Transportation(
                    mode: .flight,
                    precision: .exact,
                    date: Date(),
                    fromLocation: "San Francisco",
                    toLocation: "Tokyo",
                    carrier: "United",
                    identifier: "UA123"
                )
                return t
            }(),
            onDelete: {}
        )
        
        // Train example
        TransportationRecord(
            transportation: {
                let t = Transportation(
                    mode: .train,
                    precision: .year,
                    approxYear: 2023,
                    fromLocation: "Tokyo",
                    toLocation: "Kyoto",
                    carrier: "JR East"
                )
                return t
            }(),
            onDelete: {}
        )
        
        // Cruise example
        TransportationRecord(
            transportation: {
                let t = Transportation(
                    mode: .cruise,
                    precision: .month,
                    date: Date(),
                    fromLocation: "Miami",
                    toLocation: "Caribbean",
                    carrier: "Royal Caribbean",
                    identifier: "Symphony of the Seas"
                )
                return t
            }(),
            onDelete: {}
        )
        
        // Car example
        TransportationRecord(
            transportation: {
                let t = Transportation(
                    mode: .car,
                    precision: .yearRange,
                    approxYearStart: 2020,
                    approxYearEnd: 2021,
                    fromLocation: "Los Angeles",
                    toLocation: "San Diego",
                    identifier: "Honda Civic"
                )
                return t
            }(),
            onDelete: {}
        )
    }
    .padding()
    .background(AppColors.background)
}
