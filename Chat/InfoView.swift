//
//  InfoView.swift
//  TRIDZ
//
//  Created by sangheon on 2021/05/22.
//

import UIKit

class InfoView:UIView {
    
    var chatData:chatType? {
        didSet {
            
        }
    }
    
    lazy var nameView:UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.addSubview(self.nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return view
    }()
    
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "NAME"
        return label
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViewComponent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureViewComponent() {
        self.backgroundColor = .black
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.addSubview(nameView)
        nameView.translatesAutoresizingMaskIntoConstraints = false
        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        nameView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nameView.heightAnchor.constraint(equalToConstant: 46).isActive = true
    }
    }
