//
//  DrawingView.swift
//  freehand-drawing-app-sample
//
//  Created by Ahmad Krisman Ryuzaki on 04/07/24.
//

import UIKit

class DrawingView: UIView {
    
    // drawing path as our virtual ink
    var drawingPath = CGPath(rect: .zero, transform: nil)
    
    // drawing layer instance of CAShapeLayer which is subclass of CALayer
    private var drawingLayer: CAShapeLayer?
    
    // drawing layer configuration
    private let drawingColor: UIColor = .black
    private let lineWidth: CGFloat = 5.0
    
    let basicDrawingGestureRecognizer = BasicDrawingGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func clear() {
        drawingPath = CGPath(rect: .zero, transform: nil)
        basicDrawingGestureRecognizer.reset()
        setNeedsDisplay()
    }
    
    private func commonInit() {
        backgroundColor = .white
        addGestureRecognizer(basicDrawingGestureRecognizer)
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
        drawingLayer.fillColor = UIColor.clear.cgColor
        drawingLayer.strokeColor = drawingColor.cgColor
        drawingLayer.lineWidth = lineWidth
        drawingLayer.path = drawingPath
        
        // we make sure that the drawing layer assignment
        // and adding drawing layer as a sublayer is only happen one time
        if self.drawingLayer == nil {
            self.drawingLayer = drawingLayer
            layer.addSublayer(drawingLayer)
        }
    }
}



