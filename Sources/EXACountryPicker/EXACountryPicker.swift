// The Swift Programming Language
// https://docs.swift.org/swift-book

#if canImport(UIKit)
import UIKit

// SwiftPM resources live in `Bundle.module`. CocoaPods/Carthage typically use `Bundle(for:)`.
private extension Bundle {
    static var exaCountryPickerResources: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: EXACountryPicker.self)
        #endif
    }
}

struct Section {
    var countries: [EXCountry] = []
    mutating func addCountry(_ country: EXCountry) {
        countries.append(country)
    }
}

@objc public protocol EXACountryPickerDelegate: AnyObject {
    @objc optional func countryPicker(_ picker: EXACountryPicker,
                       didSelectCountryWithName name: String,
                       code: String)
    func countryPicker(_ picker: EXACountryPicker,
                                      didSelectCountryWithName name: String,
                                      code: String,
                                      dialCode: String)
}

open class EXACountryPicker: UITableViewController {

    // MARK: - New customization APIs

    /// Advanced configuration (preferred/recent/search). Defaults to `.default`.
    open var configuration: EXACountryPickerConfiguration = .default {
        didSet {
            _sections = nil
            tableView?.reloadData()
        }
    }

    /// Theme (colors/fonts). Defaults to `.default`.
    open var theme: EXACountryPickerTheme = .default {
        didSet {
            applyTheme()
            tableView?.reloadData()
        }
    }

    private var customCountriesCode: [String]?

    // MARK: - Recent persistence

    private var recentCountryCodes: [String] {
        get {
            guard configuration.showsRecentCountries else { return [] }
            return (UserDefaults.standard.array(forKey: configuration.recentCountriesUserDefaultsKey) as? [String]) ?? []
        }
        set {
            guard configuration.showsRecentCountries else { return }
            UserDefaults.standard.set(newValue, forKey: configuration.recentCountriesUserDefaultsKey)
        }
    }

    fileprivate lazy var CallingCodes = { () -> [[String: String]] in
        let resourceBundle = Bundle.exaCountryPickerResources
        guard let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist") else { return [] }
        return NSArray(contentsOfFile: path) as! [[String: String]]
    }()
    fileprivate var searchController: UISearchController!
    fileprivate var filteredList = [EXCountry]()
    fileprivate var unsortedCountries : [EXCountry] {
        let locale = Locale.current
        var unsortedCountries = [EXCountry]()
        let countriesCodes = configuration.allowedCountryCodes ?? customCountriesCode ?? Locale.isoRegionCodes

        for countryCode in countriesCodes {
            guard let displayName = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode) else {
                continue
            }
            let countryData = self.CallingCodes.filter { $0["code"] == countryCode }
            let country: EXCountry

            if countryData.count > 0, let dialCode = countryData[0]["dial_code"] {
                country = EXCountry(name: displayName, code: countryCode, dialCode: dialCode)
            } else {
                country = EXCountry(name: displayName, code: countryCode)
            }
            unsortedCountries.append(country)
        }

        return unsortedCountries
    }

    fileprivate var _sections: [Section]?
    fileprivate var sections: [Section] {

        if _sections != nil {
            return _sections!
        }

        let countries: [EXCountry] = unsortedCountries.map { country in
            let country = EXCountry(name: country.name, code: country.code, dialCode: country.dialCode)
            country.section = collation.section(for: country, collationStringSelector: #selector(getter: EXCountry.name))
            return country
        }

        // create empty sections
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }

        // put each country in a section
        for country in countries {
            sections[country.section!].addCountry(country)
        }

        // sort each section
        for i in 0..<sections.count {
            sections[i].countries = collation.sortedArray(from: sections[i].countries, collationStringSelector: #selector(getter: EXCountry.name)) as! [EXCountry]
        }

        // Optional: Current location section
        if configuration.showsCurrentLocation {
            var countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? self.defaultCountryCode
            if self.forceDefaultCountryCode {
                countryCode = self.defaultCountryCode
            }

            let locale = Locale.current
            if let displayName = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode) {
                let countryData = self.CallingCodes.filter { $0["code"] == countryCode }
                let country: EXCountry

                if countryData.count > 0, let dialCode = countryData[0]["dial_code"] {
                    country = EXCountry(name: displayName, code: countryCode, dialCode: dialCode)
                } else {
                    country = EXCountry(name: displayName, code: countryCode)
                }
                country.section = 0

                sections.insert(Section(), at: 0)
                sections[0].addCountry(country)
            }
        }

        // Preferred section
        if !configuration.preferredCountryCodes.isEmpty {
            let preferred = configuration.preferredCountryCodes
                .compactMap { code in countries.first(where: { $0.code.caseInsensitiveCompare(code) == .orderedSame }) }
            if !preferred.isEmpty {
                var preferredSection = Section()
                preferred.forEach { preferredSection.addCountry($0) }
                sections.insert(preferredSection, at: 0)
            }
        }

        // Recent section
        if configuration.showsRecentCountries {
            let recents = recentCountryCodes
                .compactMap { code in countries.first(where: { $0.code.caseInsensitiveCompare(code) == .orderedSame }) }
            if !recents.isEmpty {
                var recentSection = Section()
                recents.forEach { recentSection.addCountry($0) }
                sections.insert(recentSection, at: 0)
            }
        }

        _sections = sections
        return _sections!
    }

    fileprivate let collation = UILocalizedIndexedCollation.current()
        as UILocalizedIndexedCollation
    open weak var delegate: EXACountryPickerDelegate?
    
    /// Closure which returns country name and ISO code
    open var didSelectCountryClosure: ((String, String) -> ())?
    
    /// Closure which returns country name, ISO code, calling codes
    open var didSelectCountryWithCallingCodeClosure: ((String, String, String) -> ())?
    
    /// Flag to indicate if calling codes should be shown next to the country name. Defaults to false.
    open var showCallingCodes = false
    
    /// Flag to indicate whether country flags should be shown on the picker. Defaults to true
    open var showFlags = true
    
    /// The nav bar title to show on picker view
    open var pickerTitle = "Select a Country"
    
    /// The default current location, if region cannot be determined. Defaults to US
    open var defaultCountryCode = "US"
    
    /// Flag to indicate whether the defaultCountryCode should be used even if region can be deteremined. Defaults to false
    open var forceDefaultCountryCode = false
    
    // The text color of the alphabet scrollbar. Defaults to black
    open var alphabetScrollBarTintColor = UIColor.black
    
    /// The background color of the alphabet scrollar. Default to clear color
    open var alphabetScrollBarBackgroundColor = UIColor.clear
    
    // The tint color of the close icon in presented pickers. Defaults to black
    open var closeButtonTintColor = UIColor.black
    
    /// The font of the country name list
    open var font = UIFont(name: "Helvetica Neue", size: 15)
    
    /// The height of the flags shown. Default to 40px
    open var flagHeight = 40
    
    /// Flag to indicate if the navigation bar should be hidden when search becomes active. Defaults to true
    open var hidesNavigationBarWhenPresentingSearch = true
    
    /// The background color of the searchbar. Defaults to lightGray
    open var searchBarBackgroundColor = UIColor.lightGray
    
    convenience public init(completionHandler: @escaping ((String, String) -> ())) {
        self.init()
        self.didSelectCountryClosure = completionHandler
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = pickerTitle

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        createSearchBar()
        applyTheme()
        tableView.reloadData()

        definesPresentationContext = true

        if self.presentingViewController != nil {

            let bundlePath = "assets.bundle/"
            let closeButton = UIBarButtonItem(image: UIImage(named: bundlePath + "close_icon" + ".png",
                                                             in: Bundle.exaCountryPickerResources,
                                                             compatibleWith: nil),
                                              style: .plain,
                                              target: self,
                                              action: #selector(self.dismissView))
            closeButton.tintColor = theme.closeButtonTintColor ?? closeButtonTintColor
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = closeButton
        }

        tableView.sectionIndexColor = theme.alphabetIndexTintColor ?? alphabetScrollBarTintColor
        tableView.sectionIndexBackgroundColor = theme.alphabetIndexBackgroundColor ?? alphabetScrollBarBackgroundColor
        tableView.separatorColor = theme.separatorColor ?? UIColor(red: (222)/(255.0),
                                                                   green: (222)/(255.0),
                                                                   blue: (222)/(255.0),
                                                                   alpha: 1)
    }

    private func applyTheme() {
        tableView.backgroundColor = theme.backgroundColor
        if let searchColor = theme.searchBarBackgroundColor {
            searchBarBackgroundColor = searchColor
            searchController?.searchBar.barTintColor = searchColor
        }

        if let navTint = theme.navigationBarTintColor {
            navigationController?.navigationBar.tintColor = navTint
        }

        if let titleColor = theme.navigationBarTitleColor {
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: titleColor]
        }

        if let idxTint = theme.alphabetIndexTintColor {
            alphabetScrollBarTintColor = idxTint
        }

        if let idxBg = theme.alphabetIndexBackgroundColor {
            alphabetScrollBarBackgroundColor = idxBg
        }

        if let font = theme.countryNameFont {
            self.font = font
        }

        if let closeTint = theme.closeButtonTintColor {
            self.closeButtonTintColor = closeTint
        }
    }

    // MARK: Methods
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func createSearchBar() {
        if self.tableView.tableHeaderView == nil {
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = self.hidesNavigationBarWhenPresentingSearch
            searchController.searchBar.searchBarStyle = .prominent
            searchController.searchBar.barTintColor = self.searchBarBackgroundColor
            searchController.searchBar.showsCancelButton = false
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    fileprivate func filter(_ searchText: String) -> [EXCountry] {
        filteredList.removeAll()

        let normalizedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedSearch.isEmpty else { return [] }

        let tokens = normalizedSearch
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)

        func normalized(_ value: String) -> String {
            value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        }

        let allCountries = sections.flatMap { $0.countries }

        // scoring: prefix > contains; name > code > dial
        func score(country: EXCountry) -> Int {
            let name = normalized(country.name)
            let code = normalized(country.code)
            let dial = normalized(country.dialCode)

            var s = 0
            for t in tokens {
                if name.hasPrefix(t) { s += 20 }
                else if name.contains(t) { s += 10 }

                if configuration.searchMatchesDialingCodeAndISOCode {
                    if code.hasPrefix(t) { s += 6 }
                    else if code.contains(t) { s += 3 }

                    if dial.hasPrefix(t) { s += 4 }
                    else if dial.contains(t) { s += 2 }
                }
            }
            return s
        }

        let matches = allCountries
            .map { ($0, score(country: $0)) }
            .filter { $0.1 > 0 }
            .sorted {
                if $0.1 != $1.1 { return $0.1 > $1.1 }
                return $0.0.name < $1.0.name
            }
            .map { $0.0 }

        filteredList = matches
        return filteredList
    }
    
    fileprivate func getCountry(_ code: String) -> [EXCountry] {
        filteredList.removeAll()
        
        sections.forEach { (section) -> () in
            section.countries.forEach({ (country) -> () in
                if country.code.count >= code.count {
                    let result = country.code.compare(code, options: [.caseInsensitive, .diacriticInsensitive],
                                                      range: code.startIndex ..< code.endIndex)
                    if result == .orderedSame {
                        filteredList.append(country)
                    }
                }
            })
        }
        
        return filteredList
    }
    
    
    // MARK: - Public method
    
    /// Returns the country flag for the given country code
    ///
    /// - Parameter countryCode: ISO code of country to get flag for
    /// - Returns: the UIImage for given country code if it exists
    public func getFlag(countryCode: String) -> UIImage? {
        let countries = self.getCountry(countryCode)

        if countries.count > 0 {
            let bundlePath = "assets.bundle/"
            return UIImage(named: bundlePath + countries.first!.code.uppercased() + ".png",
                           in: Bundle.exaCountryPickerResources,
                           compatibleWith: nil)
        }
        else {
            return nil
        }
    }
    
    /// Returns the country dial code for the given country code
    ///
    /// - Parameter countryCode: ISO code of country to get dialing code for
    /// - Returns: the dial code for given country code if it exists
    public func getDialCode(countryCode: String) -> String? {
        let countries = self.getCountry(countryCode)
        
        if countries.count > 0 {
            return countries.first?.dialCode
        }
        else {
            return nil
        }
    }
    
    /// Returns the country name for the given country code
    ///
    /// - Parameter countryCode: ISO code of country to get dialing code for
    /// - Returns: the country name for given country code if it exists
    public func getCountryName(countryCode: String) -> String? {
        let countries = self.getCountry(countryCode)
        
        if countries.count > 0 {
            return countries.first?.name
        }
        else {
            return nil
        }
    }
}

// MARK: - Table view data source

extension EXACountryPicker {
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.searchBar.text!.count > 0 {
            return 1
        }
        return sections.count
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if CGFloat(self.flagHeight) < CGFloat(tableView.rowHeight) {
            return CGFloat(max(self.flagHeight, 25))
        }
        
        return max(tableView.rowHeight, CGFloat(self.flagHeight))
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text!.count > 0 {
            return filteredList.count
        }
        return sections[section].countries.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tempCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        
        if tempCell == nil {
            tempCell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        }
        
        let cell: UITableViewCell! = tempCell
        
        let country: EXCountry!
        if searchController.searchBar.text!.count > 0 {
            country = filteredList[(indexPath as NSIndexPath).row]
        } else {
            country = sections[(indexPath as NSIndexPath).section].countries[(indexPath as NSIndexPath).row]
            
        }
        
        cell.textLabel?.font = self.font
        
        if showCallingCodes {
            cell.textLabel?.text = country.name + " (" + country.dialCode + ")"
        } else {
            cell.textLabel?.text = country.name
        }
        
        let bundlePath = "assets.bundle/"

        if self.showFlags == true {
            let image = UIImage(named: bundlePath + country.code.uppercased() + ".png",
                                in: Bundle.exaCountryPickerResources,
                                compatibleWith: nil)
            if (image != nil) {
                cell.imageView?.image = image?.fitImage(size: CGSize(width:self.flagHeight, height:flagHeight))
            }
            else {
                let placeholder = UIImage.ex_solidColor(
                    .lightGray,
                    size: CGSize(width: CGFloat(self.flagHeight), height: CGFloat(flagHeight) / CGFloat(1.5))
                )
                cell.imageView?.image = placeholder.fitImage(
                    size: CGSize(width: CGFloat(self.flagHeight), height: CGFloat(flagHeight) / CGFloat(1.5))
                )
            }
        }
        
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.searchBar.text!.count > 0 {
            return nil
        }

        if !sections[section].countries.isEmpty {
            // top inserted sections order: Recent, Preferred, Current Location (depending on config)
            var dynamicIndex = 0

            if configuration.showsRecentCountries {
                let recents = recentCountryCodes
                if !recents.isEmpty {
                    if section == dynamicIndex { return "Recent" }
                    dynamicIndex += 1
                }
            }

            if !configuration.preferredCountryCodes.isEmpty {
                if section == dynamicIndex { return "Preferred" }
                dynamicIndex += 1
            }

            if configuration.showsCurrentLocation {
                if section == dynamicIndex { return "Current Location" }
                dynamicIndex += 1
            }

            let baseSection = section - dynamicIndex
            if baseSection >= 0, baseSection < self.collation.sectionTitles.count {
                return self.collation.sectionTitles[baseSection] as String
            }
        }

        return ""
    }
    
    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.searchBar.text!.count > 0 {
            return 0
        }
        return sections[section].countries.isEmpty ? 0 : 26
    }
    
    override open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return collation.sectionIndexTitles
    }
    
    override open func tableView(_ tableView: UITableView,
                                 sectionForSectionIndexTitle title: String,
                                 at index: Int)
        -> Int {
            return collation.section(forSectionIndexTitle: index+1)
    }
}

// MARK: - Table view delegate

extension EXACountryPicker {
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country: EXCountry!
        if searchController.searchBar.text!.count > 0 {
            country = filteredList[(indexPath as NSIndexPath).row]
        } else {
            country = sections[(indexPath as NSIndexPath).section].countries[(indexPath as NSIndexPath).row]
        }

        // Persist to recents
        if configuration.showsRecentCountries {
            var recents = recentCountryCodes
                .filter { $0.caseInsensitiveCompare(country.code) != .orderedSame }
            recents.insert(country.code.uppercased(), at: 0)
            if recents.count > configuration.recentCountriesLimit {
                recents = Array(recents.prefix(configuration.recentCountriesLimit))
            }
            recentCountryCodes = recents
            _sections = nil
        }

        delegate?.countryPicker?(self, didSelectCountryWithName: country.name, code: country.code)
        delegate?.countryPicker(self, didSelectCountryWithName: country.name, code: country.code, dialCode: country.dialCode)
        didSelectCountryClosure?(country.name, country.code)
        didSelectCountryWithCallingCodeClosure?(country.name, country.code, country.dialCode)
    }
}

extension EXACountryPicker: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            _ = filter(searchText)
        }

        tableView.reloadData()
    }
}
#endif
