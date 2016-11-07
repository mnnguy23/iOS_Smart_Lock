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
    var lockId: String
    var location: String
    
    init(lockId: String, name: String, location: String) {
        self.lockId = lockId
        self.name = name
        self.location = location
    }
}
