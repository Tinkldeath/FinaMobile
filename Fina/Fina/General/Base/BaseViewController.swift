//
//  BaseViewController.swift
//  FinaMobile
//
//  Created by Dima on 4.12.23.
//

import UIKit


class BaseViewController: UIViewController {
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        return gesture
    }()
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    var coordinator: AppCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupView()
        bind()
    }
    
    func addTouchDismissGesture() {
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupView() {  }
    
    func bind() {  }
    
    func configure() {  }
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    func displayLoading() {
        view.alpha = 0.5
        view.isUserInteractionEnabled = false
        view.addSubview(activityIndicatorView)
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        activityIndicatorView.color = .gray
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()
    }
    
    func displayEndLoading() {
        view.alpha = 1.0
        view.isUserInteractionEnabled = true
        activityIndicatorView.removeFromSuperview()
    }
}


class BaseInputViewController: BaseViewController {
    
    override func setupView() {
        super.setupView()
        
        addTouchDismissGesture()
    }
    
}
