//
//  BaseLoadingView.swift
//  FinaMobile
//
//  Created by Dima on 9.12.23.
//

import Foundation
import UIKit

class BaseLoadingView: UIView {
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    func displayLoading() {
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        activityIndicatorView.color = .gray
        addSubview(activityIndicatorView)
        activityIndicatorView.center = center
        activityIndicatorView.startAnimating()
    }
    
    func displayEndLoading() {
        activityIndicatorView.removeFromSuperview()
    }
    
}
