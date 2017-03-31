//
//  ReactorImpl.swift
//  Command-Server
//
//  Created by Tony White on 2017-03-15.
//  Copyright © 2017 Tony White. All rights reserved.
//

import Foundation

class ReactorImpl: Reactor {
    
    var handlers: [String:EventHandler] = [:]
    
    func register(name: String, handler: EventHandler) {
        handlers[name] = handler
    }
    
    func deregister(name: String) {
        handlers.removeValue(forKey: name)
    }
    
    func dispatch(event: Event) {
        let type = event.fields["TYPE"] as! String
        print("Type: \(type)");
        let handler = handlers[type]
        if handler != nil {
            print("Handled event of type \(type)");
            handler?.handleEvent(event: event)
        }
        else {
            print("Event is nil");
        }
    }
}
