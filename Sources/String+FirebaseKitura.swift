
import Foundation

extension String {
  func toJSON() -> Any? {
    guard let data = data(using: .utf8) else { return nil }
    return try? JSONSerialization.jsonObject(with: data)
  }
  
  func escaped() -> String {
    var string = ""
    string.reserveCapacity(string.toCharacterSequence().count)
    
    for char in self.toCharacterSequence() {
      switch char {
      case "\"":
        string += "\\\""
      case "\\":
        string += "\\\\"
      case "\t":
        string += "\\t"
      case "\n":
        string += "\\n"
      case "\r":
        string += "\\r"
      default:
        string.append(char)
      }
    }
    
    return string
  }
  
  #if swift(>=4.0)
  internal func toCharacterSequence() -> String {
    return self
  }
  #else
  internal func toCharacterSequence() -> CharacterView {
  return self.characters
  }
  #endif
}
