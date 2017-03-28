//
//  GameViewController.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-28.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import Foundation
import UIKit

//Images are in the Assets.xcassets folder!!!
class GameViewController: UIViewController, Observer {
    
    let game: Game = Game();
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    @IBOutlet weak var btn8: UIButton!
    @IBOutlet weak var btn9: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var compSwitch: UISwitch!
    @IBOutlet weak var showText: UILabel!
    
    var playerTurn: Bool = true;
    var gameStarted: Bool = false;
    var moves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    var xMoves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    var oMoves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    
    var gameActive = true;
    let bgqueue = DispatchQueue.global(qos: .background);
    
    let sleepTime: UInt32 = 2000000;
    
    func didWin(verdict: Int, player: Int) {
        if (player == 3 && verdict == 1) { //tie
            showText.text = "It's a tie!"
            gameActive = false;
        }
        if (verdict == 0) {
            //resume game, just display move
            return;
        }
        else if (verdict == 1) {
            if (player == 1) { //player won
                showText.text = "X has won!"
                print("X won")
                gameActive = false
            }
            else if (player == 2) { //computer won
                showText.text = "O has won!"
                print("O won")
                gameActive = false
            }
        }
        startAction(nil);
    }
    
    @IBAction func startAction(_ sender: UIButton?) {
        gameStarted = !gameStarted;
        //print("gameStarted is \(gameStarted)");
        if (gameStarted) {
            gameActive = true
            startGame();
        }
        else{
            gameActive = false
            endGame();
        }
    }
    
    func endGame() {
        startButton.setTitle("Start", for: .normal) //Set button to start meaning user has clicked stop
        toggleButtons(flag: false);
    }
    
    func startGame() {
        startButton.setTitle("Stop", for: .normal);
        resetGame();
        playerTurn = true;
        toggleButtons(flag: true);
        if compSwitch.isOn { //create thread
            bgqueue.async {
                while (self.gameStarted) {
                    if (self.playerTurn) {
                        self.toggleButtons(flag: true);
                    }
                    else {
                        self.toggleButtons(flag: false);
                    }
                    
                    usleep(self.sleepTime);
                    
                    let AIMove = self.AIMove();
                    DispatchQueue.main.async { //update UI here
                        
                        let button: UIButton = self.view.viewWithTag(AIMove+1) as! UIButton
                        button.sendActions(for: .touchUpInside)
                    }
                    self.toggleButtons(flag: false)
                }
            }
        }
    }
    
    func AIMove() -> Int { //implemented AI logic here
        var typeMoves: [Int];
        var opponentMoves: [Int];
        if (self.playerTurn) {
            typeMoves = xMoves;
            opponentMoves = oMoves;
        }
        else {
            typeMoves = oMoves;
            opponentMoves = xMoves;
        }
        for i in 0...8 { //winning condition
            if moves[i] == 0 {
                typeMoves[i] = 1;
                if (game.checkGameOver(arr: typeMoves) == 1) {
                    return i;
                }
                else {
                    typeMoves[i] = 0;
                }
            }
        }
        for i in 0...8 { //blocking condition
            if moves[i] == 0 {
                opponentMoves[i] = 1;
                if (game.checkGameOver(arr: opponentMoves) == 1) {
                    return i;
                }
                else {
                    opponentMoves[i] = 0;
                }
            }
        }
        for i in 0...8 { //else pick first available move
            if moves[i] == 0 {
                return i;
            }
        }
        
        return 1;
    }
    
    @IBAction func buttonPress(_ sender: UIButton) {
        if(moves[(sender.tag)-1] == 0 && gameActive == true){
            showText.text = "Button \(sender.tag) pressed"
            if (playerTurn) {
                sender.setImage(#imageLiteral(resourceName: "button_x"), for: UIControlState.normal)
                sender.setImage(#imageLiteral(resourceName: "button_x"), for: UIControlState.disabled)
                moves[(sender.tag)-1] = 1; //Move has been used
                xMoves[(sender.tag)-1] = 1;
                game.xMoves = xMoves;
                game.moves = moves;
                if(compSwitch.isOn == true){
                    toggleButtons(flag: false)
                }
                playerTurn = !playerTurn;
            }
            else if (!playerTurn) {
                sender.setImage(#imageLiteral(resourceName: "button_o"), for: UIControlState.normal)
                sender.setImage(#imageLiteral(resourceName: "button_o"), for: UIControlState.disabled)
                moves[(sender.tag)-1] = 1; //Move has been used
                oMoves[(sender.tag)-1] = 1
                game.oMoves = oMoves;
                game.moves = moves;
                if(compSwitch.isOn == true){
                    toggleButtons(flag: true)
                }
                playerTurn = !playerTurn;
            }
        }
    }
    
    func toggleButtons(flag: Bool) {
        for i in 1...9 {
            let button = view.viewWithTag(i) as! UIButton
            button.isEnabled = flag;
        }
    }
    
    func resetGame(){
        playerTurn = true;
        moves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        xMoves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        oMoves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        game.xMoves = xMoves;
        game.oMoves = oMoves;
        game.moves = moves;
        
        for i in 1...9 {
            let button = view.viewWithTag(i) as! UIButton
            button.setImage(#imageLiteral(resourceName: "button_empty"), for: UIControlState())
            button.setImage(#imageLiteral(resourceName: "button_empty"), for: UIControlState.disabled)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.attachObserver(observer: self);
        
        toggleButtons(flag: false);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

