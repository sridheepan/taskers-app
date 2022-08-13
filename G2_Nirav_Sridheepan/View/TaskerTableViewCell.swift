//
//  TaskerTableViewCell.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit

class TaskerTableViewCell: UITableViewCell {

    @IBOutlet weak var taskerImg: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Make Image Corners Rounded
        taskerImg.contentMode = UIView.ContentMode.scaleAspectFill
        taskerImg.frame.size.width = 60
        taskerImg.frame.size.height = 60
        taskerImg.layer.cornerRadius = 30
        taskerImg.clipsToBounds = true
        taskerImg.layer.borderWidth = 3
        taskerImg.layer.borderColor = UIColor.systemGreen.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
