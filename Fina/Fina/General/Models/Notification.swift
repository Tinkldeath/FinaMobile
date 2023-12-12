//
//  Notification.swift
//  Fina
//
//  Created by Dima on 12.12.23.
//

import Foundation

struct Notification {
    var uid: String
    var recieverId: String
    var title: String
    var content: String
    var isRead: Bool
}

extension Notification: FirebaseEntity {
    
    static func collection() -> String {
        "notifications"
    }
    
    init?(_ from: [String : Any]) {
        guard let uid = from["uid"] as? String, let recieverId = from["recieverId"] as? String, let title = from["title"] as? String, let content = from["conent"] as? String, let isRead = from["isRead"] as? Bool else { return nil }
        self.uid = uid
        self.recieverId = recieverId
        self.title = title
        self.content = content
        self.isRead = isRead
    }
    
    func toEntity() -> [String : Any] {
        return [
            "uid": uid,
            "recieverId": recieverId,
            "title": title,
            "content": content,
            "isRead": isRead
        ]
    }
}
