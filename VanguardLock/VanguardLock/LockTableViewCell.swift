//
//  LockTableViewCell.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 11/7/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class LockTableViewCell: UITableViewCell {

    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var manageButton: UIButton!

    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
