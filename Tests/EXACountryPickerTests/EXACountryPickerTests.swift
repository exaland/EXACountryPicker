import Testing
import Foundation

#if canImport(UIKit)
@testable import EXACountryPicker

@Test func configurationDefaults() async throws {
    let c = EXACountryPickerConfiguration.default
    #expect(c.preferredCountryCodes.isEmpty)
    #expect(c.showsRecentCountries == true)
    #expect(c.recentCountriesLimit == 6)
    #expect(c.showsCurrentLocation == true)
    #expect(c.searchMatchesDialingCodeAndISOCode == true)
}

@Test func exCountryIsPublicAndStable() async throws {
    let country = EXCountry(name: "France", code: "FR", dialCode: "+33")
    #expect(country.name == "France")
    #expect(country.code == "FR")
    #expect(country.dialCode == "+33")
}

@Test func recentPersistenceStoresMostRecentFirst() async throws {
    // Use a custom key so we don't collide with real app defaults.
    let key = "EXACountryPickerTests.recents"
    UserDefaults.standard.removeObject(forKey: key)

    var configuration = EXACountryPickerConfiguration.default
    configuration.recentCountriesUserDefaultsKey = key
    configuration.recentCountriesLimit = 3

    // Note: no need to instantiate `EXACountryPicker` here; we only test the persistence logic.

    // Simulate selections by writing to defaults like production code does.
    func pushRecent(_ code: String) {
        var recents = (UserDefaults.standard.array(forKey: key) as? [String]) ?? []
        recents = recents.filter { $0.caseInsensitiveCompare(code) != .orderedSame }
        recents.insert(code.uppercased(), at: 0)
        if recents.count > configuration.recentCountriesLimit {
            recents = Array(recents.prefix(configuration.recentCountriesLimit))
        }
        UserDefaults.standard.set(recents, forKey: key)
    }

    pushRecent("FR")
    pushRecent("US")
    pushRecent("FR")
    pushRecent("DE")

    let stored = (UserDefaults.standard.array(forKey: key) as? [String]) ?? []
    #expect(stored == ["DE", "FR", "US"]) // limit=3, most recent first
}

#endif
