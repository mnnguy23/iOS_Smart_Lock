//
//  VirtualKey.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/31/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import Foundation

class VirtualKey {
    let Id: String
    let token: String
    
    init(Id: String, token: String) {
        self.Id = Id
        self.token = token
    }
}
