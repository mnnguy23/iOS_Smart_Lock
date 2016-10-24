//
//  ViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/23/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    let LogInKey = "isUserLoggedIn"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: LogInKey)
        if(!isUserLoggedIn) {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "userInterfaceSegue", sender: self)
        }
    }
}

