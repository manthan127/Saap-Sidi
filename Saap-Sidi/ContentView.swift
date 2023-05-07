//
//  ContentView.swift
//  Saap-Sidi
//
//  Created by mac on 02/09/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let players: [Player]
    @ObservedObject var vm = BoardVM()
    
    @State var snackColor: [Color] = Array(repeating: Color.black, count: 5)
    
    @State var path: [Int: CGRect] = [:]
    
    init(players: [Player]) {
        self.players = players
        
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("<Back")
                            .padding(.leading, 12)
                            .padding(.bottom, 13)
                    })
                    Spacer()
                }
                .frame(height: 50)
                
                VStack {
                    board
                    Spacer()
                }
                .offset(y: 50)
                
                objects
                    .ignoresSafeArea()
                
                piece
                
                if vm.winner.count != 0 {
                    arrShow(arr: vm.winner)
                }
                
            }
            diceView
        }
        .navigationBarHidden(true)
        .onAppear {
            vm.players = players
            vm.reset()
        }
        .alert(isPresented: $vm.win, content: {
            Alert(title: Text("Player" + vm.winner.map{"\($0.num) "}.reduce("", +) + "won"),
                  primaryButton: .default(Text("Home screen"), action: {
                    presentationMode.wrappedValue.dismiss()
                  }),
                  secondaryButton: .default(Text("play again"), action: {
                    vm.players = players
                    vm.reset()
                  }))
        })
    }
    
    var board: some View {
        VStack(spacing: 0) {
            ForEach((0...9).reversed(), id: \.self) { i in
                HStack(spacing: 0) {
                    let r = i % 2 == 0 ? Array(0...9) : (0...9).reversed()
                    ForEach(r , id: \.self) { j in
                        let x = ind(i: i, j: j)
                        cell(x)
                    }
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .padding(4)
        .background(Color.gray)
        .padding(2)
    }
    func cell(_ x: Int)-> some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor((x%2 == 0 ? .red : .white))
                .padding(1)
                .overlay(
                    Text("\(x)")
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .onAppear{
                            path[x] = geo.frame(in: .global)
                        }
                )
                .padding(1)
        }
    }
    
    
    var objects: some View {
        Group {
            ForEach(vm.ladders, id: \.0) { l in
                let vals = val(l: l)
                Capsule()
                    .overlay(
                        Image("ladder")
                            .resizable(resizingMode: .tile)
                    )
                    .foregroundColor(Color.clear)
                    .rotationEffect(Angle(radians: Double(vals.2)))
                    .frame(width: vals.1.width, height: vals.1.height)
                    .position(vals.0)
//                let (start, end, size) = (vm.path[l.0] ?? .zero, vm.path[l.1] ?? .zero, vm.path[l.1]?.size.height ?? .zero)
//                Circle()
//                    .foregroundColor(Color.green.opacity(0.5))
//                    .frame(width: size, height: size)
//                    .offset(x: start.origin.x, y: start.origin.y)
//                Circle()
//                    .foregroundColor(Color.blue.opacity(0.5))
//                    .frame(width: size, height: size)
//                    .offset(x: end.origin.x, y: end.origin.y)
            }
            
            ForEach(vm.snacks.indices, id: \.self) { l in
                let vals = val(l: vm.snacks[l])
                Image("snake")
                    .resizable(capInsets: EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 11), resizingMode: .tile)
                    .renderingMode(.template)
                    .foregroundColor(snackColor[l].opacity(0.8))
                    .rotationEffect(Angle(radians: Double(vals.2)))
                    .frame(width: vals.1.width, height: vals.1.height)
                    .position(vals.0)
                    .onAppear {
                        snackColor[l] = Color(hue: Double.random(in: 0.2...0.8), saturation: 1, brightness: 1)
                    }
            }
        }
    }
    
    var piece: some View {
        let positionToPlayer = vm.players.reduce(into: [Int: [Player]]()) { (dic, data) in
            dic[data.position, default: []] += [data]
        }
        
        return Group {
            ForEach(vm.players.indices, id: \.self) { pInd in
                let player = vm.players[pInd]
                
                let playersAtPos = positionToPlayer[player.position]!
                
                let pPath = path[player.position] ?? .zero
                
                
                let pieceSize = pPath.width/CGFloat(playersAtPos.count)
                
                let cpInd = CGFloat(playersAtPos.firstIndex(where: {
                    player == $0
                })!)
                let dif = CGFloat(playersAtPos.count - 1)/2
                
                let offset = pieceSize * (cpInd - dif)
                
                Circle()
                    .fill(player.color)
                    .frame(width: pieceSize, height: pieceSize)
                    .position(x: pPath == .zero ? -500 : pPath.midX,
                              y: pPath.midY)
                    .offset(x: offset)
            }
        }
        .animation(.easeIn)
        .ignoresSafeArea()
    }
    
    func arrShow(arr: [Player]) -> some View {
        let s = path[arr[0].position] ?? .zero
        return Group {
            ForEach(arr.indices, id:\.self) { pInd in
                Circle()
                    .fill(arr[pInd].color)
                    .frame(width: s.size.width, height: s.size.height)
                    .scaleEffect(1/CGFloat(arr.count))
                    .offset(y: arr.count == 1 ? 0 : s.size.height/4)
                    .rotationEffect(Angle(degrees: Double(pInd * 360/arr.count)))
            }
        }
        .offset(x: s.origin.x, y: s.origin.y)
        .animation(.easeIn)
        .ignoresSafeArea()
    }
    
    var diceView: some View {
        Button(action: {
            vm.moving()
        }, label: {
            Image("dice\(vm.dice)")
                .renderingMode(.template)
                .foregroundColor(vm.players[vm.playerIndex].color)
        })
        .disabled(vm.disableDice)
        .padding(.bottom)
    }
    
    
    func val(l: (Int, Int)) -> (CGPoint, CGSize, rot: CGFloat) {
        let (start, end, size) = (path[l.0] ?? .zero, path[l.1] ?? .zero, path[l.1]?.size.height ?? .zero)
        let sumSub = start ± end
        let ang = atan(sumSub.1.y/sumSub.1.x)
        //        print(l.0, ang)
        return (.init(x: (sumSub.0.x + size) / 2, y: (sumSub.0.y + size) / 2),
                CGSize(width: hypot(sumSub.1.x, sumSub.1.y), height: size), ang)
    }
    
    func ind(i: Int, j: Int) -> Int {
        i*10 + j + 1
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(players: Array(totalPlayers[0..<6]))
        }
    }
}
