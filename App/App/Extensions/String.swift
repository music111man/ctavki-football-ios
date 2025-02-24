//
//  String.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

extension String {
    public func trimHTMLTags() -> String? {
        guard let htmlStringData = self.data(using: String.Encoding.utf8) else {
            return nil
        }
    
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
    
        let attributedString = try? NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
        return attributedString?.string
    }
    
    func replace(_ originalString:String, with newString:String) -> String {
        return self.replacingOccurrences(of: originalString, with: newString)
    }
    
    func regReplace(pattern: String, replaceWith: String = "") -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .anchorsMatchLines])
            let range = NSRange(self.startIndex..., in: self)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return self}
    }
    
    var containsOnlyLettersAndWhitespace: Bool {
                let allowed = CharacterSet.letters.union(.whitespaces)
                return unicodeScalars.allSatisfy(allowed.contains)
            
    }
    
    var isCorrectUserName: Bool {
        if self.count < 3 ||
           self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        
        return containsOnlyLettersAndWhitespace
    }
    var removeDublicateSpaces: String {
        let regexValue = try! NSRegularExpression(pattern: "\\s", options: [])
        return regexValue.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count), withTemplate: " ").trimmingCharacters(in: .whitespaces)
    }
}
