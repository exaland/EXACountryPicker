#if canImport(UIKit)
import UIKit

/// Visual theme for `EXACountryPicker`.
public struct EXACountryPickerTheme: Sendable {
    public var navigationBarTintColor: UIColor?
    public var navigationBarTitleColor: UIColor?

    public var backgroundColor: UIColor?
    public var separatorColor: UIColor?

    public var countryNameFont: UIFont?
    public var countryNameTextColor: UIColor?

    public var callingCodeTextColor: UIColor?

    public var sectionHeaderFont: UIFont?
    public var sectionHeaderTextColor: UIColor?

    public var alphabetIndexTintColor: UIColor?
    public var alphabetIndexBackgroundColor: UIColor?

    public var searchBarBackgroundColor: UIColor?
    public var closeButtonTintColor: UIColor?

    public init(
        navigationBarTintColor: UIColor? = nil,
        navigationBarTitleColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        separatorColor: UIColor? = nil,
        countryNameFont: UIFont? = nil,
        countryNameTextColor: UIColor? = nil,
        callingCodeTextColor: UIColor? = nil,
        sectionHeaderFont: UIFont? = nil,
        sectionHeaderTextColor: UIColor? = nil,
        alphabetIndexTintColor: UIColor? = nil,
        alphabetIndexBackgroundColor: UIColor? = nil,
        searchBarBackgroundColor: UIColor? = nil,
        closeButtonTintColor: UIColor? = nil
    ) {
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationBarTitleColor = navigationBarTitleColor
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
        self.countryNameFont = countryNameFont
        self.countryNameTextColor = countryNameTextColor
        self.callingCodeTextColor = callingCodeTextColor
        self.sectionHeaderFont = sectionHeaderFont
        self.sectionHeaderTextColor = sectionHeaderTextColor
        self.alphabetIndexTintColor = alphabetIndexTintColor
        self.alphabetIndexBackgroundColor = alphabetIndexBackgroundColor
        self.searchBarBackgroundColor = searchBarBackgroundColor
        self.closeButtonTintColor = closeButtonTintColor
    }

    public static var `default`: EXACountryPickerTheme { .init() }

    /// A modern “system” theme that follows iOS dynamic colors.
    public static var system: EXACountryPickerTheme {
        .init(
            backgroundColor: .systemBackground,
            separatorColor: .separator,
            countryNameTextColor: .label,
            callingCodeTextColor: .secondaryLabel,
            sectionHeaderTextColor: .secondaryLabel,
            alphabetIndexTintColor: .secondaryLabel,
            alphabetIndexBackgroundColor: .clear,
            searchBarBackgroundColor: .secondarySystemBackground,
            closeButtonTintColor: .label
        )
    }
}

/// Behavior and content configuration for `EXACountryPicker`.
public struct EXACountryPickerConfiguration: Sendable {
    /// If non-nil, only these ISO region codes will be shown.
    public var allowedCountryCodes: [String]?

    /// Codes pinned at the top in a dedicated section.
    public var preferredCountryCodes: [String]

    /// Enable a “Recent” section and persist selections.
    public var showsRecentCountries: Bool

    /// Maximum number of countries in the “Recent” section.
    public var recentCountriesLimit: Int

    /// UserDefaults key used to persist recent selections.
    public var recentCountriesUserDefaultsKey: String

    /// Show “Current Location” section (based on `Locale.current`).
    public var showsCurrentLocation: Bool

    /// If true, searching will also match dialing code and ISO code.
    public var searchMatchesDialingCodeAndISOCode: Bool

    public init(
        allowedCountryCodes: [String]? = nil,
        preferredCountryCodes: [String] = [],
        showsRecentCountries: Bool = true,
        recentCountriesLimit: Int = 6,
        recentCountriesUserDefaultsKey: String = "EXACountryPicker.recentCountryCodes",
        showsCurrentLocation: Bool = true,
        searchMatchesDialingCodeAndISOCode: Bool = true
    ) {
        self.allowedCountryCodes = allowedCountryCodes
        self.preferredCountryCodes = preferredCountryCodes
        self.showsRecentCountries = showsRecentCountries
        self.recentCountriesLimit = max(0, recentCountriesLimit)
        self.recentCountriesUserDefaultsKey = recentCountriesUserDefaultsKey
        self.showsCurrentLocation = showsCurrentLocation
        self.searchMatchesDialingCodeAndISOCode = searchMatchesDialingCodeAndISOCode
    }

    public static var `default`: EXACountryPickerConfiguration { .init() }
}
#endif
