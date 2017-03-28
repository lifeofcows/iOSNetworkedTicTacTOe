//
//  Service.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-27.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

//
//  Service.swift
//  lecture18
//
//  Created by Maxim Kuzmenko on 2017-03-26.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import Foundation

class Service : NetServiceBrowser, NetServiceBrowserDelegate, NetServiceDelegate{
    
    var services: [NetService]
    var browser: NetServiceBrowser
    var connection: Connection
    
    init(domain: String, type:String) {
        browser = NetServiceBrowser()
        connection = Connection()
        services = []
        super.init()
        browser.delegate = self
        browser.searchForServices(ofType: type, inDomain: domain)
        browser.schedule(in: .main, forMode: .defaultRunLoopMode)
    }
    
    //found a service
    func netServiceBrowser(_ browser: NetServiceBrowser,
                           didFind service: NetService, moreComing: Bool) {
        print("found a service")
        // (c) Make me the delegate for the service.
        service.delegate = self
        // Would want to:
        // (a) Check whether we know about the service already.
        // (b) Store the service in some kind of Array.
        if !services.contains(service){
            services.append(service)
        }
        service.resolve(withTimeout: 10)
        
        // (d) If moreComing is false, we can update UI.
        if !moreComing{
            //TODO
        }
    }
    
    // Service resolution
    func netServiceDidResolveAddress(_ sender: NetService) {
        // Would probably want to
        // (1) Store the network service
        if !services.contains(sender){
            services.append(sender)
        }
        // (2) Indicate to the user that a new service is available.
        print("New service is available")
        // TODO UI
        // (3) Connect to the service found
        //Add user to UserList
        MasterViewController.userList.append(sender.name);
        print("userlist now has: ");
        for i in MasterViewController.userList {
            print("   \(i)");
        }
        //MasterViewController.userList
        connection.open(host: sender.hostName!, port: UInt16(sender.port))
    }
    
    // Failed to resolve service
    func netService(_ sender: NetService,
                    didNotResolve errorDict: [String : NSNumber]) {
    }
    
    // Service was removed
    func netServiceBrowser(_ browser: NetServiceBrowser,
                           didRemove service: NetService, moreComing: Bool) {
        // Would want to:
        // (a) Check whether I know about the service.
        // (b) Remove it from my array if I do.
        let index = services.index(of: service)
        if  index != nil{
            services.remove(at: index!)
        }
        
        //MasterViewController.userList.remove(sender.name);
        // (c) Update an UI that depends upon the service array.
        print("removed a service")
        // TODO UI
    }
    
}
