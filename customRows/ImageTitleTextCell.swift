//
//  ImageTitleTextCell.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 22/10/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Eureka
import UIKit
import Foundation

final class ImageTitleTextRow: Row<ImageTitleTextCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ImageTitleTextCell>(nibName: "ImageTitleTextCell")
    }
}

class ImageTitleTextCell: Cell<obj>, CellType {

	@IBOutlet var image: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet var text: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override func setup() {
        super.setup()
        // we do not want our cell to be selected in this case. If you use such a cell in a list then you might want to change this.
        selectionStyle = .none

        // configure our profile picture imageView
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true

        // define fonts for our labels
        title.font = .systemFont(ofSize: 18)
        text.font = .systemFont(ofSize: 15)
        
        // set the textColor for our labels
		title.textColor = .black
		text.textColor = .gray
		
        // specify the desired height for our cell
        height = { return 94 }

        // set a light background color for our cell
        backgroundColor = UIColor(red:0.984, green:0.988, blue:0.976, alpha:1.00)
    }

    override func update() {
        super.update()

        // we do not want to show the default UITableViewCell's textLabel
        textLabel?.text = nil

        // get the value from our row
        guard let obj = row.value else { return }

        // set the image to the userImageView. You might want to do this with AlamofireImage or another similar framework in a real project
		image.image = UIImage(named: "icon_fuels")
        

        // set the texts to the labels
		title.text = obj.title
		text.text = obj.text
    }
    
}

struct obj: Equatable {
    var title: String
    var text: String
    var image: Data
}

func ==(lhs: obj, rhs: obj) -> Bool {
	return lhs.image == rhs.image
}
