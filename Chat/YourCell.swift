//
//  YourCell.swift
//  TRIDZ
//
//  Created by sangheon on 2021/05/22.
//

import UIKit

class YourCell: UITableViewCell {

    @IBOutlet weak var yourCellTextView: UITextView!
    @IBOutlet weak var myCellBackView:UIImageView!
    var yourobj : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myCellBackView.layer.cornerRadius = 20
        myCellBackView.layer.borderWidth = 1
        myCellBackView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func goPopup(_ sender: Any) {
        if let btnAction = self.yourobj
        {
            btnAction()
          //  user!("pass string")
        }
    }
    
    
}
