//
//  ReceiveViewController.swift
//  Token Lexicon
//
//  Created by Iwan on 2022/02/25.
//

import UIKit

class ReceiveViewController: UIViewController {
    
    private var conversations = [Messages]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchlatestMessagesByProUsers()
    }
    
    
    public func fetchlatestMessagesByProUsers() {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String
        else {
            return
        }
        print("Getting data")
        DatabaseManager.shared.getMessageTokens(withnonSafeEmail: email, completion: { [weak self] result in
            switch result {
            case .success(var messages):
                
                let matches = self!.conversations.filter({$0.proUserId == messages.proUserId})
                
                if matches.isEmpty {
                    
                    self?.conversations.append(messages)
                    
                    self?.conversations.sort(by: {$0.latestMessage.date > $1.latestMessage.date})
                    
                    print(self?.conversations as Any)
                                        
                }
                else {
                    print("CAUGHT AN EXISTING CONVERSATION")
                    
                    let convo = self!.conversations.firstIndex(where: { $0.proUserId == messages.proUserId})
                   
                    self?.conversations.remove(at: convo!)
                    messages.latestMessage.isRead = false
                    
                    self?.conversations.insert(messages, at: 0)
                    
                    print("\(messages.latestMessage)")
                }
                
                
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
}
