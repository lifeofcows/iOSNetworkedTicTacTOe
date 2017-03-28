//
//  MasterViewController.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-26.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, GCDAsyncSocketDelegate {
    
    //@IBOutlet weak var imageView: UIImageView!
    var connection: Connection = Connection();
    var port: UInt16 = 8889;
    var host: String = "192.168.0.15"
    var socket:GCDAsyncSocket!
    var numRows: Int = 1;
    static var userList: [String] = []
    static var instance: UITableViewController?
    var detailViewController: DetailViewController? = nil
    var objects: [String] = [];
    var details: [String] = [];
    let bg = DispatchQueue.global(qos: .background);
    let name: String = "Maxim";
    
    var service: Service!;
    var accept: AcceptorReactor!;
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MasterViewController.instance = self;
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        service = Service(domain: "local", type:"_tictactoe._tcp.");
        accept = AcceptorReactor(domain: "local", type: "_tictactoe._tcp.", name: randomString(length: 8), port: 8889);
        
        bg.async {
            self.accept.accept(on: 8889)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    //function registers handlers for the AcceptorReactor
    
    func insertNewObject(_ sender: Any) {
        objects.insert(MasterViewController.userList[MasterViewController.userList.count-1], at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = details[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
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
