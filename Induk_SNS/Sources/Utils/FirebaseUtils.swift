//
//  FirebaseUtils.swift
//  Induk_SNS
//
//  Created by 승진김 on 18/12/2018.
//  Copyright © 2018 seungjin. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
            
        }) { (error) in
            print("******************************************************")
            print(" <User 정보 가져오기 실패:> \n\t", error)
            print("******************************************************")
        }
    }
}
