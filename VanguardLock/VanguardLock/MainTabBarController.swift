//
//  MainTabBarController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 11/17/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let lockEndPoint = "\(Constant.BASE_API)/lock/all"
    
    var locks:[Lock] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getLocks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getLocks() {
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
                                                guard let locks = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [AnyObject] else {
                                                    print("could not get HSON from responseData as NSArray")
                                                    return
                                                }
                                                print(locks)
                                            } catch {
                                                print("error parsing response from /lock/all")
                                                return
                                            }
            })
            task.resume()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
