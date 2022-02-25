//
//  DatabaseManager.swift
//  Token Lexicon
//
//  Created by Iwan on 2022/02/25.
//

import Foundation

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

extension DatabaseManager {
    
    public func getAllMessages(withMessageTokens: String, withIsRead: String, completion: @escaping (Result<Messages, Error>) -> Void) {
        
        print ("Hello")
        
        let tokens = withMessageTokens
        let isRead = withIsRead
        
        database.child(tokens).child("latestMessage").observe( .value, with: { snapshot in
            
            guard let value = snapshot.value as? [String: AnyObject]
            else {
                print("ERROR")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            guard let author = value["author"] as! String?,
                  let dateString = value["date"] as! String?,
                  let date = SpecificNotificationsViewController.dateFormatter.date(from: dateString),
                  let message = value["message"] as! String?,
                  let messageId = value["messageId"] as! String?,
                  let userId = value["userID"] as! String?
            else{
                print("ERROR HERE")
                return
            }
            
            var read = Bool()
            
            if isRead == "true" {
                read = true
            }
            
            else if isRead == "false" {
                read = false
            }
            
            
            let path = "\(userId)_profile_picture.jpeg"
            
            StorageManager.shared.downloadImage(with: path, completion: { result in
                switch result {
                case .success(let url):
                    let latestMessageObject = LatesMessage(date: date, text: message, pathToImage: url, isRead: read)
                    
                    completion(.success(Messages(id: messageId, name: author, proUserId: userId, latestMessage: latestMessageObject)))
                    
                case .failure(let error):
                    print("Failed to get url: \(error)")
                }
                
            })
            
        })
    }
    
    public func getMessageTokens(withnonSafeEmail: String, completion: @escaping (Result<Messages, Error>) -> Void){
        let email = withnonSafeEmail
        
        var id = email.replacingOccurrences(of: ".", with: "-fullstop-")
        id = id.replacingOccurrences(of: "@", with: "-at-")
        id = id.replacingOccurrences(of: "$", with: "-dollar-")
        id = id.replacingOccurrences(of: "#", with: "-hash-")
        
        database.child(id).child("messageTokens").observe( .childAdded, with: { [weak self] snapshot in
            
            guard let strongSelf = self
            else {
                
                return
            }
            
            guard let tokens = snapshot.key as String?,
                  let reads = snapshot.value as? [String: AnyObject],
                  let isRead = reads["R"] as? String
            else {
                print("ERROR")
                
                return
            }
            
            strongSelf.getAllMessages(withMessageTokens: tokens, withIsRead: isRead, completion: { result in
                
                switch result {
                case .success(let message):
                    completion(.success(message))
                    
                    
                case .failure(let error):
                    completion(.failure(error))
                    print(error)
                    
                }
            })
            
        })
        
    }
    
    public func deliverMessageNotification(withNonSafeEmail: String, recipients: [String], completion: @escaping (Bool) -> Void) {
        let email = withNonSafeEmail
        
        var id = email.replacingOccurrences(of: ".", with: "-fullstop-")
        id = id.replacingOccurrences(of: "@", with: "-at-")
        id = id.replacingOccurrences(of: "$", with: "-dollar-")
        id = id.replacingOccurrences(of: "#", with: "-hash-")
        
        for user in recipients {
            print(user)
            
            let child = ["R" : "false"] as [String : Any?]
            
           database.child(user).child("messageTokens").child(id).updateChildValues(child)
        }
        
        completion(true)
    }
    
}
