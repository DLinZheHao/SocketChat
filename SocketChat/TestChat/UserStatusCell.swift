//
//  userStatusCell.swift
//  CounterSocketIOS
//
//  Created by 林哲豪 on 2023/9/1.
//

import UIKit

class UserStatusCell: UITableViewCell {

    @IBOutlet weak var userNikenameLabel: UILabel!
    @IBOutlet weak var isConntectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
