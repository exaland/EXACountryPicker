#if canImport(UIKit)
import UIKit

private enum EXACountryPickerL10n {
    static let tableName = "EXACountryPicker"

    static func localized(_ key: String, fallback: String, bundle: Bundle?) -> String {
        let b = bundle ?? .main
        let value = NSLocalizedString(key, tableName: tableName, bundle: b, value: fallback, comment: "")
        return value
    }
}

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
    
    /// Bundle used to resolve localized section titles (defaults to `.main`).
    public var localizationBundle: Bundle?

    /// Localizable.strings table name used to resolve localized section titles.
    /// Defaults to "EXACountryPicker".
    public var localizationTableName: String

    /// Override section titles directly (if set, takes precedence over localization).
    public var preferredTitle: String?
    public var currentLocationTitle: String?
    public var recentTitle: String?

    /// Localization keys (used when override titles are nil).
    public var preferredTitleKey: String
    public var currentLocationTitleKey: String
    public var recentTitleKey: String

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
        closeButtonTintColor: UIColor? = nil,
        localizationBundle: Bundle? = nil,
        localizationTableName: String = "EXACountryPicker",
        preferredTitle: String? = nil,
        currentLocationTitle: String? = nil,
        recentTitle: String? = nil,
        preferredTitleKey: String = "EXACountryPicker.section.preferred",
        currentLocationTitleKey: String = "EXACountryPicker.section.currentLocation",
        recentTitleKey: String = "EXACountryPicker.section.recent"
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
        self.localizationBundle = localizationBundle
        self.localizationTableName = localizationTableName

        self.preferredTitle = preferredTitle
        self.currentLocationTitle = currentLocationTitle
        self.recentTitle = recentTitle

        self.preferredTitleKey = preferredTitleKey
        self.currentLocationTitleKey = currentLocationTitleKey
        self.recentTitleKey = recentTitleKey
    }

    /// Resolved (localized) "Recent" title.
    public func resolvedRecentTitle() -> String {
        if let recentTitle { return recentTitle }
        let b = localizationBundle
        return NSLocalizedString(recentTitleKey, tableName: localizationTableName, bundle: b ?? .main, value: "Recent", comment: "")
    }

    /// Resolved (localized) "Preferred" title.
    public func resolvedPreferredTitle() -> String {
        if let preferredTitle { return preferredTitle }
        let b = localizationBundle
        return NSLocalizedString(preferredTitleKey, tableName: localizationTableName, bundle: b ?? .main, value: "Preferred", comment: "")
    }

    /// Resolved (localized) "Current Location" title.
    public func resolvedCurrentLocationTitle() -> String {
        if let currentLocationTitle { return currentLocationTitle }
        let b = localizationBundle
        return NSLocalizedString(currentLocationTitleKey, tableName: localizationTableName, bundle: b ?? .main, value: "Current Location", comment: "")
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
