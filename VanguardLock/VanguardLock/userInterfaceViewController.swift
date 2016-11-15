    //
//  userInterfaceViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/23/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class userInterfaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let LogInKey = "isUserLoggedIn"
    let lockKey = "lockValue"
    let lockImages: [UIImage] = [#imageLiteral(resourceName: "Lock Filled-100.png"), #imageLiteral(resourceName: "Unlock Filled-100.png")]
    var lockEnabledStored = false
    
    var locks:[Lock] = [Lock(lockId: "1234", name: "Home", location: "3519 Harbor Pass lane, Friendswood, TX 77546"), Lock(lockId: "5678", name: "Garage", location: "3519 Harbor Pass lane, Friendswood, TX 77546")]
    var keys:[VirtualKey] = []
    
 
    @IBOutlet weak var addLockButton: UIButton!
    @IBOutlet weak var addLockLabel: UILabel!
    @IBOutlet weak var locksTableView: UITableView!

    
    // ToDo: Must add UserDefault for The Locks to save.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locksTableView.delegate = self
        self.locksTableView.dataSource = self
        print(">>> \(self.locks.count)")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        lockEnabledStored = UserDefaults.standard.bool(forKey: lockKey)
      //  checkLockValue(lockValue: lockEnabledStored)
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: LogInKey)
        UserDefaults.standard.synchronize()
        
        confirmationMessage(message: "Successfully logged out.")
    }
    
    @IBAction func lockAccess(_ sender: AnyObject) {
        lockEnabledStored = UserDefaults.standard.bool(forKey: lockKey)
        if(lockEnabledStored) {
            UserDefaults.standard.set(false, forKey: lockKey)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.set(true, forKey: lockKey)
            UserDefaults.standard.synchronize()
        }
        lockEnabledStored = UserDefaults.standard.bool(forKey: lockKey)
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
        if lock.locked {
            lock.locked = false
        } else {
            lock.locked = true
        }
        print(lock.locked)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "managementSegue" {
            
        }
    }
}
