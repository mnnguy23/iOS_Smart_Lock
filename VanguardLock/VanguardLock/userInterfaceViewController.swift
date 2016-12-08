    //
//  userInterfaceViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/23/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit
import MapKit

class userInterfaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let LogInKey = "isUserLoggedIn"
    let lockImages: [UIImage] = [#imageLiteral(resourceName: "Lock Filled-100.png"), #imageLiteral(resourceName: "Unlock Filled-100.png")]
    var lockEnabledStored = false
    var currentLock:Lock?
    var ownedLocks:[Lock] = []
    @IBOutlet weak var addLockButton: UIButton!
    @IBOutlet weak var addLockLabel: UILabel!
    @IBOutlet weak var locksTableView: UITableView!

    
    // ToDo: Must add UserDefault for The Locks to save.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locksTableView.delegate = self
        self.locksTableView.dataSource = self
        self.locksTableView.rowHeight = 50.0
        updateTabBarData()
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let tabVC = self.tabBarController as! MainTabBarController
        self.ownedLocks = tabVC.ownedlocks
        self.locksTableView.reloadData()
      //  checkLockValue(lockValue: lockEnabledStored)
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: LogInKey)
        UserDefaults.standard.synchronize()
        
        confirmationMessage(message: "Successfully logged out.")
    }
    

    private func confirmationMessage(message: String) {
        let myAlert = UIAlertController(title: "Confirmed", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok" , style: UIAlertActionStyle.default) { action in
            self.dismiss(animated: true, completion: nil)
        }
        
        myAlert.addAction(okAction)
        
        present(myAlert, animated: true, completion: nil)
    }

    
    @IBAction func saveLock(unwindSegue: UIStoryboardSegue) {
        if let lockDetailsViewController = unwindSegue.source as? AddLockViewController {
            if let lock = lockDetailsViewController.lock {
                ownedLocks.append(lock)
            }
            self.updateTabBarData()
            self.locksTableView.reloadData()
        }
        //checkForLocks()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ownedLocks.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Owned Lock(s)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:LockTableViewCell = self.locksTableView.dequeueReusableCell(withIdentifier: "cell")! as! LockTableViewCell
        cell = returnLockCell(lock: self.ownedLocks[indexPath.row], cell: cell)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleLock(lock: ownedLocks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75.0
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete", handler: {action, index in
            self.deleteLock(row: indexPath.row)
            self.ownedLocks.remove(at: indexPath.row)
            self.locksTableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.updateTabBarData()
            
        })
        delete.backgroundColor = UIColor.red
        
        let map = UITableViewRowAction(style: .normal, title: "Map", handler: {action, index in
            self.currentLock = self.ownedLocks[indexPath.row]
            self.performSegue(withIdentifier: "managementSegue", sender: nil)
        })
        map.backgroundColor = UIColor.green
        
        
        return [delete, map]
        
    }
    /// TODO: Come back to this part when the correct endpoint is working
    private func deleteLock(row: Int) {
        print("row: \(row)")
        let lockId = self.ownedLocks[row].lockId
        let removeEndPoint = "\(Constant.BASE_API)/lock/remove/\(lockId)"
        print("lock id: \(lockId)")
        guard let url = URL(string: removeEndPoint) else {
            print("Could not create URL")
            return
        }
        var urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        DispatchQueue.main.async {
            let task = session.dataTask(with: urlRequest,
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
                                                guard let receivedData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Any else {
                                                    print("Could not get JSON from responseData as Any")
                                                    return
                                                }
                                                print("Recieved data: \(receivedData)")
                                            } catch {
                                                print("error parsing response from lock_user_auth/lock/\(lockId)")
                                                return
                                            }
            })
            task.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    
    func returnLockCell(lock: Lock, cell: LockTableViewCell) -> LockTableViewCell {
        cell.lockLabel?.text = lock.name
        cell.lock = lock
        
        if(cell.lock.locked) {
            cell.lockImageView.image = lockImages[0]
            cell.lockImageView.layer.borderWidth = 1
            cell.lockImageView.layer.masksToBounds = false
            cell.lockImageView.layer.cornerRadius = cell.lockImageView.frame.height/6
            cell.lockImageView.backgroundColor = UIColor.green
            cell.lockImageView.layer.borderColor = UIColor.green.cgColor
        } else {
            cell.lockImageView.backgroundColor = UIColor.red
            cell.lockImageView.image = lockImages[1]
            cell.lockImageView.layer.borderWidth = 1
            cell.lockImageView.layer.masksToBounds = false
            cell.lockImageView.layer.cornerRadius = cell.lockImageView.frame.height/6
            cell.lockImageView.layer.borderColor = UIColor.red.cgColor
        }
        return cell
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
                                            self.locksTableView.reloadData()
            })
            task.resume()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "managementSegue" {
            if let managementVC = segue.destination as? ManagementViewController {
                if currentLock != nil {
                    managementVC.lock = currentLock
                }
            }
        }
    }
    
    func updateTabBarData() {
        let tbvc = self.tabBarController as! MainTabBarController
        tbvc.ownedlocks = self.ownedLocks
    }
}
