//
//  AuthorizedLockTableViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 12/8/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class AuthorizedLockTableViewController: UITableViewController {
    
    var authorized:[Lock] = []
    let lockImages: [UIImage] = [#imageLiteral(resourceName: "Lock Filled-100.png"), #imageLiteral(resourceName: "Unlock Filled-100.png")]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 50.0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabVC = self.tabBarController as! MainTabBarController
        self.authorized = tabVC.authorized
        self.tableView.reloadData()
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
        return self.authorized.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:ALockTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! ALockTableViewCell
        cell = returnLockCell(lock: self.authorized[indexPath.row], cell: cell)
        
        return cell
    }
    
    func returnLockCell(lock: Lock, cell: ALockTableViewCell) -> ALockTableViewCell {
        cell.lockLabel?.text = lock.name
        
        if(lock.locked) {
            cell.lockImage.image = lockImages[0]
            cell.lockImage.layer.borderWidth = 1
            cell.lockImage.layer.masksToBounds = false
            cell.lockImage.layer.cornerRadius = cell.lockImage.frame.height/6
            cell.lockImage.backgroundColor = UIColor.green
            cell.lockImage.layer.borderColor = UIColor.green.cgColor
            
        } else {
            cell.lockImage.image = lockImages[1]
            cell.lockImage.layer.borderWidth = 1
            cell.lockImage.layer.masksToBounds = false
            cell.lockImage.layer.cornerRadius = cell.lockImage.frame.height/6
            cell.lockImage.backgroundColor = UIColor.red
            cell.lockImage.layer.borderColor = UIColor.red.cgColor
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleLock(lock: authorized[indexPath.row])
    }
    
    func toggleLock(lock: Lock) {
        var toggleLockEndPoint:String = "https://smartlock-jt.herokuapp.com/"
        if lock.locked {
            toggleLockEndPoint = toggleLockEndPoint + "unlock/\(lock.lockId)"
        } else {
            toggleLockEndPoint = toggleLockEndPoint + "lock/\(lock.lockId)"
        }
        guard let toggleLockURL = URL(string: toggleLockEndPoint) else {
            print("Error: cannot create url")
            return
        }
        
        let toggleLockUrlRequest = URLRequest(url: toggleLockURL)
        let session = URLSession.shared
        
        DispatchQueue.main.async {
            print(toggleLockUrlRequest)
            let task = session.dataTask(with: toggleLockUrlRequest,
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
                                                guard let jsonLock = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String:AnyObject] else {
                                                    print("Could not get JSON from responseData as [String:AnyObject]")
                                                    return
                                                }
                                                let isLocked = jsonLock["lock_state"] as! Bool
                                                lock.locked = isLocked
                                            } catch  let error as Error {
                                                print("error parsing response from POST on \(toggleLockEndPoint)")
                                                print(error)
                                                return
                                            }
                                            self.tableView.reloadData()
            })
            task.resume()
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
