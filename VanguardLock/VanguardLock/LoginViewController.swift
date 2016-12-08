//
//  LoginViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/23/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var usersData: NSArray?
    
    let baseEndPoint = "\(Constant.BASE_API)/user/all"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getInfo()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logIn(_ sender: AnyObject) {
        
        let userNameResults = checkUsername()
        let passwordResults = checkPassword()
        
        if userNameResults.0 {
            if passwordResults {
                UserDefaults.standard.set(userNameResults.1, forKey: Constant.USER_ID)
                UserDefaults.standard.set(true, forKey: Constant.LOGIN_KEY)
                UserDefaults.standard.synchronize()
                self.dismiss(animated: true, completion: nil)
            } else {
                displayError(title: "Password Errror", message: "Password is incorrect")
            }
        } else {
            displayError(title: "UserName Error", message: "UserName does not exist")
        }
    }
    
    private func checkUsername() -> (Bool, Int) {
        var isCorrect = false
        var id = 0
        if let users = usersData {
            for user in users {
                let userData = user as! [String: AnyObject]
                let username = userData["username"] as! String
                let userID = userData["user_id"] as! Int
                if(username == self.emailTextField.text!) {
                    isCorrect = true
                    id = userID
                }
                
            }
        }
        
        return (isCorrect, id)
    }
    
    private func checkPassword() -> Bool {
        var isCorrect = false
        if let users = usersData {
            for user in users {
                let userData = user as! [String: AnyObject]
                let password = userData["password"] as! String
                if(password == self.passwordTextField.text!) {
                    isCorrect = true
                }
                
            }
        }
        return isCorrect
    }
    
    func getInfo() {
        guard let url = URL(string: baseEndPoint) else {
            print( "Could not create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        DispatchQueue.main.async {
            let task = session.dataTask(with: urlRequest, completionHandler: {data, response, error in
                if error != nil {
                    print("Error found \(error)")
                    return
                }
                
                guard let responseData = data else {
                    print("No data")
                    return
                }
                
                let users = try! JSONSerialization.jsonObject(with: responseData, options: []) as! NSArray
                self.usersData = users
                
                
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
    
    func displayError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
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
