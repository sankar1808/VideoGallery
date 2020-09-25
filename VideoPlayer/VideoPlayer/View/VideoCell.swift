//
//  VideoCell.swift
//  VideoPlayer
//
//  Created by Sankaranarayana Settyvari on 24/09/20.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImageThumbnail: UIImageView!
    @IBOutlet weak var bookmark: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        videoView.layer.borderWidth = 1
        videoView.layer.cornerRadius = 10
        videoView.layer.borderColor = UIColor.gray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
