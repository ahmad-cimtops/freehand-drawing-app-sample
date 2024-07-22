//
//  StrokeGestureRecognizer.swift
//  freehand-drawing-app-sample
//
//  Created by Ahmad Krisman Ryuzaki on 22/07/24.
//

import UIKit

class StrokeGestureRecognizer: UIGestureRecognizer {
    var stroke = Stroke()
    var collectForce = false
    
    private var coordinateSpaceView: DrawingView? {
        return view as? DrawingView
    }
    
    var isForPencil: Bool = false
    var fingerStartTimer: Timer?
    let cancellationTimeInterval = TimeInterval(0.1)
    
    var trackedTouch: UITouch?
    var initialTimestamp: TimeInterval?
    
    func append(touches: Set<UITouch>, event: UIEvent?, isLastTouch: Bool = false) -> Bool {
        // Check that we have a touch to append, and that touches
        // doesn't contain it.
        guard let touchToAppend = trackedTouch, touches.contains(touchToAppend) else {
            return false
        }

        // Cancel the stroke recognition if we get a second touch during cancellation period.
        if shouldCancelRecognition(touches: touches, touchToAppend: touchToAppend) {
            if state == .possible {
                state = .failed
            } else {
                state = .cancelled
            }
            return false
        }

        guard let view = coordinateSpaceView else {
            return false
        }
                
        if let event = event, let coalescedTouches = event.coalescedTouches(for: touchToAppend) {
            let lastIndex = coalescedTouches.count - 1
            for index in 0..<lastIndex {
                saveStrokeSample(stroke: stroke, touch: coalescedTouches[index], view: view, coalesced: true,  isLastTouch: isLastTouch)
            }
            saveStrokeSample(stroke: stroke, touch: coalescedTouches[lastIndex], view: view, coalesced: false,  isLastTouch: isLastTouch)
        }

        return true
    }


    func saveStrokeSample(stroke: Stroke, touch: UITouch, view: UIView, coalesced: Bool, isLastTouch: Bool) {
        let location = touch.preciseLocation(in: view)
        if let previousSample = stroke.samples.last {
            if (previousSample.location - location).quadrance < 0.003 {
                return
            }
        }

        var sample = StrokeSample(timestamp: touch.timestamp, location: location, coalesced: coalesced, force: touch.force)
        sample.isLastTouch = isLastTouch
        
        if touch.type == .pencil {
            let estimatedProperties = touch.estimatedProperties
            sample.estimatedProperties = estimatedProperties
            sample.estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates
            sample.altitude = touch.altitudeAngle
            sample.azimuth = touch.azimuthAngle(in: view)
        }

        stroke.add(sample: sample)
        
    }
    
    func shouldCancelRecognition(touches: Set<UITouch>, touchToAppend: UITouch) -> Bool {
        
        guard let initialTimestamp else {
            return true
        }
        
        var shouldCancel = false
        for touch in touches {
            if touch !== touchToAppend &&
                touch.timestamp - initialTimestamp < cancellationTimeInterval {
                shouldCancel = true
                break
            }
        }
        return shouldCancel
    }


    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        if trackedTouch == nil {
            trackedTouch = touches.first
            initialTimestamp = trackedTouch?.timestamp
            collectForce = trackedTouch?.type == .pencil || view?.traitCollection.forceTouchCapability == .available
            if !isForPencil {
                // Give other gestures, such as pan and pinch, a chance by
                // slightly delaying the `.begin.
                fingerStartTimer = Timer.scheduledTimer(
                    withTimeInterval: cancellationTimeInterval,
                    repeats: false,
                    block: { [weak self] (timer) in
                        guard let strongSelf = self else { return }
                        if strongSelf.state == .possible {
                            strongSelf.state = .began
                        }
                    }
                )
            }
        }
        
        if append(touches: touches, event: event) {
            if isForPencil {
                state = .began
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {

        if append(touches: touches, event: event) {
            if state == .began {
                state = .changed
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {

        if append(touches: touches, event: event, isLastTouch: true) {
            stroke.state = .done
            state = .ended
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        
        if append(touches: touches, event: event) {
            stroke.state = .cancelled
            state = .failed
        }
    }

    override func reset() {
        stroke = Stroke()
        trackedTouch = nil
        
        if let timer = fingerStartTimer {
            timer.invalidate()
            fingerStartTimer = nil
        }
        super.reset()
    }
    
}
