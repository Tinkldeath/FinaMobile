//
//  BaseLoadingViewModel.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation
import RxRelay

class BaseLoadingViewModel {
    let loadingRelay = PublishRelay<Void>()
    let endLoadingRelay = PublishRelay<Void>()
}
