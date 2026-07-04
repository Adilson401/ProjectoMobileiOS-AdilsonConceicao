//
//  Item.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
