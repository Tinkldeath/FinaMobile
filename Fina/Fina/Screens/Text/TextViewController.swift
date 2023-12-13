//
//  TextViewController.swift
//  mOrganization
//
//  Created by Dima on 12.11.23.
//

import UIKit
import RxCocoa


class TextViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel: TextViewModel?

    override func bind() {
        super.bind()
        
        viewModel?.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel?.text.bind(to: textView.rx.text).disposed(by: disposeBag)
        closeButton.rx.tap.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
    
}
