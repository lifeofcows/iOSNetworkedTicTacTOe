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
    
    var gameStarted: Bool = false;
    var moves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    var xMoves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    var oMoves = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    
    var gameActive = true;
    
    //function is called from the Game class every time a move is made to determine whether game has ended
    func didWin(verdict: Int, player: Int) {
        gameStarted = false
        print("player is \(player) and verdict is \(verdict)");
        if (player == 3 && verdict == 1) { //tie
            let stream = MasterViewController.instance?.stream;
            let source = MasterViewController.instance?.name
            let destination = MasterViewController.instance?.oppName
            showText.text = stringsConstants.tie;
            gameActive = false;
            Event(stream: stream!, fields: ["TYPE": "GAME_OVER", "SOURCE": source!, "DESTINATION": destination!, "REASON": "It is a tie!"]).put()
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
                let stream = MasterViewController.instance?.stream;
                let source = MasterViewController.instance?.name
                let destination = MasterViewController.instance?.oppName
                Event(stream: stream!, fields: ["TYPE": "GAME_OVER", "SOURCE": source!, "DESTINATION": destination!, "REASON": "X won the game!"]).put()
            }
            else if (player == 2) { //computer won
                showText.text = stringsConstants.oWin;
                print("O won")
                let stream = MasterViewController.instance?.stream;
                let source = MasterViewController.instance?.name
                let destination = MasterViewController.instance?.oppName
                Event(stream: stream!, fields: ["TYPE": "GAME_OVER", "SOURCE": source!, "DESTINATION": destination!, "REASON": "O won the game!"]).put()
                gameActive = false
            }
        }
        endGame();
    }
    
    //IBAction corresponds to the start button; function starts the game/ends the game.
    @IBAction func startAction(_ sender: UIButton?) {
        print("Sender: \(sender)")
        gameStarted = !gameStarted;
        if (gameStarted) {
            gameActive = true
            if (MasterViewController.instance?.player1)! {
                let stream = MasterViewController.instance?.stream;
                let source = MasterViewController.instance?.name
                let destination = MasterViewController.instance?.oppName
                Event(stream: stream!, fields: ["TYPE": "GAME_ON", "SOURCE": source!, "DESTINATION": destination!]).put()
                
            }
            startGame();
        }
        else {
            showText.text = stringsConstants.gameEnded;
            gameActive = false
            endGame();
        }
    }
    
    func endGame() { //function ends game
        print("entered endgame");
        if (MasterViewController.instance?.player1)! {
            startButton.setTitle("Start", for: .normal) //Set button to start meaning user has clicked stop
            startButton.isEnabled = true
        }
        else {
            startButton.setTitle("Start", for: .normal) //Set button to start meaning user has clicked stop
            startButton.isEnabled = false
        }
        toggleButtons(flag: false);
    }
    
    func startGame() { //function starts game; does some ready work to prep game for new game.
        startButton.setTitle("Stop", for: .normal);
        resetGame();
        if(MasterViewController.instance?.player1)!{
            toggleButtons(flag: true);
        }
        else{
            toggleButtons(flag: false);
        }
      
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
        print("button clicked")
        if(moves[(sender.tag)-1] == 0 && gameActive == true) { //if the game is on and the button that is clicked has not been previously clicked
            makeMove(move: sender.tag-1, sender: sender);
            DispatchQueue.main.async {
                self.toggleButtons(flag: false);
            }
            let stream = MasterViewController.instance?.stream;
            let source = MasterViewController.instance?.name
            let destination = MasterViewController.instance?.oppName
            Event(stream: stream!, fields: ["TYPE": "MOVE_MESSAGE", "SOURCE": source!, "DESTINATION": destination!, "MOVE": sender.tag - 1]).put()
        }
    }
    
    func makeMove(move: Int, sender: UIButton) {
        showText.text = "Button \(move) pressed"
        if ((MasterViewController.instance?.player1)!) {
            sender.setImage(#imageLiteral(resourceName: "button_x"), for: UIControlState.normal)
            sender.setImage(#imageLiteral(resourceName: "button_x"), for: UIControlState.disabled)
            moves[move] = 1; //Move has been used
            xMoves[move] = 1;
            game.xMoves = xMoves;
            game.moves = moves;
        }
        else {
            sender.setImage(#imageLiteral(resourceName: "button_o"), for: UIControlState.normal)
            sender.setImage(#imageLiteral(resourceName: "button_o"), for: UIControlState.disabled)
            moves[move] = 1; //Move has been used
            oMoves[move] = 1
            game.oMoves = oMoves;
            game.moves = moves;
        }
    }
    
    //turns on/off all buttons depending on flag value
    func toggleButtons(flag: Bool) {
        print("doing toggle buttons...\(flag)");
        for i in 1...9 {
            let button = view.viewWithTag(i) as! UIButton
            button.isEnabled = flag;
        }
    }
    
    //resets the game
    func resetGame(){
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
        
        if (MasterViewController.instance?.player1)! {
            startButton.isEnabled = true;
        }
        else {
            startButton.isEnabled = false;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func oppMadeMove(move: Int) {
        let button: UIButton = self.view.viewWithTag(move+1) as! UIButton //button clicked programmatically
        DispatchQueue.main.async {
            MasterViewController.instance?.player1 = !(MasterViewController.instance?.player1)!
            self.makeMove(move: move, sender: button);
            MasterViewController.instance?.player1 = !(MasterViewController.instance?.player1)!
            self.toggleButtons(flag: true);
        }
    }
}

