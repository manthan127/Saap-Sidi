//
//  PlayerData.swift
//  Saap-Sidi
//
//  Created by home on 24/03/22.
//

import SwiftUI

struct Player: Hashable {
    init(_ n: Int) {
        self.num = n
    }
    var num: Int
    var position: Int = 90
    var color: Color {
        get {
            [Color.blue, .purple, .init(UIColor.brown), .yellow, .init(UIColor.cyan), .orange][num-1]
        }
    }
}

let totalPlayers = [Player(1), Player(2), Player(3), Player(4), Player(5), Player(6)]
