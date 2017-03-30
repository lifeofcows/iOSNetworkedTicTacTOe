//
//  Connection.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-27.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import Foundation
import UIKit

class Connection: NSObject, GCDAsyncSocketDelegate, Reactor {
    var socket: GCDAsyncSocket!
    var isStarted: Bool = true;
    var reactor = ReactorImpl();
    let dg = DispatchGroup()

    func open(host: String, port:UInt16) {
        print("Opening socket connection with host \(host), port \(port)");
        socket = GCDAsyncSocket(delegate: self,
                                delegateQueue: DispatchQueue.main)
        do {
            try socket.connect(toHost: host, onPort: port)
            print("Connected!");
        } catch let e {
            print(e)
        }
    }
    
    func registerHandlers() {
        register(name: "PLAY_GAME_REQUEST",  handler: PlayGameRequest());
        register(name: "PLAY_GAME_RESPONSE", handler: PlayGameResponse());
        register(name: "GAME_ON",  handler: gameOn());
        register(name: "MOVE_MESSAGE", handler: PlayGameResponse());
        register(name: "GAME_OVER",  handler: PlayGameRequest());
    }
    
    func socket(_ sock : GCDAsyncSocket,
                didConnectToHost host:String, port p:UInt16) {
        print("Connected to \(host) on port \(p).") //CONNECTED! NOW CAN SEND OBJECT
        Event(stream: JSONEventStream(socket: sock), fields: ["TYPE": "PLAY_GAME_REQUEST", "SOURCE": MasterViewController.instance?.name ?? "NULL", "DESTINATION": MasterViewController.instance?.oppName ?? "NULL"]).put();
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("Reading data...");
        let clientData = JSONEventStream(socket: sock).get(data: data);
        print("       got clientData...")
        reactor.dispatch(event: clientData);
        print("       dispatched clientData...")
        JSONEventStream(socket: sock).get();
    }
    
    func register(name: String, handler: EventHandler) {
        reactor.register(name: name, handler: handler)
    }
    
    func deregister(name: String) {
        reactor.deregister(name: name)
    }
    
    func dispatch(event: Event) {
        reactor.dispatch(event: event)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected");
    }
}
