//
//  HomeScreen.swift
//  Saap-Sidi
//
//  Created by home on 24/03/22.
//

import SwiftUI

struct HomeScreen: View {
    let width = UIScreen.main.bounds.width/3
    @State var numOfPlayer = 6
    @State var nav = false
    var body: some View {
        VStack {
            if nav {
                NavigationLink(
                    "", destination: ContentView(players: Array(totalPlayers[0..<numOfPlayer])),
                    isActive: $nav)
                    .position(x: -10, y: -10.0)
            }
            
            Button(action: {
                nav.toggle()
            }, label: {
                Text("Play")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .frame(width: width, height: (width/3)*2)
                    .background(RadialGradient(gradient: Gradient(colors: [Color.white, Color.blue]), center: .init(x: 0.4, y: 0.4), startRadius: 5, endRadius: 70))
                    .cornerRadius(10)
            })
            
            Picker(selection: $numOfPlayer, label: Text("Picker"),
                   content: {
                    ForEach(2..<7, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                   })
                .pickerStyle(InlinePickerStyle())   
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
