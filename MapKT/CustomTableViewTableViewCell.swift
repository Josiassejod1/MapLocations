//
//  CustomTableViewTableViewCell.swift
//  MapKT
//
//  Created by Dalvin Sejour on 1/17/19.
//  Copyright © 2019 Dalvin Sejour. All rights reserved.
//

import UIKit

class CustomTableViewTableViewCell: UITableViewCell {
    @IBOutlet var instructions: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
