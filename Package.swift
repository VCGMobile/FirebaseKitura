// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "FirebaseKitura",
  products: [
    .library(
      name: "FirebaseKitura",
      targets: ["FirebaseKitura"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/IBM-Swift/Swift-JWT.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "FirebaseKitura",
      dependencies: ["SwiftJWT"],
      path: "./Sources"
    )
  ]
)


