//
//  PopupViewController.swift
//  TRIDZ
//
//  Created by sangheon on 2021/05/22.
//

import UIKit

class PopupViewController:UIViewController {
    
    
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var wordName: UILabel!
    
    @IBOutlet weak var wordDescription: UITextView!
    
    @IBOutlet weak var popView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popView.layer.cornerRadius = 20
        labelView.layer.cornerRadius = 20
        labelView.layer.maskedCorners =  [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        let ud = UserDefaults.standard
         
         if let name = ud.string(forKey: "wordName") {
            wordName.text = name
         }
        if let disc = ud.string(forKey: "disc") {
            wordDescription.text = disc
        }
    }
    
    
    @IBAction func PostButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goCancel(_ sender: Any) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
