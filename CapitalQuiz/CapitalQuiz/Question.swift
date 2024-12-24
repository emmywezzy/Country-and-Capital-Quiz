//
//  Question.swift
//  CapitalQuiz
//
//  Created by Emmanuel Yusuf on 2024-10-05.
//

import Foundation

struct Question: Identifiable {
    let id = UUID()
    let country: String
    let capital: String
    let options: [String]
}
