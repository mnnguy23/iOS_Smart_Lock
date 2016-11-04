    //
//  userInterfaceViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/23/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class userInterfaceViewController: UIViewController {

    let LogInKey = "isUserLoggedIn"
    let lockKey = "lockValue"
    let lockImages: [UIImage] = [#imageLiteral(resourceName: "Lock Filled-100.png"), #imageLiteral(resourceName: "Unlock Filled-100.png")]
    var lockEnabledStored = false
    var locks:[Lock] = []
    var keys:[VirtualKey] = []
    
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var addLockButton: UIButton!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var addKeyButton: UIButton!
    @IBOutlet weak var addKeyLabel: UILabel!
    
    // ToDo: Must add UserDefault for The Locks to save.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForLocks()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        lockEnabledStored = UserDefaults.standard.bool(forKey: lockKey)
        checkLockValue(lockValue: lockEnabledStored)
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
        checkLockValue(lockValue: lockEnabledStored)
    }
    

    private func confirmationMessage(message: String) {
        let myAlert = UIAlertController(title: "Confirmed", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok" , style: UIAlertActionStyle.default) { action in
            self.dismiss(animated: true, completion: nil)
        }
        
        myAlert.addAction(okAction)
        
        present(myAlert, animated: true, completion: nil)
    }
    
    private func checkLockValue(lockValue: Bool) {
        if(lockValue) {
            lockButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
            lockButton.tintColor = UIColor.green
            lockButton.setImage(lockImages[0], for: .normal)
        } else {
            lockButton.setImage(lockImages[1], for: .normal)
            lockButton.tintColor = UIColor.red
            lockButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        }
    }
    
    private func checkForLocks() {
        if locks.count != 0 {
            lockLabel.text = locks[0].name
            lockButton.isHidden = false
            lockLabel.isHidden = false
            addKeyButton.isHidden = false
            addKeyLabel.isHidden = false
        } else {
            lockButton.isHidden = true
            lockLabel.isHidden = true
            addKeyButton.isHidden = true
            addKeyLabel.isHidden = true
        }
    }
    
    private func checkForKey() {
        for lock in locks {
            if lock.virtualKeys.count > 0 {
                lockButton.isEnabled = true
                lockLabel.isEnabled = true
            } else {
                lockButton.isEnabled = false
                lockLabel.isEnabled = false
            }
        }
    }
    
    
    
    @IBAction func saveLock(unwindSegue: UIStoryboardSegue) {
        if let lockDetailsViewController = unwindSegue.source as? AddLockViewController {
            if let lock = lockDetailsViewController.lock {
                locks.append(lock)
            }
        }
        checkForLocks()
        checkForKey()
    }
    
    @IBAction func saveKey(unwindSegue: UIStoryboardSegue) {
        if let returnVC = unwindSegue.source as? AddKeyViewController {
            if let editedLocks = returnVC.locks {
                locks = editedLocks
            }
        }
        print("> \(locks[0].virtualKeys)")
        checkForKey()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addKeySegue") {
            if let destinationVC = segue.destination as? AddKeyViewController {
               destinationVC.locks = self.locks
            }
        }
    }
}
