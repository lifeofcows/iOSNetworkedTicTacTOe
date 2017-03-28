//
//  Connection.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-27.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import Foundation
import UIKit

class Connection: NSObject, GCDAsyncSocketDelegate {
    var socket: GCDAsyncSocket!
    var isStarted: Bool = true;
    //var imageArray: [NSObjectFileImage] = [];
    
    func open(host: String, port:UInt16) {
        print("Opening socket connection...");
        socket = GCDAsyncSocket(delegate: self,
                                delegateQueue: DispatchQueue.main)
        do {
            print("Connecting to socket server...");
            try socket.connect(toHost: host, onPort: port)
            print("Connected!");
        } catch let e {
            print(e)
        }
    }
    
    func socket(_ socket : GCDAsyncSocket,
                didConnectToHost host:String, port p:UInt16) {
        print("Connected to \(host) on port \(p).")
        let connect = try? JSONSerialization.data(withJSONObject:
            ["NAME": "Maxim", "TYPE":"CONNECT"], options: [])
        socket.write(connect!, withTimeout: -1, tag:0)
        let nl = "\n".data(using: .ascii)
        socket.write(nl!, withTimeout: -1, tag:0)
        let nl1 = "\n".data(using: .ascii)
        socket.readData(to: nl1!, withTimeout: -1, tag:0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("Something received!");
        let json = try? JSONSerialization.jsonObject(with: data,
                                                     options: []) as! [String : Any]
        
        let type = json?["TYPE"] as! String
        print("Type is \(type)");
        
        if type == "CONNECT_RESPONSE" {
            let getUrls = try? JSONSerialization.data(withJSONObject:
                ["TYPE":"GET_URLS"], options: [])
            socket.write(getUrls!, withTimeout: -1, tag:0)
            let nl = "\n".data(using: .ascii)
            socket.write(nl!, withTimeout: -1, tag:0)
            let nl1 = "\n".data(using: .ascii)
            socket.readData(to: nl1!, withTimeout: -1, tag:0)
            print("reading data...")
            
        }
        else if type == "URL" {
            let url = json?["URL"] as! String
            setImage1(url: url);
        }
        else if type == "END_URLS" {
            isStarted = false;
        }
    }
    
    func setImage1(url: String) {
        let catPictureURL = URL(string: url)!
        
        // Creating a session object with the default configuration.
        // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        if let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                //MasterViewController.instance?.imageView.image = image;
                                print("set image");
                            }
                        }
                        // Do something with your image.
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume()
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected");
    }
}
