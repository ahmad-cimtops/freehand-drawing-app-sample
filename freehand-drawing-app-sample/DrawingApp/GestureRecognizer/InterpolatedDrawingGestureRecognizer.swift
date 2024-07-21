//
//  InterpolatedDrawingGestureRecognizer.swift
//  freehand-drawing-app-sample
//
//  Created by Ahmad Krisman Ryuzaki on 09/07/24.
//

import UIKit

class InterpolatedDrawingGestureRecognizer: UIGestureRecognizer {
    
    private var path = CGMutablePath()
    private var temporaryPath: CGMutablePath?
    private var points: [CGPoint] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let drawingView = view as? DrawingView,
              let point = touches.first?.location(in: drawingView) else {
            return
        }
        
        points.removeAll()
        points.append(point)
        path.move(to: point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let drawingView = view as? DrawingView,
              let point = touches.first?.location(in: drawingView) else {
            return
        }
        
        points.append(point)
        updatePaths()
        
        let mainPath = CGMutablePath()
        mainPath.addPath(path)
        
        if let tempPath = temporaryPath {
            mainPath.addPath(tempPath)
        }
        
        drawingView.activePath = mainPath
        drawingView.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let drawingView = view as? DrawingView else {
            return
        }
        
        drawingView.finishActivePath()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }
    
    override func reset() {
        path = CGMutablePath()
        points.removeAll()
    }
    
    private func updatePaths() {
        
        // update main path
        while points.count > 4 {
            
            points[3] = CGPoint(x: (points[2].x + points[4].x)/2.0, y: (points[2].y + points[4].y)/2.0)
            path.addCurve(to: points[3], control1: points[1], control2: points[2])
            points.removeFirst(3)
            temporaryPath = nil
        }
        
        // build temporary path up to last touch point
        switch points.count {
        case 2:
            temporaryPath = newTemporaryPath(at: points[0])
            temporaryPath?.addLine(to: points[1])
            break
        case 3:
            temporaryPath = newTemporaryPath(at: points[0])
            temporaryPath?.addQuadCurve(to: points[2], control: points[1])
            break
        case 4:
            temporaryPath = newTemporaryPath(at: points[0])
            temporaryPath?.addCurve(to: points[3], control1: points[1], control2: points[2])
            break
        default:
            break
        }
    }

    private func newTemporaryPath(at point: CGPoint) -> CGMutablePath {
        let localPath = CGMutablePath()
        localPath.move(to: point)
        return localPath
    }
    
}
