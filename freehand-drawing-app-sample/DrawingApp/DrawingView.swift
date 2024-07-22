//
//  DrawingView.swift
//  freehand-drawing-app-sample
//
//  Created by Ahmad Krisman Ryuzaki on 04/07/24.
//

import UIKit

enum DrawingType: Int {
    case basic = 0
    case interpolated = 1
    case fountain = 2
    case calligraphy = 3
}

class DrawingView: UIView {
    
    // drawing type
    var drawingType: DrawingType = .basic {
        didSet {
            setupDrawingType()
        }
    }
    
    // drawing paths as our virtual ink
    var drawingPaths: [CGPath] = []
    var activePath = CGMutablePath()
    
    // drawing layer instance of CAShapeLayer which is subclass of CALayer
    private var drawingLayer: CAShapeLayer?
    
    // drawing layer configuration
    private let drawingColor: UIColor = .black
    private let lineWidth: CGFloat = 5.0
    
    private let basicDrawingGestureRecognizer = BasicDrawingGestureRecognizer()
    private let interpolatedDrawingGestureRecognizer = InterpolatedDrawingGestureRecognizer()
    private lazy var strokeGestureRecognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func finishActivePath() {
        drawingPaths.append(activePath)
        activePath = CGMutablePath()
        
        basicDrawingGestureRecognizer.reset()
        interpolatedDrawingGestureRecognizer.reset()
        setNeedsDisplay()
    }
    
    func clear() {
        drawingPaths.removeAll()
        activePath = CGMutablePath()
        setNeedsDisplay()
    }
    
    private func commonInit() {
        backgroundColor = .white
        
        addGestureRecognizer(basicDrawingGestureRecognizer)
        addGestureRecognizer(interpolatedDrawingGestureRecognizer)
        addGestureRecognizer(strokeGestureRecognizer)
    }
    
    /**
     this function  is called when a view is first displayed or when an event occurs that invalidates a visible part of the view.
     You should never call this method directly yourself. To invalidate part of your view, and thus cause that portion to be redrawn,
     call the setNeedsDisplay() or setNeedsDisplay(_:) method instead.
     */
    override func draw(_ rect: CGRect) {
        // drawing layer local variable
        let drawingLayer = self.drawingLayer ?? CAShapeLayer()
        
        // here is our drawing environment, we can start to draw our virtual canvas
        // with virtual ink (CGPath) and set the drawing configuration such as color and thickness
        setup(drawingLayer: drawingLayer)
        
        let drawingPath = CGMutablePath()
        drawingPath.addPath(activePath)
        
        for path in drawingPaths {
            drawingPath.addPath(path)
        }
        
        drawingLayer.path = drawingPath
        
        // we make sure that the drawing layer assignment
        // and adding drawing layer as a sublayer is only happen one time
        if self.drawingLayer == nil {
            self.drawingLayer = drawingLayer
            layer.addSublayer(drawingLayer)
        }
    }
    
    private func setupDrawingType() {
        
        basicDrawingGestureRecognizer.isEnabled = false
        interpolatedDrawingGestureRecognizer.isEnabled = false
        strokeGestureRecognizer.isEnabled = false
        
        switch drawingType {
        case .basic:
            basicDrawingGestureRecognizer.isEnabled = true
        case .interpolated:
            interpolatedDrawingGestureRecognizer.isEnabled = true
        case .fountain, .calligraphy:
            strokeGestureRecognizer.isEnabled = true
        }
    }
    
    private func setup(drawingLayer: CAShapeLayer) {
        switch drawingType {
        case .basic, .interpolated:
            drawingLayer.fillColor = UIColor.clear.cgColor
            drawingLayer.strokeColor = drawingColor.cgColor
            drawingLayer.lineWidth = lineWidth
        case .fountain, .calligraphy:
            drawingLayer.fillColor = drawingColor.cgColor
            drawingLayer.strokeColor = drawingColor.cgColor
            drawingLayer.lineWidth = 0
        }
    }
    
    @objc func strokeUpdated(_ strokeGesture: StrokeGestureRecognizer) {
        
        var stroke: Stroke?
        
        if strokeGesture.state != .cancelled {
            stroke = strokeGesture.stroke
        } else {
            activePath = CGMutablePath()
            setNeedsDisplay()
        }
        
        if let stroke = stroke {
            stroke.drawingType = drawingType
            activePath = stroke.toCGPath()
            
            if strokeGesture.state == .ended {
                drawingPaths.append(activePath)
                activePath = CGMutablePath()
            }
            
            setNeedsDisplay()
        }
    }
}



