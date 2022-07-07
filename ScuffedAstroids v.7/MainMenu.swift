//
//  MainMenu.swift
//  ScuffedAstroids v.7
//
//  Created by Mikko Laquindanum on 7/6/22.
//

import SwiftUI
import SpriteKit

struct MainMenu: View {
    
    @StateObject private var vModel = MainMenuViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer ()
                    
                    Text("Doodle Shooter")
                        .font(.custom("Chalkduster", size: 45))
                        .fontWeight(.bold)
                        
                    
//                    Spacer()
                        .padding()
                        .padding()
                        .padding()
                        .padding()
                        .padding()
                        .padding()
                    NavigationLink {
                        ContentView().navigationBarHidden(true).navigationBarBackButtonHidden(true)
                    } label: {
                        Text("Start Game")
                            .foregroundColor(.red)
                    }
                    
                    Text("HighScore: \(vModel.highScore)")
                        .offset(y: 50)
                    
                    Spacer()
                    
                    HStack {
                        Text("MekMillyGaming")
                            .font(.custom("AmericanTypewriter-CondensedLight", size: 20))
                    }
                    
                    Spacer()
//
//                    HStack {
//                        Button {
//
//                        } label: {
//                            Text("zdsf")
//                        }
//                    }
                    
                }
                
//                Text("MekMillyGaming")
//                    .font(.custom("AmericanTypewriter-CondensedLight", size: 20))
                
//                Spacer()
                
            }
            
            .frame(width: 510, height: 1100, alignment: .center)
            .background(Image("CoverArt6.0"))
            .ignoresSafeArea()
            
        }
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}
