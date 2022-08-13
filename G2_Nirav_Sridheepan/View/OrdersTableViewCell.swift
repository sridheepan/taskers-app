//
//  OrdersTableViewCell.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit

class OrdersTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    
    @IBOutlet weak var taskerImage: UIImageView!
    @IBOutlet weak var lblTaskerName: UILabel!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet weak var lblTaskScheduleDate: UILabel!
    @IBOutlet weak var lblTaskScheduleTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Make Image Corners Rounded
        taskerImage.contentMode = UIView.ContentMode.scaleAspectFill
        taskerImage.layer.cornerRadius = taskerImage.frame.size.height/2
        taskerImage.clipsToBounds = true
        taskerImage.layer.borderWidth = 3
        taskerImage.layer.borderColor = UIColor.systemGreen.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
