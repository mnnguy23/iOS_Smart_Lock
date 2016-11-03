//
//  AddKeyViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 11/2/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class AddKeyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var locks:[Lock]?

    @IBOutlet weak var lockPickerView: UIPickerView!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var keyNameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lockPickerView.delegate = self
        lockPickerView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locks!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        lockLabel.text = locks![row].name
        return locks![row].name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveKeyUnwind"{
            self.addKey()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var result = false
        if(identifier == "saveKeyUnwind") {
            if !(keyNameTF.text?.isEmpty)! {
                createAlert(title: "Key Created", message: "Created key for lock: \(self.lockLabel.text!)")
                result = true
            } else {
                createAlert(title: "Missing Field", message: "Key name is required.")
            }
        }
        return result
    }
    
    func createAlert(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(alertOk)
        present(alertVC, animated: true, completion: nil)
    }
    
    func addKey() {
        for lock in self.locks! {
            if lock.name == self.lockLabel.text {
                let token = self.randomStringWithLength()
                let key = VirtualKey(Id: self.keyNameTF.text!, token: token)
                print(">> \(key.token)")
                lock.virtualKeys.append(key)
            }
        }
       
    }
    
    func randomStringWithLength() -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< 10 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
 
