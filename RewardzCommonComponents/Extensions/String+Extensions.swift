//
//  String+Extensions.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import Foundation
public extension String {
    func firstCharacterUpperCase() -> String {
        return self.capitalizingFirstLetter()
    }
    private func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func getdateFromStringFrom(dateFormat: String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US")
        if let strDate = dateFormatter.date(from: self)
        {
            return strDate
        }
        return Date()
    }
    
    init?(htmlEncodedString: String) {
        
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        guard let attributedString = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                                                                                   NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
    
    func checkIfRedemptionContainsURL(redemtionCode: String) -> (String?,Bool?) {
        let url = checkForURL(redemtionCode: redemtionCode)
        return (url != nil) ? (String(url!),true) : (redemtionCode,false)
    }
    
    func checkIfPincodeIsPresent(redemtionCode: String) -> (String?,Bool) {
        let getURL = checkForURL(redemtionCode: redemtionCode)
        var pinCode = ""
        if let url = getURL {
            if let endIndex = redemtionCode.range(of: "\(url)")?.upperBound {
                let trimString = String(redemtionCode[endIndex...])
                pinCode = trimString.trimmingCharacters(in: .whitespaces)
            }
        }
        return  !pinCode.isEmpty ? (pinCode,true) : (nil,false)
    }
    
    func checkForURL(redemtionCode: String) -> Substring? {
        let urlDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let urlMatches = urlDetector.matches(in: redemtionCode, options: [], range: NSRange(location: 0, length: redemtionCode.utf16.count))
        var url: Substring?
        for match in urlMatches {
            guard let range = Range(match.range, in: redemtionCode) else { continue }
            url = redemtionCode[range]
        }
        return url
    }
}

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}



