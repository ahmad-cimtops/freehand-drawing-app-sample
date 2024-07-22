//
//  ViewController.swift
//  freehand-drawing-app-sample
//
//  Created by Ahmad Krisman Ryuzaki on 04/07/24.
//

import UIKit

class ViewController: UIViewController {
    
    private let drawingView = DrawingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiateNavigation()
        initiateDrawingView()
    }
    
    private func initiateNavigation() {
        let segmentedControl = UISegmentedControl(items: ["Basic", "Interpolated", "Fountain", "Calligraphy"])
        segmentedControl.selectedSegmentTintColor = .systemBlue
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(drawingTypeChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearDrawingView(_:)))
        navigationItem.rightBarButtonItem = clearButton
    }
    
    private func initiateDrawingView() {
        drawingView.backgroundColor = .white
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(drawingView)
        NSLayoutConstraint.activate([
            drawingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            drawingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            drawingView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            drawingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    @objc func clearDrawingView(_ barButton: UIBarButtonItem) {
        drawingView.clear()
    }
    
    @objc func drawingTypeChanged(_ control: UISegmentedControl) {
        drawingView.drawingType = DrawingType(rawValue: control.selectedSegmentIndex) ?? .basic
    }
}
