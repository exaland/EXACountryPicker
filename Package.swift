// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "EXACountryPicker",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "EXACountryPicker",
      targets: ["EXACountryPicker"]
    )
  ],
  targets: [
    .target(
      name: "EXACountryPicker",
      path: "Sources/EXACountryPicker",
      resources: [
        .process("assets.bundle"),
        .process("CallingCodes.plist")
      ]
    ),
    .testTarget(
      name: "EXACountryPickerTests",
      dependencies: ["EXACountryPicker"]
    )
  ]
)
