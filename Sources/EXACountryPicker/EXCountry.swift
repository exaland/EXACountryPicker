//
//  ADCountry.swift
//  EXACountryPicker
//
//  Created by Alexandre Magnier on 13/02/2026.
//



#if canImport(UIKit)
import UIKit

public final class EXCountry: NSObject {
    @objc public let name: String
    public let code: String
    public var section: Int?
    public let dialCode: String

    public init(name: String, code: String, dialCode: String = " - ") {
        self.name = name
        self.code = code
        self.dialCode = dialCode
    }
}
#endif
