
import Foundation
import SwiftJWT

public struct Firebase {
  public let identities: [String: [String]]
  public let signInProvider: String
  
  init(claim: Claims) {
    if let package = claim["firebase"] as? [String : Any] {
      identities = package["identities"] as? [String : [String]] ?? [:]
      signInProvider = package["sign_in_provider"] as? String ?? ""
    } else {
      identities = [:]
      signInProvider = ""
    }
  }
  
  public init(identities: [String: [String]], signInProvider: String) {
    self.identities = identities
    self.signInProvider = signInProvider
  }
}

public struct User {
  public let id: String
  public let authTime: Date
  public let issuedAtTime: Date
  public let expirationTime: Date
  public let email: String?
  public let emailVerified: Bool?
  public let firebase: Firebase
  
  public init(id: String,
              authTime: Date,
              issuedAtTime: Date,
              expirationTime: Date,
              email: String? = nil,
              emailVerified: Bool? = nil,
              firebase: Firebase = Firebase(identities: [:], signInProvider: "")) {
    self.id = id
    self.authTime = authTime
    self.issuedAtTime = issuedAtTime
    self.expirationTime = expirationTime
    self.email = email
    self.emailVerified = emailVerified
    self.firebase = firebase
  }
  
  public init(jwt: JWT) {
    self.init(id: jwt.userId!,
      authTime: jwt.authTime!,
      issuedAtTime: jwt.issuedAtTime!,
      expirationTime: jwt.expirationTime!,
      email: jwt.email,
      emailVerified: jwt.emailVerified,
      firebase: Firebase(claim: jwt.claims))
  }
}
