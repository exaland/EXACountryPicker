//
//  ADCountry.swift
//  EXACountryPicker
//
//  Created by Alexandre Magnier on 13/02/2026.
//



import UIKit

class EXCountry: NSObject {
    @objc let name: String
    let code: String
    var section: Int?
    let dialCode: String!
    
    init(name: String, code: String, dialCode: String = " - ") {
        self.name = name
        self.code = code
        self.dialCode = dialCode
    }
}
