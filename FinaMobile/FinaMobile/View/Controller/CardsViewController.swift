//
//  CardsViewController.swift
//  FinaMobile
//
//  Created by Dima on 20.09.23.
//

import UIKit

class CardsViewController: UIViewController {

    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}


extension CardsViewController: UICollectionViewDelegateFlowLayout {
    
}

extension CardsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
}
