//
//  BoardVM.swift
//  Saap-Sidi
//
//  Created by home on 24/03/22.
//

import SwiftUI

class BoardVM: ObservableObject {
    @Published var dice = 1
    
    @Published var winner: [Player] = []
    @Published var players: [Player] = totalPlayers
    
    @Published var win = false
    @Published var playerIndex = 0
    @Published var disableDice:Bool = false
    
    @Published var ladders: [(Int, Int)] = []
    @Published var snacks: [(Int, Int)] = []
    
    init(){}
    init(players: [Player]) {
        
    }
    // MARK:- Create
    
    func setObjects() {
        var ladders: [(Int, Int)] = []
        var snacks: [(Int, Int)] = []
        (0..<5).forEach{ _ in
            var x = (2...99).randomElement()!
            while ladders.contains(where: { $0.0 == x || $0.1 == x }) {
                x = (2...99).randomElement()!
            }
            
            while true {
                let y = (2...99).randomElement()!
                if (x-1) / 10 != (y-1) / 10, !ladders.contains(where: { $0.0 == y || $0.1 == y }) {
                    ladders.append((min(x,y), max(x,y)))
                    break
                }
            }
        }
        (0..<5).forEach{ _ in
            var x = (2...99).randomElement()!
            while ladders.contains(where: { $0.0 == x || $0.1 == x }) || snacks.contains(where: { $0.0 == x || $0.1 == x }) {
                x = (2...99).randomElement()!
            }
            
            while true {
                let y = (2...99).randomElement()!
                if (x-1) / 10 != (y-1) / 10, !ladders.contains(where: { $0.0 == y || $0.1 == y }), !snacks.contains(where: { $0.0 == y || $0.1 == y }) {
                    snacks.append((min(x,y), max(x,y)))
                    break
                }
            }
        }
        self.ladders = ladders
        self.snacks = snacks
    }
    
    // MARK:- Play
    func moving() {
        disableDice = true
        dice = Int.random(in: 1..<7)
        guard players[playerIndex].position + dice <= 100 else {
            nextPlayer()
            return
        }
        
        for i in 1...dice {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2 * Double(i)) { [self] in
                
                withAnimation(Animation.linear(duration: 0.2)) {
                    self.players[self.playerIndex].position += 1
                }
                guard i == dice else {return}
                if players[playerIndex].position == 100 {
                    winner.append(players[playerIndex])
                    players.remove(at: playerIndex)
                    nextPlayer()
                    win = players.count == 1
                    return
                }
                if let pos = climbAndFall() {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        withAnimation(Animation.linear(duration: 0.5)) {
                            players[playerIndex].position = pos
                        }
                        if dice != 6 {
                            nextPlayer()
                        }
                        disableDice = false
                    }
                } else {
                    if dice != 6 {
                        nextPlayer()
                    }
                    disableDice = false
                }
            }
        }
    }
    
    func climbAndFall() -> Int? {
        for i in snacks.indices {
            if players[playerIndex].position == snacks[i].1 {
                return snacks[i].0
            }
        }
        
        for i in ladders.indices {
            if players[playerIndex].position == ladders[i].0 {
                return ladders[i].1
            }
        }
        return nil
    }
    
    func nextPlayer() {
        playerIndex = playerIndex+1
        if playerIndex >= players.count {
            playerIndex = 0
        }
        disableDice = false
    }
    
    func reset() {
        winner = []
        win = false
        playerIndex = 0
        setObjects()
    }
}
