//
//  StrokeSample.swift
//  Notator
//
//  Created by Ahmad Krisman Ryuzaki on 12/03/24.
//  Copyright © 2024 CIMTOPS SG LAB Pte. Ltd. All rights reserved.
//

import UIKit

struct StrokeSample {
    var isLastTouch = false
    var timestamp: TimeInterval
    var location: CGPoint
    var force: CGFloat?
    var estimatedProperties: UITouch.Properties = []
    var estimatedPropertiesExpectingUpdates: UITouch.Properties = []
    var altitude: CGFloat?
    var azimuth: CGFloat?
    
    let coalesced: Bool
    let predicted: Bool
    
    var azimuthUnitVector: CGVector {
        var vector = CGVector(dx: 1.0, dy: 0.0)
        if let azimuth = self.azimuth {
            vector = vector.applying(CGAffineTransform(rotationAngle: azimuth))
        }
        return vector
    }
    
    init(isLastTouch: Bool = false,
         timestamp: TimeInterval = Date.timeIntervalSinceReferenceDate,
         location: CGPoint,
         coalesced: Bool,
         predicted: Bool = false,
         force: CGFloat? = nil,
         azimuth: CGFloat? = nil,
         altitude: CGFloat? = nil,
         estimatedProperties: UITouch.Properties = [],
         estimatedPropertiesExpectingUpdates: UITouch.Properties = []) {

        self.isLastTouch = isLastTouch
        self.timestamp = timestamp
        self.location = location
        self.force = force
        self.coalesced = coalesced
        self.predicted = predicted
        self.altitude = altitude
        self.azimuth = azimuth
    }

    var forceWithDefault: CGFloat {
        return force ?? 1.0
    }

    var perpendicularForce: CGFloat {
        let force = forceWithDefault
        if let altitude = altitude {
            let result = force / CGFloat(sin(Double(altitude)))
            return result
        } else {
            return force
        }
    }
}

