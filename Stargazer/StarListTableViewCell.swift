//
//  StarListTableViewCell.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-07.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import TagListView

class StarListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        // HACK: avoid tag color change when cell is highlighted
        tagListView.tagBackgroundColor = tagListView.tagBackgroundColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // HACK: avoid tag color change when cell is selected
        tagListView.tagBackgroundColor = tagListView.tagBackgroundColor
    }

}
