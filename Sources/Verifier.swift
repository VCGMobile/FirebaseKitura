import Foundation
import SwiftJWT

public protocol Verifier {
  func verify(token: String, allowExpired: Bool) throws -> User?
}

extension Verifier {
  public func verify(token: String) throws -> User? {
    return try verify(token: token, allowExpired: false)
  }
}

public struct JWTVerifier: Verifier {
  public let projectId: String
  public let publicCertificateFetcher: PublicCertificateFetcher
  public init(projectId: String, publicCertificateFetcher: PublicCertificateFetcher = GooglePublicCertificateFetcher()) throws {
    if projectId.isEmpty {
      throw VerificationError(type: .emptyProjectId, message: nil)
    }
    self.projectId = projectId
    self.publicCertificateFetcher = publicCertificateFetcher
  }
  
  public func verify(token: String, allowExpired: Bool = false) throws -> User? {
    guard var jwt = try JWT.decode(token) else {return nil }
    
    assert(jwt.subject == jwt.userId)
    if !allowExpired {
      try jwt.verifyExpirationTime()
    }
    try jwt.verifyAlgorithm()
    try jwt.verifyAudience(with: projectId)
    try jwt.verifyIssuer(with: projectId)
    
    guard let keyIdentifier = jwt.header[.kid] as? String else {
      throw VerificationError(type: .notFound(key: "kid"), message: "Firebase ID token has no 'kid' claim.")
    }
    
    guard let subject = jwt.subject else {
      let message = "Firebase ID token has no 'sub' (subject) claim. \(verifyIdTokenDocsMessage)"
      throw VerificationError(type: .notFound(key: "sub"), message: message)
    }
    guard subject.count <= 128 else {
      let message = "Firebase ID token has 'sub' (subject) claim longer than 128 characters. \(verifyIdTokenDocsMessage)"
      throw VerificationError(type: .incorrect(key: "sub"), message: message)
    }
    
    let cert = try publicCertificateFetcher.fetch(with: keyIdentifier) //.makeBytes().base64Decoded
    print(cert)
    
    guard let publicKey = Data(jwt_base64URLEncodedString: cert, options: []) else {
      throw VerificationError(type: .publicKeyError, message: "Firebase public key cannot be accessed")
    }
    
    //let publicKeyPath = URL(string: "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")!
    //let publicKey = try Data(contentsOf: publicKeyPath)
    let algorithm = Algorithm.rs256(publicKey, .publicKey)
    let signedJWT = try jwt.sign(using: algorithm)
    let verified = try JWT.verify(signedJWT!, using: algorithm)
    
    if verified == false {
      throw VerificationError(type: .publicKeyError, message: "Firebase public key cannot be verified")
    }
    print(User(jwt: jwt))
    return User(jwt: jwt)
  }
}
