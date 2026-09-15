//
//  Item.swift
//  SkySense
//
//  Created by Ketut Agus Cahyadi Nanda on 15/09/26.
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
