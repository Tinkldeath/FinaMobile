//
//  CreditScheduleManager.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import FirebaseFirestore

typealias StringArrayClosure = ([String]) -> Void
typealias CreditScheduleCompletionHandler = (CreditSchedule?) -> Void

final class CreditScheduleManager {
    
    let firestore = Firestore.firestore()
    
    func createSchedule(creditId: String, scheduleItems: [CreditSchedule], _ completion: @escaping StringArrayClosure) {
        Task {
            var results = [String]()
            for scheduleItem in scheduleItems {
                let reference = firestore.collection(CreditSchedule.collection()).document()
                var copy = scheduleItem
                copy.creditId =  creditId
                copy.uid = reference.documentID
                try? await reference.setData(copy.toEntity())
                results.append(copy.uid)
            }
            completion(results)
        }
    }
    
    func fetchSchedule(_ uid: String, _ completion: @escaping CreditScheduleCompletionHandler) {
        firestore.collection(CreditSchedule.collection()).document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), let schedule = CreditSchedule(data), error == nil else { completion(nil); return }
            completion(schedule)
        }
    }
    
    func fetchScheduleAsync(_ scheduleIds: [String]) async -> [CreditSchedule] {
        var results = [CreditSchedule?]()
        for scheduleId in scheduleIds {
            guard let documentData = try? await firestore.collection(CreditSchedule.collection()).document(scheduleId).getDocument().data() else { continue }
            let result = CreditSchedule(documentData)
            results.append(result)
        }
        return results.compactMap({ $0 })
    }
    
    func updateSchedule(_ scheduleToUpdate: CreditSchedule, _ completion: BoolClosure? = nil) {
        firestore.collection(CreditSchedule.collection()).document(scheduleToUpdate.uid).updateData(scheduleToUpdate.toEntity()) { error in
            completion?(error == nil)
        }
    }
    
    func deleteSchedule(_ uid: String, _ completion: BoolClosure? = nil) {
        firestore.collection(CreditSchedule.collection()).document(uid).delete { error in
            completion?(error == nil)
        }
    }
}
