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
}
