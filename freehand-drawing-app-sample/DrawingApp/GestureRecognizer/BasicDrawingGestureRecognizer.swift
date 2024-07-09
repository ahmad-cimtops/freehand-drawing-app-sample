//
//  FixLineWidthDrawingGestureRecognizer.swift
//  freehand-drawing-app-sample
//
//  Created by Ahmad Krisman Ryuzaki on 08/07/24.
//

import UIKit

/**
 this class is handling touches received by drawing view
 */
class BasicDrawingGestureRecognizer: UIGestureRecognizer {
    
    private var path = CGMutablePath()
    
    // will be triggered when first touch is received
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let drawingView = view as? DrawingView,
              let point = touches.first?.location(in: drawingView) else {
            return
        }
        
        path.move(to: point)
        
    }
    
    // will be triggered when toches moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let drawingView = view as? DrawingView,
              let point = touches.first?.location(in: drawingView) else {
            return
        }
        
        path.addLine(to: point)
        drawingView.drawingPath = path
        drawingView.setNeedsDisplay()
    }
    
    // will be triggered when last touch is received
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let drawingView = view as? DrawingView,
              let point = touches.first?.location(in: drawingView) else {
            return
        }
        
        path.addLine(to: point)
        drawingView.setNeedsDisplay()
    }
    
    // sent to the gesture recognizer when a system event (such as an incoming phone call) cancels a touch event
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }
    
    // overridden to reset internal state when a gesture recognition attempt completes
    override func reset() {
        path = CGMutablePath()
    }
    
}
