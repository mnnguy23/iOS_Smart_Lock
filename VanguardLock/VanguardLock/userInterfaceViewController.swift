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
    var enabledLocks:[String:Lock]?
    
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var addLockButton: UIButton!
    
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
    
    @IBAction func logOut(_ sender: AnyObject) {
        
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
            lockButton.backgroundColor = UIColor.red
            lockButton.setTitle("Unlock", for: .normal)
            lockImage.image = lockImages[0]
        } else {
            lockButton.backgroundColor = UIColor.green
            lockButton.setTitle("Lock", for: .normal)
            lockImage.image = lockImages[1]
        }
    }
    
    private func checkForLocks() {
        if enabledLocks != nil {
            lockButton.isHidden = false
            lockImage.isHidden = false
        } else {
            lockButton.isHidden = true
            lockImage.isHidden = true
        }
    }
}
