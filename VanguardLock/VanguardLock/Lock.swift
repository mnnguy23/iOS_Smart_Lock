//
//  Lock.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/31/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import Foundation

class Lock {
    var locked: Bool
    var name: String
    var lockId: Int
    var serialNumber: String
    var location: String
    var logs:[Log] = []
    var owner:Int
    var users:[User] = []
    
    init(lockId: Int, owner: Int, name: String, location: String, serialNumber: String, locked: Bool) {
        self.lockId = lockId
        self.owner = owner
        self.name = name
        self.location = location
        self.serialNumber = serialNumber
        self.locked = locked
    }
}
