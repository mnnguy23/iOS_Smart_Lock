//
//  MainTabBarController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 11/17/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var ownedlocks:[Lock] = []
    var authorized:[Lock] = []
    let lockEndPoint = "\(Constant.BASE_API)/lock/all"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.getOwnedLocks()
            self.getAuthorizedLocks()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func getOwnedLocks() {
        guard let url = URL(string: lockEndPoint) else {
            print("Could not create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        DispatchQueue.main.async {
            let task = session.dataTask(with: urlRequest,
                                        completionHandler: {(data, response, error) in
                                            if error != nil {
                                                print("Error found \(error)")
                                                return
                                            }
                                            
                                            guard let responseData = data else {
                                                print("No data")
                                                return
                                            }
                                            
                                            do {
                                                guard let jsonLocks = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [AnyObject] else {
                                                    print("could not get JSON from responseData as NSArray")
                                                    return
                                                }
                                                for jsonLock in jsonLocks {
                                                    let lockData = jsonLock as! [String: AnyObject]
                                                    let name = lockData["lock_name"] as! String
                                                    let owner = lockData["owner"] as! Int
                                                    let address = lockData["address"] as! String
                                                    let id = lockData["lock_id"] as! Int
                                                    let serialNumber = lockData["serial_number"] as! String
                                                    let lockState = lockData["lock_state"] as! Bool
                                                    let currentUser = UserDefaults.standard.integer(forKey: Constant.USER_ID)
                                                    if(owner == currentUser) {
                                                        let newLock:Lock = Lock(lockId: id, owner: owner, name: name, location: address, serialNumber: serialNumber, locked: lockState)
                                                        self.ownedlocks.append(newLock)
                                                    }
                                                }
                                            } catch {
                                                print("error parsing response from /lock/all")
                                                return
                                            }
            })
            task.resume()
        }
    }
    
    private func getAuthorizedLocks() {
        let currentUser = UserDefaults.standard.integer(forKey: Constant.USER_ID)
        let authUserEndPoint = "\(Constant.BASE_API)/lock_user_auth/user_authorized/\(currentUser)"
        guard let url = URL(string: authUserEndPoint) else {
            print("Could not create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        DispatchQueue.main.async {
            let task = session.dataTask(with: urlRequest,
                                        completionHandler: {(data, response, error) in
                                            if error != nil {
                                                print("Error found \(error)")
                                                return
                                            }
                                            
                                            guard let responseData = data else {
                                                print("No data")
                                                return
                                            }
                                            
                                            do {
                                                guard let jsonUserAuths = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [AnyObject] else {
                                                    print("could not get JSON from responseData as NSArray")
                                                    return
                                                }
                                                for jsonUserAuth in jsonUserAuths {
                                                    let lockData = jsonUserAuth as! [String: AnyObject]
                                                    let name = lockData["lock_name"] as! String
                                                    let owner = lockData["owner"] as! Int
                                                    let address = lockData["address"] as! String
                                                    let id = lockData["lock_id"] as! Int
                                                    let serialNumber = lockData["serial_number"] as! String
                                                    let lockState = lockData["lock_state"] as! Bool
                                                    let newLock:Lock = Lock(lockId: id, owner: owner, name: name, location: address, serialNumber: serialNumber, locked: lockState)
                                                    self.authorized.append(newLock)
                                                }
                                            } catch {
                                                print("error parsing response from /lock/all")
                                                return
                                            }
            })
            task.resume()
        }
    }
}
