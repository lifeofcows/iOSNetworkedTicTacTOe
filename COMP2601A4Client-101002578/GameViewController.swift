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
class GameViewController: UIViewController, Observer { //, Observer {
    let game: Game = Game();
    
    //Creating buttons
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
    var es: EventStream!;
    
    @IBOutlet weak var showText: UILabel!
    
    static var instance: GameViewController?
    
    var playerTurn: Bool = true;
    var gameStarted: Bool = false;
    var moves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    var xMoves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    var oMoves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    var corners = [0, 2, 6, 8];
    var sides = [1, 3, 5, 7];
    
    var gameActive = true;
    let bgqueue = DispatchQueue.global(qos: .background);
    
    let sleepTime: UInt32 = 2000000; //sleeptime for the computer
    
    var isFirst: Bool!;
    
    //function is called from the Game class every time a move is made to determine whether game has ended
    func didWin(verdict: Int, player: Int) {
        if (player == 3 && verdict == 1) { //tie
            showText.text = stringsConstants.tie;
            gameActive = false;
        }
        if (verdict == 0) {
            //resume game, just display move
            return;
        }
        else if (verdict == 1) {
            if (player == 1) { //player won
                showText.text = stringsConstants.xWin;
                print("X won")
                gameActive = false
            }
            else if (player == 2) { //computer won
                showText.text = stringsConstants.oWin;
                print("O won")
                gameActive = false
            }
        }
        startAction(nil);
    }
    
    //IBAction corresponds to the start button; function starts the game/ends the game.
    @IBAction func startAction(_ sender: UIButton?) {
        gameStarted = !gameStarted;
        if (gameStarted) {
            gameActive = true
            startGame();
        }
        else{
            gameActive = false
            endGame();
        }
    }
    
    func endGame() { //function ends game
        startButton.setTitle("Start", for: .normal) //Set button to start meaning user has clicked stop
        toggleButtons(flag: false);
    }
    
    func startGame() { //function starts game; does some ready work to prep game for new game.
        startButton.setTitle("Stop", for: .normal);
        resetGame();
        playerTurn = true;
        toggleButtons(flag: true);
        //if compSwitch.isOn { //if computer mode is on, create thread and play with computer
            bgqueue.async { //create background thread
                while (self.gameStarted) {
                    if (self.playerTurn) {
                        self.toggleButtons(flag: true);
                    }
                    else {
                        self.toggleButtons(flag: false);
                    }
                    
                    //print("sleeping now");
                    usleep(self.sleepTime);
                    
                    let AIMove = self.AIMove();
                    if AIMove == -1 {
                        return;
                    }
                    DispatchQueue.main.async { //update UI here
                        let button: UIButton = self.view.viewWithTag(AIMove+1) as! UIButton //button clicked programmatically
                        button.sendActions(for: .touchUpInside)
                    }
                    self.toggleButtons(flag: false)
            //    }
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
        
        let val = randMoveFromArray(arr: corners); //return one of the random corners
        if (val != -1) {
            return val;
        }
        
        if (moves[4] == 0) { //return the center
            return 4;
        }
        
        return randMoveFromArray(arr: sides); //return one of the random sides
    }
    
    func randMoveFromArray(arr: [Int])->Int { //returns a random element based on the array depending on the 'move' array
        var availableRandMoves: [Int] = [Int](); //pick a corner
        for i in arr {
            if (moves[i] == 0) {
                availableRandMoves.append(i);
            }
        }
        if availableRandMoves.count != 0 {
            return availableRandMoves[Int(arc4random_uniform(UInt32(availableRandMoves.count-1)))]
        }
        return -1;
    }
    
    @IBAction func buttonPress(_ sender: UIButton) { //called whenever a tic tac toe button is pressed
        if(moves[(sender.tag)-1] == 0 && gameActive == true) { //if the game is on and the button that is clicked has not been previously clicked
            showText.text = "Button \(sender.tag) pressed"
            if (playerTurn) {
                sender.setImage(#imageLiteral(resourceName: "button_x"), for: UIControlState.normal)
                sender.setImage(#imageLiteral(resourceName: "button_x"), for: UIControlState.disabled)
                moves[(sender.tag)-1] = 1; //Move has been used
                xMoves[(sender.tag)-1] = 1;
                game.xMoves = xMoves;
                game.moves = moves;
                toggleButtons(flag: false)
                playerTurn = !playerTurn;
            }
                /*
            else if (!playerTurn) {
                sender.setImage(#imageLiteral(resourceName: "button_o"), for: UIControlState.normal)
                sender.setImage(#imageLiteral(resourceName: "button_o"), for: UIControlState.disabled)
                moves[(sender.tag)-1] = 1; //Move has been used
                oMoves[(sender.tag)-1] = 1
                game.oMoves = oMoves;
                game.moves = moves;
                toggleButtons(flag: true)
                playerTurn = !playerTurn;
            }*/
        }
    }
    
    //turns on/off all buttons depending on flag value
    func toggleButtons(flag: Bool) {
        for i in 1...9 {
            let button = view.viewWithTag(i) as! UIButton
            button.isEnabled = flag;
        }
    }
    
    //resets the game
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
        game.attachObserver(observer: self); //attach observer to the game instance
        
        toggleButtons(flag: false); //turn off all buttons initally
        GameViewController.instance = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func oppMadeMove(move: Int) {
        if (isFirst!) {
            
        }
        
        playerTurn = true;
    }
    
}

