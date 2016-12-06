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
    var locks:[Lock] = [Lock(lockId: "1234", name: "ERP", location: "5000 Gulf Fwy #226, Houston, TX 77023"), Lock(lockId: "5678", name: "UH", location: "4800 Calhoun Rd, Houston, TX 77004")]
 
    @IBOutlet weak var addLockButton: UIButton!
    @IBOutlet weak var addLockLabel: UILabel!
    @IBOutlet weak var locksTableView: UITableView!

    
    // ToDo: Must add UserDefault for The Locks to save.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locksTableView.delegate = self
        self.locksTableView.dataSource = self
        print(">>> \(self.locks.count)")
        self.locks[0].users.append(User(username: "TestUser"))
        self.locks[1].users.append(User(username: "TA"))
        self.locks[1].users.append(User(username: "Professor"))
        updateTabBarData()
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        lockEnabledStored = UserDefaults.standard.bool(forKey: Constant.LOCK_KEY)
        let tabBarVC = self.tabBarController as! MainTabBarController
        locks = tabBarVC.locks
      //  checkLockValue(lockValue: lockEnabledStored)
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: LogInKey)
        UserDefaults.standard.synchronize()
        
        confirmationMessage(message: "Successfully logged out.")
    }
    
    @IBAction func lockAccess(_ sender: AnyObject) {
        lockEnabledStored = UserDefaults.standard.bool(forKey: Constant.LOCK_KEY)
        if(lockEnabledStored) {
            UserDefaults.standard.set(false, forKey: Constant.LOCK_KEY)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.set(true, forKey: Constant.LOCK_KEY)
            UserDefaults.standard.synchronize()
        }
        lockEnabledStored = UserDefaults.standard.bool(forKey: Constant.LOCK_KEY)
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
                locks.append(lock)
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
        
        return self.locks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:LockTableViewCell = self.locksTableView.dequeueReusableCell(withIdentifier: "cell")! as! LockTableViewCell
        cell = returnLockCell(lock: self.locks[indexPath.row], cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleLock(lock: locks[indexPath.row])
        self.locksTableView.reloadRows(at: [indexPath], with: .none)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete", handler: {action, index in
            self.locks.remove(at: indexPath.row)
            self.locksTableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateTabBarData()
            
        })
        delete.backgroundColor = UIColor.red
        
        let map = UITableViewRowAction(style: .normal, title: "Map", handler: {action, index in
            self.currentLock = self.locks[indexPath.row]
            self.performSegue(withIdentifier: "managementSegue", sender: nil)
        })
        map.backgroundColor = UIColor.green
        
        
        return [delete, map]
        
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
            cell.lockButton.setImage(lockImages[0], for: .normal)
            cell.lockButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
            cell.lockButton.tintColor = UIColor.green
            
        } else {
            cell.lockButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
            cell.lockButton.setImage(lockImages[1], for: .normal)
            cell.lockButton.tintColor = UIColor.red
        }
        print(cell.lock.locked)
        return cell
    }
    
    func toggleLock(lock: Lock) {
        var lockStatus:String
        if lock.locked {
            lock.locked = false
            lockStatus = "Unlocked"
        } else {
            lock.locked = true
            lockStatus = "Locked"
        }
        let date = NSDate()
        let calender = NSCalendar.current
        let hour = calender.component(.hour, from: date as Date)
        let minutes = calender.component(.minute, from: date as Date)
        let day = calender.component(.day, from: date as Date)
        let month = calender.component(.month, from: date as Date)
        let year = calender.component(.year, from: date as Date)
        
        let completeTime = "Day: \(year)-\(month)-\(day) Time: \(hour)-\(minutes)"

        lock.lockStatus.append(lockStatus)
        lock.logs.append(completeTime)
        updateTabBarData()
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
        tbvc.locks = self.locks
    }
    
    private func getLocks() {
        
    }
}
