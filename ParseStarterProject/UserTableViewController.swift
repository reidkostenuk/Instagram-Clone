//
//  UserTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Reid Kostenuk on 2016-08-02.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var usernames = [""]
    var userIDs = [""]
    var isFollowing = ["": false]
    var refresher: UIRefreshControl!

    @IBAction func logoutButtonPressed(_ sender: AnyObject) {
        
        PFUser.logOut()
        performSegue(withIdentifier: "logOutSegue", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // when refreshed, a user query is run to get updated information on users
    func refresh() {
        
        let query = PFUser.query()
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            // if there is an error in finding the users then print error to console.
            if error != nil {
                
                print(error)
                
            // if there is no error in finding the users on server then remove all locally.
            } else if let users = objects {
                
                self.usernames.removeAll()
                self.userIDs.removeAll()
                self.isFollowing.removeAll()
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        // if user is not current user then display user.
                        if user.objectId != PFUser.current()?.objectId {
                            
                            // display username not email address.
                            let usernameArray = user.username?.components(separatedBy: "@")
                            self.usernames.append((usernameArray?[0])!)
                            self.userIDs.append(user.objectId!)
                            
                            // follower is set to current and following is the other.
                            let query = PFQuery(className: "Followers")
                            query.whereKey("follower", equalTo: (PFUser.current()?.objectId)!)
                            query.whereKey("following", equalTo: user.objectId!)
                            query.findObjectsInBackground(block: { (objects, error) in
                                
                                if let objects = objects {
                                    
                                    if objects.count > 0 {
                                        
                                        self.isFollowing[user.objectId!] = true
                                        
                                    } else {
                                        
                                        self.isFollowing[user.objectId!] = false
                                    }
                                    
                                    if self.isFollowing.count == self.usernames.count {
                                        
                                        self.tableView.reloadData()
                                        self.refresher.endRefreshing()
                                        
                                    }
                                }
                            })
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
     
        refresh()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(UserTableViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        
        if isFollowing[userIDs[indexPath.row]] == true {
            
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if isFollowing[userIDs[indexPath.row]] == true {
            
            isFollowing[userIDs[indexPath.row]] = false
            cell?.accessoryType = UITableViewCellAccessoryType.none
            
            let query = PFQuery(className: "Followers")
            query.whereKey("follower", equalTo: (PFUser.current()?.objectId)!)
            query.whereKey("following", equalTo: userIDs[indexPath.row])
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let objects = objects {
                    
                    for object in objects{
                        
                        object.deleteInBackground()
                    }
                }
            })
            
        } else {
            
            isFollowing[userIDs[indexPath.row]] = true
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        
            let following = PFObject(className: "Followers")
            following["follower"] = PFUser.current()?.objectId
            following["following"] = userIDs[indexPath.row]
            following.saveInBackground()
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
