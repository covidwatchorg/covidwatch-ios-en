//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

func generateFakeExposureInfos(
    from startDate: Date,
    to endDate: Date,
    interval: TimeInterval = 60 * 10,
    variation: TimeInterval = 5 * 60
) -> [ENExposureInfo] {
    var entries = [ENExposureInfo]()
    for time in stride(from: startDate.timeIntervalSince1970, to: endDate.timeIntervalSince1970, by: interval) {
        let randomVariation = Double.random(in: -(variation)...(variation))
        let fakeTime = max(startDate.timeIntervalSince1970, min(time + randomVariation, endDate.timeIntervalSince1970))
        entries.append(ENExposureInfo.makeRandom(timestamp: Date(timeIntervalSince1970: fakeTime)))
    }
    return entries
}

func generateFakePositiveDiagnoses(
    from startDate: Date,
    to endDate: Date,
    interval: TimeInterval = 60 * 10,
    variation: TimeInterval = 5 * 60
) -> [PositiveDiagnosis] {
    var entries = [PositiveDiagnosis]()
    for time in stride(from: startDate.timeIntervalSince1970, to: endDate.timeIntervalSince1970, by: interval) {
        let randomVariation = Double.random(in: -(variation)...(variation))
        let fakeTime = max(startDate.timeIntervalSince1970, min(time + randomVariation, endDate.timeIntervalSince1970))
        entries.append(PositiveDiagnosis.makeRandom(timestamp: Date(timeIntervalSince1970: fakeTime)))
    }
    return entries
}
