//
//  SendViewController.swift
//  Token Lexicon
//
//  Created by Iwan on 2022/02/25.
//

import UIKit

class SendViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func sendNotification(withUsers: [String]) {
        
        let email = UserDefaults.standard.value(forKey: "email") as! String
        
        DatabaseManager.shared.deliverMessageNotification(withNonSafeEmail: email, myFollowers: withUsers, completion: { result in
            switch result {
            case true:
                print("Sent Notifications")
            case false:
                print("Failed to send notifications")
            }
            
        })
    }
}
