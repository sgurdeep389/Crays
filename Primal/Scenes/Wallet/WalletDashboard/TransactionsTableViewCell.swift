//
//  TransactionsTableViewCell.swift
//  Crays
//
//  Created by Gurdeep Singh  on 29/11/25.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var lblPaymentTime: UILabel!
    @IBOutlet weak var imgPayment: UIImageView!
    @IBOutlet weak var viewPayment: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
