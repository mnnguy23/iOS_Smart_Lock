//
//  Lock.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/31/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import Foundation

class Lock {
    var locked: Bool = false
    var name: String
    var lockId: Int
    var serialNumber: String
    var location: String
    var logs:[String] = []
    var lockStatus:[String] = []
    var owner:Int
    var users:[User] = []
    
    init(lockId: Int, owner: Int, name: String, location: String, serialNumber: String) {
        self.lockId = lockId
        self.owner = owner
        self.name = name
        self.location = location
        self.serialNumber = serialNumber
    }
}
