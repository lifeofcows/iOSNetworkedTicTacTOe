//
//  MasterViewController.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-26.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import UIKit

//Zachary Seguin 101000589
//Maxim Kuzmenko 101002578
class MasterViewController: UITableViewController, GCDAsyncSocketDelegate {
    
    var port: UInt16 = 8889;
    var host: String = "192.168.0.15"
    var numRows: Int = 1;
    var userList = [NetService]();
    static var instance: MasterViewController?
    var GameViewController: GameViewController?
    var objects: [String] = [];
    var details: [String] = [];
    let bg = DispatchQueue.global(qos: .background);
    var name: String = "";
    var oppName: String = "";
    var oppIndexPath: IndexPath?;
    var alertView: UIAlertController?
    var alertView1: UIAlertController?
    var player1: Bool = false;
    
    var service: Service!;
    var acceptor: AcceptorReactor!;
    var stream: EventStream!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //ads user to list
    func addToUserList(service: NetService) {
        if !userList.contains(service) && service.name != name {
            userList.append(service);//add table row as well
            let indexPath = IndexPath(row: userList.count-1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            print("Added \(service.name) to UserList")
        }
        else {
            print("userlist already contains this service or service name is name");
        }
    }
    //removes from list
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
        //gen random name
        name = randomString(length: 8);
        service = Service(domain: "local", type:"_tictactoe._tcp.");
        acceptor = AcceptorReactor(domain: "local", type: "_tictactoe._tcp.", name: name, port: 8889); //don't connect automatically
        
        bg.async {
           self.acceptor.accept(on: 8889)
        }
    }
    
    //IMPLEMENT BACK BUTTON OVERRIDE
    
    //create start segue
    func doGameStartSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "gameOn", sender: self);
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        //Will get called on segue back
        //close stream
        if (service.connection.socket != nil) {
            service.connection.socket.disconnect();
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (service.connection.isConnected) {        //if socket connected
            return true;
        }
        return false;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //on click row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        oppIndexPath = indexPath;
        print("Set to index path");
        let opponentService = userList[indexPath.row];
        oppName = opponentService.name;
        service.connection.open(host: opponentService.hostName!, port: UInt16(opponentService.port));
        tableView.cellForRow(at: indexPath)?.isSelected = false
        tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = false;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = userList[indexPath.row]
        cell.textLabel!.text = object.name;
        return cell
    }

    func showWaitingAlert() {
        alertView1 = UIAlertController(title: "Play Request with \(oppName)", message: "Waiting...", preferredStyle: UIAlertControllerStyle.alert);
    }
    //request alert from server side
    func showGameReqAlert(player: String, es: EventStream) {
        print("entered game req alert");
        stream = es;
        alertView = UIAlertController(title: "Play Request!", message: "\(player) wants to play with you", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            Event(stream: es, fields: ["TYPE":"PLAY_GAME_RESPONSE", "SOURCE": MasterViewController.instance?.name ?? "NULL", "DESTINATION": player, "ANSWER": true]).put()
            self.doGameStartSegue();
            print("return true in play_game_response");
        }
        let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            Event(stream: es, fields: ["TYPE":"PLAY_GAME_RESPONSE", "SOURCE": MasterViewController.instance?.name ?? "NULL", "DESTINATION": player, "ANSWER": false]).put()
            print("return false in play_game_response");
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
    
    //gen random string
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
