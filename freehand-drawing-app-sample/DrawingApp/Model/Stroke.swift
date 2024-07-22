//
//  Stroke.swift
//  Notator
//
//  Created by Ahmad Krisman Ryuzaki on 12/03/24.
//  Copyright © 2024 CIMTOPS SG LAB Pte. Ltd. All rights reserved.
//

import UIKit

enum StrokeState: Int {
    case active = 0
    case done = 1
    case cancelled = 2
}


class Stroke {
    
    var state: StrokeState = .active
    var samples: [StrokeSample] = []
    var drawingType: DrawingType = .fountain
    
    static let calligraphyFallbackAzimuthUnitVector = CGVector(dx: 1.0, dy: 1.0).normalized!
    private var lockedAzimuthUnitVector: CGVector?
    private let azimuthLockAltitudeThreshold = CGFloat.pi / 2.0 * 0.80 // locking azimuth at 80% altitude
    
    init(samples: [StrokeSample] = []) {
        self.samples = samples
    }
    
    func add(sample: StrokeSample) {
        samples.append(sample)
    }
    
    func toCGPath() -> CGMutablePath {
        
        let path = CGMutablePath()
        
        for segment in self {
            draw(segment: segment, in: path)
        }
        
        return path
        
    }
    
    func reset() {
        samples.removeAll()

    }
    
    private func draw(segment: StrokeSegment, in path: CGMutablePath) {
        
        guard let toSample = segment.toSample,
              let fromSample = segment.fromSample else {
            return
        }
        
        if drawingType == .fountain {
            drawFountain(segment: segment, in: path, toSample: toSample, fromSample: fromSample)
        }
        
        if drawingType == .calligraphy {
            drawCalligraphy(in: path, toSample: toSample, fromSample: fromSample, forceAccessBlock: forceAccessBlock())
        }
    }
    
    
    private func drawFountain(segment: StrokeSegment, in path: CGMutablePath, toSample: StrokeSample, fromSample: StrokeSample) {
        let forceAccessBlock = self.forceAccessBlock()
        let unitVector = segment.fromSampleUnitNormal
        let fromUnitVector = unitVector * forceAccessBlock(fromSample)
        let toUnitVector = segment.toSampleUnitNormal * forceAccessBlock(toSample)
        
        let topLeftVertex = fromSample.location + fromUnitVector
        let topRightVertex = toSample.location + toUnitVector
        let bottomLeftVertex = toSample.location - toUnitVector
        let bottomRightVertex = fromSample.location - fromUnitVector
        let fromSampleArcRadius = topLeftVertex.calculateDistanceToOtherPoint(otherPoint: fromSample.location)
        
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: fromSample.location, radius: fromSampleArcRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        if segment.toSample?.isLastTouch ?? false {
            let toSampleArcRadius = topRightVertex.calculateDistanceToOtherPoint(otherPoint: toSample.location)
            circlePath.addArc(withCenter: toSample.location, radius: toSampleArcRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        }
        
        let offsetPath = CGMutablePath()
        offsetPath.addLines(between: [
            topLeftVertex,
            topRightVertex,
            bottomLeftVertex,
            bottomRightVertex
        ])
        
        
        let unionCGPath = offsetPath.union(circlePath.cgPath)
        path.addPath(unionCGPath)
    }
    
    func drawCalligraphy(in path: CGMutablePath,
                         toSample: StrokeSample,
                         fromSample: StrokeSample,
                         forceAccessBlock: (_ sample: StrokeSample) -> CGFloat) {

        var fromAzimuthUnitVector = Stroke.calligraphyFallbackAzimuthUnitVector
        var toAzimuthUnitVector = Stroke.calligraphyFallbackAzimuthUnitVector

        if fromSample.azimuth != nil {

            if lockedAzimuthUnitVector == nil {
                lockedAzimuthUnitVector = fromSample.azimuthUnitVector
            }
            fromAzimuthUnitVector = fromSample.azimuthUnitVector
            toAzimuthUnitVector = toSample.azimuthUnitVector
            if fromSample.altitude! > azimuthLockAltitudeThreshold {
                fromAzimuthUnitVector = lockedAzimuthUnitVector!
            }
            if toSample.altitude! > azimuthLockAltitudeThreshold {
                toAzimuthUnitVector = lockedAzimuthUnitVector!
            } else {
                lockedAzimuthUnitVector = toAzimuthUnitVector
            }

        }
        
        // Rotate 90 degrees
        let calligraphyTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
        fromAzimuthUnitVector = fromAzimuthUnitVector.applying(calligraphyTransform)
        toAzimuthUnitVector = toAzimuthUnitVector.applying(calligraphyTransform)

        let fromUnitVector = fromAzimuthUnitVector * forceAccessBlock(fromSample)
        let toUnitVector = toAzimuthUnitVector * forceAccessBlock(toSample)

        path.addLines(between: [
            fromSample.location + fromUnitVector,
            toSample.location + toUnitVector,
            toSample.location - toUnitVector,
            fromSample.location - fromUnitVector
        ])
    }
    
    
    private func forceAccessBlock() -> (_ sample: StrokeSample) -> CGFloat {
        
        var forceMultiplier = CGFloat(2.0)
        var forceOffset = CGFloat(0.1)
        var forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
            return sample.forceWithDefault
        }

        if drawingType == .fountain {
            forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
                return sample.perpendicularForce
            }
        }

        // Make the force influence less pronounced for the calligraphy pen.
        if drawingType == .calligraphy {
            let previousGetter = forceAccessBlock
            forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
                return Swift.max(previousGetter(sample), 1.0)
            }
            // make force value less pronounced
            forceMultiplier = 1.0
            forceOffset = 10.0
        }

        let previousGetter = forceAccessBlock
        forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
            return previousGetter(sample) * forceMultiplier + forceOffset
        }

        return forceAccessBlock
    }
}
