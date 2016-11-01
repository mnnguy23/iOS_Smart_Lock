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
    var lockId: String
    var virtualKeys : [VirtualKey]?
    
    init(lockId: String) {
        self.lockId = lockId
    }
}
