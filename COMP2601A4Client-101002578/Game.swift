//
//  Game.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-28.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import Foundation

class Game {
    
    private var observerArray = [Observer]()
    private var _xMoves = [Int]()
    private var _oMoves = [Int]()
    private var _moves = [Int]()
    
    var xMoves : [Int] {
        set {
            _xMoves = newValue
            let val = checkGameOver(arr: xMoves);
            notify(verdict: val, player: 1);
        }
        get {
            return _xMoves;
        }
    }
    
    var oMoves : [Int] {
        set {
            _oMoves = newValue
            let val = checkGameOver(arr: oMoves);
            notify(verdict: val, player: 2);
        }
        get {
            return _oMoves;
        }
    }
    
    var moves : [Int] {
        set {
            _moves = newValue
            let val = isTie(availableMoves: moves);
            notify(verdict: val, player: 3);
        }
        get {
            return _moves;
        }
    }
    
    private func notify(verdict: Int, player: Int) {
        for observer in observerArray {
            observer.didWin(verdict: verdict, player: player);
        }
    }
    
    func attachObserver(observer : Observer){
        observerArray.append(observer)
    }
    
    func checkGameOver(arr: [Int])->Int {
        //This func will check if the game is over (winning conditions)
        let winningConditions = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
        
        for condition in winningConditions {
            if(arr[condition[0]] != 0 && arr[condition[0]] == arr[condition[1]] && arr[condition[1]] == arr[condition[2]]){
                if(arr[condition[0]] == 1){
                    return 1;
                }
            }
        }
        return 0; //Returning 0 means the game is not over
    }
    
    func isTie(availableMoves: [Int])->Int{
        for i in availableMoves {
            if(i == 0){
                return 0
            }
        }
        return 1 //Game is a tie
    }
}
