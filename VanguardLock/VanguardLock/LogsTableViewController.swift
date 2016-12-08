//
//  LogsTableViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 11/17/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class LogsTableViewController: UITableViewController {
    
    var locks:[Lock] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false
        let tabBarVC = self.tabBarController as! MainTabBarController
        locks = tabBarVC.ownedlocks
        getLogs()
        self.tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabBarVC = self.tabBarController as! MainTabBarController
        locks = tabBarVC.ownedlocks
        getLogs()
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
        return locks[section].logs.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return locks[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath)
        let status = locks[indexPath.section].logs[indexPath.row].lockStatus
        let accessTime = locks[indexPath.section].logs[indexPath.row].time
        cell.textLabel?.text = status
        if status == "Unlock" {
            cell.textLabel?.textColor = UIColor.red
        } else {
            cell.textLabel?.textColor = UIColor.green
        }
        cell.detailTextLabel?.text = accessTime

        return cell
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
    
    private func getLogs() {
        let logsEndPoint = "\(Constant.BASE_API)/activity_log/all"
        guard let logsUrl = URL(string: logsEndPoint) else {
            print("Could not create URL")
            return
        }
        let logsUrlRequest = URLRequest(url: logsUrl)
        let logSession = URLSession.shared
        
        DispatchQueue.main.async {
            let task = logSession.dataTask(with: logsUrlRequest,
                                           completionHandler: { data, response, error in
                                            if error != nil {
                                                print("Error: \(error)")
                                                return
                                            }
                                            
                                            guard let responseData = data else {
                                                print("No data")
                                                return
                                            }
                                            
                                            do {
                                                guard let logData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [AnyObject] else {
                                                    print("Could not get JSON from logData as Array")
                                                    return
                                                }
                                                for lock in self.locks {
                                                    lock.logs.removeAll()
                                                }
                                                for log in logData {
                                                    let currentLog = log as! [String: AnyObject]
                                                    let lockId = currentLog["lock_id"] as! Int
                                                    let logId = currentLog["log_id"] as! Int
                                                    let status = currentLog["acc_sum"] as! String
                                                    let accessTime = currentLog["act_time"] as! String
                                                    
                                                    for lock in self.locks {
                                                        if(lock.lockId == lockId) {
                                                            let newLog = Log(id: logId, lockStatus: status, time: accessTime)
                                                            lock.logs.insert(newLog, at: 0)
                                                        }
                                                    }
                                                }
                                                self.tableView.reloadData()
                                            } catch {
                                                print("error parsing response from GET on /activity_log/all")
                                                return
                                            }
            })
            task.resume()
        }
    }
}
