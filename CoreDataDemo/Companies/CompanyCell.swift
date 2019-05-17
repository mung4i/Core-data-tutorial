//
//  CompaniesCell.swift
//  CoreDataDemo
//
//  Created by Martin Mungai on 17/05/2019.
//  Copyright © 2019 GeniusAppz. All rights reserved.
//

import UIKit


class CompanyCell: UITableViewCell {
    
    //
    // MARK: Computed Properties
    //
    
    var company: Company? {
        
        didSet {
            
            if let imageData = company?.imageData {
                companyImageView.image = UIImage(data: imageData)
            }
            
            let name = company?.name ?? "88y"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            
            let date = dateFormatter.string(from: company?.founded ?? Date())
            
            dateFoundedLabel.text = "\(name) - Founded: \(date)"
        }
    }
    
    //
    // MARK: Overriden Internal Methods
    //
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .tealColor
        
        addSubview(companyImageView)
        
        companyImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        companyImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        companyImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        companyImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(dateFoundedLabel)
        
        dateFoundedLabel.leftAnchor.constraint(equalTo: companyImageView.rightAnchor, constant: 8).isActive = true
        dateFoundedLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dateFoundedLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        dateFoundedLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // MARK: Constants
    //
    
    let companyImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(named: "default_profile"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.darkBlue.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let dateFoundedLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Company Name"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
