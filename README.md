# EXACountryPicker

EXACountryPicker is a country picker controller for iOS8+ with an option to search. The list of countries is based on the ISO 3166 country code standard (http://en.wikipedia.org/wiki/ISO_3166-1). Also and the library includes a set of 250 public domain flag images.

The picker provides:
-   Country Names
-   Country codes - ISO 3166
-   International Dialing Codes
-   Flags

## New (Design + “Smart” features)

### 1) Configuration (Preferred + Recent + Search)

```swift
let picker = EXACountryPicker(style: .grouped)

picker.configuration = EXACountryPickerConfiguration(
    allowedCountryCodes: nil,                // or ["FR", "US", ...]
    preferredCountryCodes: ["FR", "US"],    // pinned section
    showsRecentCountries: true,              // persists last selections
    recentCountriesLimit: 6,
    showsCurrentLocation: true,
    searchMatchesDialingCodeAndISOCode: true
)
```

### 2) Theme (colors/fonts)

```swift
picker.theme = .system // follows dynamic system colors

// or build your own
picker.theme = EXACountryPickerTheme(
    backgroundColor: .systemBackground,
    countryNameFont: UIFont.systemFont(ofSize: 16, weight: .medium),
    countryNameTextColor: .label,
    searchBarBackgroundColor: .secondarySystemBackground
)
```

### 3) Improved search

Search is now diacritics-insensitive and matches:
- country name (prefix and contains)
- ISO code (optional)
- dialing code (optional)

## Screenshots

![alt tag](https://github.com/exaland/EXACountryPicker/blob/master/screen1.png) ![alt tag](https://github.com/exaland/EXACountryPicker/blob/master/screen2.png) ![alt tag](https://github.com/exaland/EXACountryPicker/blob/master/screen3.png)
![alt tag](https://github.com/exaland/EXACountryPicker/blob/master/screen4.png)

*Note: current location is determined from the current region of the iPhone

## Installation

EXACountryPicker is available through [CocoaPods](http://cocoapods.org), to install it simply add the following line to your Podfile:

Swift 5 and later:

    use_frameworks!
     pod 'EXACountryPicker', '~> 1.0.3'
    

### Swift Package Manager

You can also use Swift Package Manager to add EXACountryPicker to your project:

#### Via Xcode:

1. Go to File > Add Packages...
2. Enter the repository URL: `https://github.com/exaland/EXACountryPicker.git`
3. Select the version you want to use
4. Click Add Package

#### Via Package.swift:

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/exaland/EXACountryPicker.git", from: "1.0.3")
]
```

Then add `EXACountryPicker` to your target dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["EXACountryPicker"]
    )
]
```

## SwiftUI

```swift
import SwiftUI
import EXACountryPicker

struct ContentView: View {
    @State private var showPicker = false
    @State private var selected: EXCountry?

    var body: some View {
        Button("Choose country") { showPicker = true }
            .sheet(isPresented: $showPicker) {
                CountryPickerView(
                    isPresented: $showPicker,
                    pickerTitle: "Select a Country",
                    configuration: .init(preferredCountryCodes: ["FR", "US"]),
                    theme: .system,
                    showCallingCodes: true
                ) { country in
                    selected = country
                }
            }
    }
}
```

Push EXACountryPicker from UIViewController

```swift

let picker = EXACountryPicker(style: .grouped)
navigationController?.pushViewController(picker, animated: true)

```
Present EXACountryPicker from UIViewController

```swift

let picker = EXACountryPicker()
let pickerNavigationController = UINavigationController(rootViewController: picker)
self.present(pickerNavigationController, animated: true, completion: nil)

```
## EXACountryPicker properties

```swift

/// delegate
picker.delegate = self

/// Optionally, set this to display the country calling codes after the names
picker.showCallingCodes = true

/// Flag to indicate whether country flags should be shown on the picker. Defaults to true
picker.showFlags = true
    
/// The nav bar title to show on picker view
picker.pickerTitle = "Select a Country"
    
/// The default current location, if region cannot be determined. Defaults to US
picker.defaultCountryCode = "US"

/// Flag to indicate whether the defaultCountryCode should be used even if region can be deteremined. Defaults to false
picker.forceDefaultCountryCode = false

/// The text color of the alphabet scrollbar. Defaults to black
picker.alphabetScrollBarTintColor = UIColor.black
    
/// The background color of the alphabet scrollar. Default to clear color
picker.alphabetScrollBarBackgroundColor = UIColor.clear
    
/// The tint color of the close icon in presented pickers. Defaults to black
picker.closeButtonTintColor = UIColor.black
    
/// The font of the country name list
picker.font = UIFont(name: "Helvetica Neue", size: 15)
    
/// The height of the flags shown. Default to 40px
picker.flagHeight = 40
    
/// Flag to indicate if the navigation bar should be hidden when search becomes active. Defaults to true
picker.hidesNavigationBarWhenPresentingSearch = true
    
/// The background color of the searchbar. Defaults to lightGray
picker.searchBarBackgroundColor = UIColor.lightGray

/// Advanced configuration (preferred/recent/search)
picker.configuration = .default

/// Theme (colors/fonts)
picker.theme = .system

```

## EXACountryPickerDelegate protocol

```swift

func countryPicker(picker: EXACountryPicker, didSelectCountryWithName name: String, code: String) {
        print(code)
}

func countryPicker(picker: EXACountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        print(dialCode)
}

```

## Closure

```swift

// or closure
picker.didSelectCountryClosure = { name, code in
        print(code)
}

picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
        print(dialCode)
}

```
## Supporting Functions

```swift

/// Returns the country flag for the given country code
///
/// - Parameter countryCode: ISO code of country to get flag for
/// - Returns: the UIImage for given country code if it exists
let flagImage =  picker.getFlag(countryCode: code)


/// Returns the country name for the given country code
///
/// - Parameter countryCode: ISO code of country to get dialing code for
/// - Returns: the country name for given country code if it exists
let countryName =  picker.getCountryName(countryCode: code)


/// Returns the country dial code for the given country code
///
/// - Parameter countryCode: ISO code of country to get dialing code for
/// - Returns: the dial code for given country code if it exists
let dialingCode =  picker.getDialCode(countryCode: code)

```
## Author

Alexandre MAGNIER - EXALAND CONCEPT exaland@gmail.com

Core based on work of @mustafaibrahim989

Notes
============

Designed for iOS 13+

## License

EXACountryPicker is available under the MIT license. See the LICENSE file for more info.
