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
    var key:VirtualKey?

    @IBOutlet weak var lockPickerView: UIPickerView!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var keyTextField: UITextField!
    
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var result = false
        if(identifier == "saveKeyUnwind") {
        if !(keyTextField.text?.isEmpty)! {
        result = createAlert(title: "Are you sure?", message: "Do you want to create a key for this lock: \(lockLabel.text!)")
            }
        }
        return result
    }
    
    func createAlert(title: String, message: String) -> Bool {
        var result = false
        let alertVC = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.alert)
        let alertYes = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            self.addKey()
            result = true
        }
        let alertNo = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            result = false
        }
        alertVC.addAction(alertYes)
        alertVC.addAction(alertNo)
        present(alertVC, animated: true, completion: nil)
        return result
    }
    
    func addKey() {
        for lock in self.locks! {
            if lock.name == self.lockLabel.text {
                let token = self.randomStringWithLength()
                let key = VirtualKey(Id: self.keyTextField.text!, token: token)
                lock.virtualKeys?.append(key)
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
 
