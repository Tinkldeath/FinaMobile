//
//  MediaManager.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//

import Foundation
import FirebaseStorage
import UIKit

typealias ImageCompletionHandler = (UIImage?) -> Void

protocol MediaManager: AnyObject {
    func fetchImage(for uid: String, _ completion: @escaping ImageCompletionHandler)
    func setImage(for uid: String, _ image: UIImage, _ completion: @escaping ImageCompletionHandler)
}

final class FirebaseMediaManager: MediaManager {
    
    private let stroage = Storage.storage().reference()
    
    func fetchImage(for uid: String, _ completion: @escaping ImageCompletionHandler) {
        stroage.child(uid + ".jpg").getData(maxSize: 1024 * 1024) { data, error in
            guard let data = data else { completion(nil); return }
            let image = UIImage(data: data)
            completion(image)
        }
    }
    
    func setImage(for uid: String, _ image: UIImage, _ completion: @escaping ImageCompletionHandler) {
        guard let jpeg = image.jpegData(compressionQuality: 0.5) else { completion(nil); return }
        stroage.child(uid + ".jpg").putData(jpeg) { metadata, error in
            guard metadata != nil && error == nil else { return }
            completion(image)
        }
    }

}
