//
//  AcceptorReactor.swift
//  Command-Server
//
//  Created by Tony White on 2017-03-15.
//  Copyright © 2017 Tony White. All rights reserved.
//

import Foundation

// The model for the reactor used in this class is like
// the reactor used in the midterm; i.e., reactor-redux
// As I/O is non-blocking, we have a slightly different 
// event source implementation. However, the philosophy is
// the same though.

class AcceptorReactor: NSObject, SocketDelegate, Reactor, NetServiceDelegate {
    
    //var clientName: String = "NULL";
    var acceptor: Socket!
    var clients: [Socket:EventStream]
    var reactor = ReactorImpl()
    let dg = DispatchGroup()
    var netService: NetService
    
    init(domain: String, type: String, name: String, port: Int32) {
        netService = NetService(domain: domain, type: type, name: name, port: port)
        clients = [:]
        super.init()
        acceptor = Socket(delegate: self, delegateQueue: DispatchQueue.global())
        registerHandlers();
    }
    
    deinit {
        netService.stop()
        netService.remove(from: .main, forMode: .defaultRunLoopMode)
    }
    
    /*
     * Setup the server socket: non-blocking
     */
    func accept(on port: UInt16) {
        do {
            dg.enter()
            try acceptor.accept(onPort: port)
            print("Accepted");
            netService.delegate = self
            netService.publish()
            netService.schedule(in: .main, forMode: .defaultRunLoopMode)
            RunLoop.main.run()
        } catch let e {
            print(e)
        }
    }
    
    /*
     * Reactor protocol
     */
    func register(name: String, handler: EventHandler) {
        reactor.register(name: name, handler: handler)
    }
    
    func deregister(name: String) {
        reactor.deregister(name: name)
    }
    
    func dispatch(event: Event) {
        reactor.dispatch(event: event)
    }
    
    func registerHandlers() {
        register(name: "PLAY_GAME_REQUEST",  handler: PlayGameRequest());
        register(name: "PLAY_GAME_RESPONSE", handler: PlayGameResponse());
        register(name: "GAME_ON",  handler: gameOn());
        register(name: "MOVE_MESSAGE", handler: PlayGameResponse());
        register(name: "GAME_OVER",  handler: PlayGameRequest());
    }
    
    /*
     * GCDAsyncSocketDelegate callbacks
     */
    
    /*
     * CODE HERE: Accepting a new socket
     * 1. Create an event source
     * 2. Save the event source keyed on the socket
     * 3. Schedule a read operation
     */
    func socket(_ socket: Socket, didAcceptNewSocket newSocket: Socket) {
        print("Client connected")
        let jsonevent = JSONEventStream(socket: newSocket);
        clients[newSocket] = jsonevent;
        clients[newSocket]?.get();
    }

    /*
     * CODE HERE: Callback for disconnection
     * 1. Remove the socket from the hashtable
     * 2. Close the socket
     */
    func socketDidDisconnect(_ sock: Socket, withError err: Error?) {
        print("Client disconnected: \(err)")
        clients[sock] = nil
        sock.disconnect()
    }
    
    /*
     * CODE HERE: Deals with:
     * 1. Finding the correct event stream
     * 2. Obtaining the event from the data
     * 3. Dispatching the event to the correct handler
     * 4. Scheduling another read
     */
    func socket(_ sock: Socket, didRead data: Data, withTag tag: Int) {
        print("Reading data...");
        let client = clients[sock];
        let clientData = client?.get(data: data);
        print("       got clientData...")
        reactor.dispatch(event: clientData!)
        print("       dispatched clientData...")
        client?.get();
    }
    
    func netServiceDidStop(_ sender: NetService) {
        print("did stop")
    }
    
    func netServiceWillPublish(_ sender: NetService) {
        print("will publish")
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        print("did publish")
    }
    
    func netService(_ sender: NetService,
                    didNotPublish errorDict: [String : NSNumber]) {
        print("did not publish")
    }
    
    func unpublishService() {
        netService.stop()
        netService.remove(from: .main, forMode: .defaultRunLoopMode)
    }

    
}