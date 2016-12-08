//
//  Log.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 12/7/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import Foundation

class Log {
    let id: Int
    let lockStatus:String
    let time: String
    
    init(id: Int, lockStatus: String, time: String) {
        self.id = id
        self.lockStatus = lockStatus
        self.time = time
    }
}
