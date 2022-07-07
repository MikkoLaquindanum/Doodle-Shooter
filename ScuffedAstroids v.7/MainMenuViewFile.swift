//
//  MainMenuViewFile.swift
//  ScuffedAstroids v.7
//
//  Created by Mikko Laquindanum on 7/7/22.
//

import Foundation

class MainMenuViewModel: ObservableObject {
    
    @Published var highScore = 0
     let highScoreKey = "ScuffedAstroids"
//    var highScoreUserDefault = UserDefaults.standard.set(0, forKey: "ScuffedAstroids")
    
    init() {
        highScore = highScoreValue()
        
//        highScore = highScoreUserDefault.self
        
    }
    
    func highScoreValue() -> Int {
        UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
     func setHighScoreValue(to value: Int) {
        UserDefaults.standard.set(value, forKey: highScoreKey)
    }
    
    func compareScores(currentScore: Int) {
        if highScoreValue() < currentScore {
            setHighScoreValue(to: currentScore)
        }
    }
        
    
}
