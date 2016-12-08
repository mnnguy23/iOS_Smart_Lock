//
//  UsersTableViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 11/17/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    var locks:[Lock] = []

    override func viewDidLoad() {
        super.viewDidLoad()
            let tabBarVC = self.tabBarController as! MainTabBarController
            self.locks = tabBarVC.ownedlocks
            self.getUsers()
            self.tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabBarVC = self.tabBarController as! MainTabBarController
        self.locks = tabBarVC.ownedlocks
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return locks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locks[section].users.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return locks[section].name
    }
 
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0 , width: view.frame.size.width, height: 50))
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = locks[section].name
        headerView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        let imageView = UIImageView(frame: CGRect(x: 0,y: 0, width: 30,height: 30))
        imageView.image = UIImage(named: "Unlock Filled-100.png")
        headerView.addSubview(imageView)
        imageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        cell.textLabel?.text = locks[indexPath.section].users[indexPath.row].username
        // Configure the cell...

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        /// ToDo: Still need to remove people from The DB
        let delete = UITableViewRowAction(style: .normal, title: "Delete", handler: {action, index in
            
            self.deleteUser(section: indexPath.section, row: indexPath.row)
            self.locks[indexPath.section].users.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateTabBarData()
        })
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }

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
    
    @IBAction func saveUser(unwindSegue: UIStoryboardSegue) {
        if let addUserVC = unwindSegue.source as? AddUserViewController {
            self.locks = addUserVC.locks
        }
        
        self.tableView.reloadData()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addUserSegue" {
            if let destinationVC = segue.destination as? AddUserViewController {
                destinationVC.locks = self.locks
            }
        }
    }
    
    func updateTabBarData() {
        let tbvc = self.tabBarController as! MainTabBarController
        tbvc.ownedlocks = self.locks
    }
    
    private func deleteUser(section: Int, row: Int) {
        let lockId = locks[section].lockId
        let userId = locks[section].users[row].id
        
        print("lock Id: \(lockId)")
        print("lock Id: \(userId)")
        let removeEndPoint = "\(Constant.BASE_API)/lock_user_auth/remove"
        
        guard let removeUrl = URL(string: removeEndPoint) else {
            print("Could not create URL")
            return
        }
        var removeUrlRequest = URLRequest(url: removeUrl)
        removeUrlRequest.httpMethod = "POST"
        removeUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let removeUser: [String:Any] = ["lock_id": lockId, "user_id": userId]
        let jsonRemoveUser: Data
        do {
            jsonRemoveUser = try JSONSerialization.data(withJSONObject: removeUser, options: .prettyPrinted)
            removeUrlRequest.httpBody = jsonRemoveUser
        } catch {
            print("Error: Could not create JSON from jsonRemoveUser")
            return
        }
        let session = URLSession.shared
        DispatchQueue.main.async {
            let task = session.dataTask(with: removeUrlRequest,
                                        completionHandler: { data, response, error in
                                            guard error == nil else {
                                                print("Error calling /lock/change/state/")
                                                print(error as! String)
                                                return
                                            }
                                            
                                            guard let responseData = data else {
                                                print("Error: did not received data")
                                                return
                                            }
                                            
                                            do {
                                                guard let receivedRemoveData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Any else {
                                                    print("Could not get JSON from responseData as Any")
                                                    return
                                                }
                                            } catch let error as Error {
                                                print("error parsing response from POST on /lock_user_auth/remove")
                                                print(error)
                                                return
                                            }
            })
            task.resume()
        }
    }
    func getUsers() {
        let authUserEndPoint = "\(Constant.BASE_API)/lock_user_auth/all"
        var userIds:[Int:Int] = [:]
        guard let authUserUrl = URL(string: authUserEndPoint) else {
            print("could not create URL")
            return
        }
        let authUserUrlRequest = URLRequest(url: authUserUrl)
        let authSession = URLSession.shared
        
        DispatchQueue.main.async {
            authSession.dataTask(with: authUserUrlRequest,
                                 completionHandler: { data, response, error in
                                    if error != nil {
                                        print("Error found \(error)")
                                        return
                                    }
                                    
                                    guard let responseData = data else {
                                        print("No data")
                                        return
                                    }
                                    
                                    do {
                                        guard let authUsers = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [AnyObject] else {
                                            print("Could not get JSON from jsonLocks as NSArray")
                                            return
                                        }
                                        for authUser in authUsers {
                                            let authData = authUser as! [String: AnyObject]
                                            let authLock = authData["lock_id"] as! Int
                                            let currentAuthUser = authData["child_id"] as! Int
                                            
                                            for currentLock in self.locks {
                                                if currentLock.lockId == authLock {
                                                    userIds[currentAuthUser] = authLock
                                                }
                                            }
                                        }
                                        
                                    } catch {
                                        print("error parsing response from /lock_user_auth/all")
                                        return
                                    }
                                    
                                    print(authUserEndPoint)
            }).resume()
            
            let userEndPoint = "\(Constant.BASE_API)/user/all"
            guard let userUrl = URL(string: userEndPoint) else {
                print("could not create URL")
                return
            }
            let userUrlRequest = URLRequest(url: userUrl)
            let userSession = URLSession.shared
            DispatchQueue.main.async {
                userSession.dataTask(with: userUrlRequest,
                                     completionHandler: { data, response, error in
                                        if error != nil {
                                            print("Error found \(error)")
                                            return
                                        }
                                        
                                        guard let responseData = data else {
                                            print("No data")
                                            return
                                        }
                                        
                                        do {
                                            guard let jsonUsers = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [AnyObject] else {
                                                print("Could not get JSON from jsonUsers as Array")
                                                return
                                            }
                                            for jsonUser in jsonUsers {
                                                let currentUser = jsonUser as! [String: AnyObject]
                                                let userId = currentUser["user_id"] as! Int
                                                let username = currentUser["username"] as! String
                                                if let lockId = userIds[userId] {
                                                    let newUser = User(id: userId, username: username)
                                                    for currentLock in self.locks {
                                                        if(lockId == currentLock.lockId) {
                                                            currentLock.users.append(newUser)
                                                        }
                                                    }
                                                }
                                            }
                                        } catch {
                                            print("error parsing response from /user/all")
                                            return
                                        }
                                        print(userEndPoint)
                                        self.tableView.reloadData()
                }).resume()
            }
        }
    }
}
