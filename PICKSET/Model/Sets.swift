//
//  Sets.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/20.
//

import Foundation

struct Sets {
    let setText: String
    var votes: Int
    var didPick = false
    let setID: String
    var didSelect = false
    var percentage: Double
//    var percentage: Int
    
    init(setID: String, dictionary: [String: Any]) {
        self.setID = setID
        
        self.setText = dictionary["setText"] as? String ?? ""
        self.votes = dictionary["votes"] as? Int ?? 0
        self.percentage = dictionary["percentage"] as? Double ?? 0
    }
}
