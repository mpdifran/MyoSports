//
//  MyoEventExtensions.swift
//  MyoSports
//
//  Created by Mark DiFranco on 2015-05-28.
//  Copyright (c) 2015 MDF Projects. All rights reserved.
//

import Foundation

private let separator = ", "
private let carriageReturn = "\n"

extension TLMOrientationEvent {

    func toCSV() -> String {
        let values = [timestamp.timeIntervalSince1970.description,
                      quaternion.w.description,
                      quaternion.x.description,
                      quaternion.y.description,
                      quaternion.z.description]

        return join(separator, values) + carriageReturn
    }
}

extension TLMAccelerometerEvent {

    func toCSV() -> String {
        return toCSV(vector)
    }

    func toCSV(vector: TLMVector3) -> String {
        let values = [timestamp.timeIntervalSince1970.description,
            vector.x.description,
            vector.y.description,
            vector.z.description]

        return join(separator, values) + carriageReturn
    }
}

extension TLMGyroscopeEvent {

    func toCSV() -> String {
        let values = [timestamp.timeIntervalSince1970.description,
                      vector.x.description,
                      vector.y.description,
                      vector.z.description]

        return join(separator, values) + carriageReturn
    }
}

extension TLMEmgEvent {

    func toCSV() -> String {
        var values = [timestamp.timeIntervalSince1970.description]

        for value in rawData {
            values.append(value.description)
        }

        return join(separator, values) + carriageReturn
    }
}
