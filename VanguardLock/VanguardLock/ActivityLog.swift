//
//  ActivityLog.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 12/5/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import Foundation

class ActivityLog {
    let time:String
    let status:String
    let lockID: Int
    
    init(time: String, status:String, lockID: Int) {
        self.time = time
        self.status = status
        self.lockID = lockID
    }
}
