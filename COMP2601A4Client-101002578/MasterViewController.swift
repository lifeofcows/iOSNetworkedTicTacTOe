//
//  MasterViewController.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-26.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, GCDAsyncSocketDelegate {
    
    var connection: Connection = Connection();
    var port: UInt16 = 8889;
    var host: String = "192.168.0.15"
    var socket:GCDAsyncSocket!
    var numRows: Int = 1;
    var userList = [NetService]();
    static var instance: MasterViewController?
    var GameViewController: GameViewController? = nil
    var objects: [String] = [];
    var details: [String] = [];
    let bg = DispatchQueue.global(qos: .background);
    var name: String = "";
    var oppName: String = "";
    
    var alertView: UIAlertController?
    
    var service: Service!;
    var acceptor: AcceptorReactor!;
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addToUserList(service: NetService) {
        if !userList.contains(service) {//&& service.name != name {
            userList.append(service);//add table row as well
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            print("Added \(service.name) to UserList")
        }
        else {
            print("userlist already contains this service or service name is name");
        }
    }
    
    func removeFromUserList(service: NetService) {
        let index = userList.index(of: service)
        if  index != nil {
            userList.remove(at: index!);
            let indexPath = IndexPath(row: index!, section: 0)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            print("Removed \(service.name) from UserList")
        } else {
            print("User to be removed does not exist");
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MasterViewController.instance = self;

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.GameViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? GameViewController
        }
        
        name = randomString(length: 8);
        service = Service(domain: "local", type:"_tictactoe._tcp.");
        acceptor = AcceptorReactor(domain: "local", type: "_tictactoe._tcp.", name: name, port: 8889); //don't connect automatically
        
        bg.async {
           self.acceptor.accept(on: 8889)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //showGameReqAlert(player: "lel")
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepped for seg, sender is \(sender)");
        /*if segue.identifier == "selectRow" {
            //if let indexPath = self.tableView.indexPathForSelectedRow { //request a game with the other user
                
            //}
        }*/
        if segue.identifier == "gameOn" {
            print("seguing rn")
            let controller = (segue.destination as! UINavigationController).topViewController as! GameViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("lel");
        let opponentService = userList[indexPath.row];
        oppName = opponentService.name;
        connection.open(host: opponentService.hostName!, port: UInt16(opponentService.port));
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = userList[indexPath.row]
        cell.textLabel!.text = object.name
        return cell
    }

    func showGameReqAlert(player: String, es: EventStream) {
        alertView = UIAlertController(title: "Play Request!", message: "\(player) wants to play with you", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            Event(stream: es, fields: ["TYPE":"PLAY_GAME_RESPONSE", "SOURCE": MasterViewController.instance?.name ?? "NULL", "DESTINATION": player, "ANSWER": true]).put()
            print("return true");
        }
        let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            Event(stream: es, fields: ["TYPE":"PLAY_GAME_RESPONSE", "SOURCE": MasterViewController.instance?.name ?? "NULL", "DESTINATION": player, "ANSWER": false]).put()
            print("return false");
        }
        alertView?.addAction(acceptAction);
        alertView?.addAction(declineAction)

        self.present(alertView!, animated: true, completion: nil)
    }
    
    func showGameResDeclineAlert(player: String) {
        alertView = UIAlertController(title: "Declined", message: "\(player) does not want to play with you", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
        }
        alertView?.addAction(okAction)
        
        self.present(alertView!, animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
