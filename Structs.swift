//
//  Structs.swift
//  Token Lexicon
//
//  Created by Iwan on 2022/02/25.
//

import Foundation

struct Messages {
    let id: String
    let name: String
    let proUserId: String
    var latestMessage: LatesMessage
}

struct LatesMessage {
    let date: Date
    let text: String
    let pathToImage: URL
    var isRead: Bool
}
