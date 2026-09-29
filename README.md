# My Locks

Minimal SwiftUI iPhone app for recording personal life "locks".

## Database

- Country
- CountryVisit
- City
- CityVisit
- MichelinRestaurant
- RestaurantVisit
- Event
- EventVisit

Country is a first-class entity. City and MichelinRestaurant reference Country instead of duplicating country strings. CountryVisit records individual trips, allowing multiple visits to the same country.

## Requirements

- Xcode 16+
- iOS 17+
- No third-party dependencies

## Project build fix
The Xcode project includes proper PBXBuildFile entries for every Swift source, so the application target produces an executable.
