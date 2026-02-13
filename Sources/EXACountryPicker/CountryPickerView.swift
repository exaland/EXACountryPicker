import SwiftUI

#if canImport(UIKit)
import UIKit

/// SwiftUI wrapper around `EXACountryPicker`.
@available(iOS 13.0, *)
public struct CountryPickerView: UIViewControllerRepresentable {

    public typealias UIViewControllerType = UINavigationController

    private let configuration: EXACountryPickerConfiguration
    private let theme: EXACountryPickerTheme
    private let showCallingCodes: Bool
    private let showFlags: Bool
    private let pickerTitle: String

    @Binding private var isPresented: Bool
    private let onSelect: (EXCountry) -> Void

    public init(
        isPresented: Binding<Bool>,
        pickerTitle: String = "Select a Country",
        configuration: EXACountryPickerConfiguration = .default,
        theme: EXACountryPickerTheme = .system,
        showCallingCodes: Bool = false,
        showFlags: Bool = true,
        onSelect: @escaping (EXCountry) -> Void
    ) {
        self._isPresented = isPresented
        self.pickerTitle = pickerTitle
        self.configuration = configuration
        self.theme = theme
        self.showCallingCodes = showCallingCodes
        self.showFlags = showFlags
        self.onSelect = onSelect
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        let picker = EXACountryPicker(style: .grouped)
        picker.pickerTitle = pickerTitle
        picker.configuration = configuration
        picker.theme = theme
        picker.showCallingCodes = showCallingCodes
        picker.showFlags = showFlags

        picker.didSelectCountryWithCallingCodeClosure = { [weak coordinator = context.coordinator] name, code, dialCode in
            let country = EXCountry(name: name, code: code, dialCode: dialCode)
            coordinator?.didSelect(country)
        }

        // If calling codes aren’t requested, still support selection.
        picker.didSelectCountryClosure = { [weak coordinator = context.coordinator] name, code in
            let country = EXCountry(name: name, code: code)
            coordinator?.didSelect(country)
        }

        return UINavigationController(rootViewController: picker)
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // no-op for now
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, onSelect: onSelect)
    }

    public final class Coordinator {
        @Binding private var isPresented: Bool
        private let onSelect: (EXCountry) -> Void

        init(isPresented: Binding<Bool>, onSelect: @escaping (EXCountry) -> Void) {
            self._isPresented = isPresented
            self.onSelect = onSelect
        }

        func didSelect(_ country: EXCountry) {
            onSelect(country)
            isPresented = false
        }
    }
}

#else
// This package is iOS-oriented (UIKit). We conditionally compile the SwiftUI wrapper
// so `swift test` on macOS doesn't fail.
#endif
