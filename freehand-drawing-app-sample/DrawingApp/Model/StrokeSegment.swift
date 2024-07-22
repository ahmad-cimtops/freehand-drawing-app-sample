//
//  StrokeSegment.swift
//  Notator
//
//  Created by Ahmad Krisman Ryuzaki on 12/03/24.
//  Copyright © 2024 CIMTOPS SG LAB Pte. Ltd. All rights reserved.
//

import Foundation

extension Stroke: Sequence {
    func makeIterator() -> StrokeSegmentIterator {
        return StrokeSegmentIterator(stroke: self)
    }
}

class StrokeSegment {
    var sampleBefore: StrokeSample?
    var fromSample: StrokeSample?
    var toSample: StrokeSample?
    var sampleAfter: StrokeSample?
    var fromSampleIndex: Int

    var fromSampleUnitNormal: CGVector {
        return interpolatedNormalUnitVector(between: previousSegmentStrokeVector, and: segmentStrokeVector)
    }

    var toSampleUnitNormal: CGVector {
        return interpolatedNormalUnitVector(between: segmentStrokeVector, and: nextSegmentStrokeVector)
    }

    var previousSegmentStrokeVector: CGVector {
        if let sampleBefore, let fromSample {
            return fromSample.location - sampleBefore.location
        } else {
            return segmentStrokeVector
        }
    }
    
    var segmentStrokeVector: CGVector {
        guard let toSample, let fromSample else {
            return CGVector(dx: 0, dy: 0)
        }
        
        return toSample.location - fromSample.location
    }

    var nextSegmentStrokeVector: CGVector {
        if let sampleAfter, let toSample {
            return sampleAfter.location - toSample.location
        } else {
            return segmentStrokeVector
        }
    }

    init(sample: StrokeSample?) {
        self.sampleAfter = sample
        self.fromSampleIndex = -2
    }
    
    @discardableResult
    func advanceWithSample(incomingSample: StrokeSample?) -> Bool {
        if let sampleAfter = self.sampleAfter {
            self.sampleBefore = fromSample
            self.fromSample = toSample
            self.toSample = sampleAfter
            self.sampleAfter = incomingSample
            self.fromSampleIndex += 1
            return true
        }
        return false
    }
    
    private func interpolatedNormalUnitVector(between vector1: CGVector, and vector2: CGVector) -> CGVector {
        if let result = (vector1.normal + vector2.normal)?.normalized {
            return result
        } else {
            // This means they resulted in a 0,0 vector,
            // in this case one of the incoming vectors is a good result.
            if let result = vector1.normalized {
                return result
            } else if let result = vector2.normalized {
                return result
            } else {
                // This case should not happen.
                return CGVector(dx: 1.0, dy: 0.0)
            }
        }
    }

}

class StrokeSegmentIterator: IteratorProtocol {
    private let stroke: Stroke
    private var nextIndex: Int
    private let sampleCount: Int
    private var segment: StrokeSegment?
    
    init(stroke: Stroke) {
        self.stroke = stroke
        nextIndex = 1
        sampleCount = stroke.samples.count
    
        if sampleCount > 1 {
            segment = StrokeSegment(sample: sampleAt(0))
            segment?.advanceWithSample(incomingSample: sampleAt(1))
        }
    }
    
    func sampleAt(_ index: Int) -> StrokeSample? {
        if index < sampleCount {
            return stroke.samples[index]
        }
        
        return nil
    }
    
    func next() -> StrokeSegment? {
        nextIndex += 1
        if let segment = self.segment {
            if segment.advanceWithSample(incomingSample: sampleAt(nextIndex)) {
                return segment
            }
        }
        return nil
    }
}
