//
//  ConversationModels.swift
//  Chat App
//
//  Created by Ikenna on 9/28/23.
//

import Foundation

struct Conversation
{
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage
{
    let date: String
    let text: String
    let isRead: Bool
}
