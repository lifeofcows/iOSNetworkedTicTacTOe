//
//  Handlers.swift
//  Command-Server
//
//  Created by Tony White on 2017-03-15.
//  Copyright © 2017 Tony White. All rights reserved.
//

import Foundation

class PlayGameRequest: EventHandler {
    func handleEvent(event: Event) {
        print("play game request handler called");
        MasterViewController.instance?.showGameReqAlert(player: event.fields["SOURCE"] as! String, es: event.stream);
    }
}

class PlayGameResponse: EventHandler {
    func handleEvent(event: Event) {
        print("play game response handler called");
        if event.fields["ANSWER"] as! Bool {
            MasterViewController.instance?.performSegue(withIdentifier: "gameOn", sender: self) //segue
            Event(stream: event.stream, fields: ["TYPE": "GAME_ON", "SOURCE": event.fields["DESTINATION"] as! String, "DESTINATION": event.fields["SOURCE"] as! String]).put();
        }
        else {
            event.stream.close(); //close socket connection
        }
    }
}

class gameOn: EventHandler {
    func handleEvent(event: Event) { //create new game
        print("game on handler called");
        MasterViewController.instance?.performSegue(withIdentifier: "gameOn", sender: self) //segue
    }
}

class moveMessage: EventHandler {
    func handleEvent(event: Event) {
        print("movemessage handler called");
        let move = event.fields["MOVE"] as? Int;
        GameViewController.instance?.oppMadeMove(move: move!);
    }
}

class gameOver: EventHandler {
    func handleEvent(event: Event) {
        print("gameover handler called");
        GameViewController.instance?.showText.text = event.fields["REASON"] as? String;
        GameViewController.instance?.endGame();
    }
}
/*
PLAY_GAME_REQUEST
TYPE = "PLAY_GAME_REQUEST"
SOURCE = A String representing your name
DESTINATION = A String representing the other player's name

PLAY_GAME_RESPONSE
TYPE = "PLAY_GAME_RESPONSE"
SOURCE = A String representing your name
DESTINATION = A String representing the other player's name
ANSWER = A boolean represented using a String: true means yes I will play, false means no I will not play
 
GAME_ON
TYPE = "GAME_ON"
SOURCE = A String representing your name
DESTINATION = A String representing the other player's name
 
MOVE_MESSAGE
TYPE = "MOVE_MESSAGE"
SOURCE = A String representing your name
DESTINATION = A String representing the other player's name
MOVE = An Integer in the range 0-8 representing the tile selected
 
GAME_OVER
TYPE = "GAME_OVER"
SOURCE = A String representing your name
DESTINATION = A String representing the other player's name
REASON = A String representing the reason for the end of game (See assignment 2, requirement 2.11)
 */
