//
//  DateParser.swift
//  CovidWatch-California-Dev
//
//  Created by James Petrie on 2020-07-18.
//  
//

import Foundation

func getDateString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}

// searches the input string and replaces the first substring matching this format:
//          DAYS_FROM_EXPOSURE{LATEST,16,TRUE}
// With a date relative to significant detected exposures
//  1st param: either 'EARLIEST' or 'LATEST', describes whether the earliest or latest significant exposure date should be used
// 2nd param: an integer. The requested date is the exposure date incremented by this many days
// 3rd param: 'TRUE' or 'FALSE'. True means that the requested date is adjusted to not fall on a weekend (Saturday -> Friday and Sunday -> Monday). False means the requested date is left as-is
// Currently only replaces the first pattern matched
// Doesnt handle space between the parameters. "LATEST,16,TRUE" is OK, "LATEST, 16, TRUE" is not
func parseNextStepDescription(description: String) -> String {

    // Search for one string in another.
    let result = description.range(of: #"DAYS_FROM_EXPOSURE\{.*\}"#,
                            options: .regularExpression)

    // See if string was found.
    if let range = result {
        var parsed = description[range].replacingOccurrences(of: "DAYS_FROM_EXPOSURE{", with: "")
        parsed = parsed.replacingOccurrences(of: "}", with: "")

        let delimiter = ","
        let tokens = parsed.components(separatedBy: delimiter)

        if let requestedDate = evaluateRequestedDate(tokens: tokens) {
            let dateString = getDateString(date: requestedDate)
            var parsedDescription = description
            // replace DAYS_FROM_EXPOSURE{*,*,*} with the requested date
            parsedDescription.replaceSubrange(range, with: dateString)
            return parsedDescription
        }
    }
    // return original string
    return description
}

// accepts an array of parsed tokens.
// properly formatted tokens will take the values:
//  tokens[0] = {EARLIEST, LATEST}
//  tokens[1] = {any integer}
//  tokens[2] = {TRUE, FALSE}
// Requires that LocalStore.shared.riskMetrics?.leastRecentSignificantExposureDate
// and LocalStore.shared.riskMetrics?.mostRecentSignificantExposureDate are set
func evaluateRequestedDate(tokens: [String]) -> Date? {
    guard tokens.count == 3 else {
        return nil
    }

    var baseDate: Date?
    if tokens[0] == "LATEST" {
        baseDate = LocalStore.shared.riskMetrics?.mostRecentSignificantExposureDate
    } else if tokens[0] == "EARLIEST" {
        baseDate = LocalStore.shared.riskMetrics?.leastRecentSignificantExposureDate
    }

    if let baseDate = baseDate {
        if let dayOffset = Int(tokens[1]) {
            if let requestedDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: baseDate) {
                if tokens[2] == "TRUE" {
                    let calendar = Calendar(identifier: .gregorian)
                    let components = calendar.dateComponents([.weekday], from: requestedDate)
                    if components.weekday == 1 {
                        // Falls on a sunday so add one day
                        let adjustedDate = Calendar.current.date(byAdding: .day, value: 1, to: requestedDate)
                        return adjustedDate
                    } else if components.weekday == 7 {
                        // Falls on a saturday so subtract one day
                        let adjustedDate = Calendar.current.date(byAdding: .day, value: -1, to: requestedDate)
                        return adjustedDate
                    } else {
                        return requestedDate
                    }
                } else if tokens[2] == "FALSE" {
                    return requestedDate
                }
            }
        }
    }
    return nil
}
