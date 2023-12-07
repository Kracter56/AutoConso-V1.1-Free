//
//  AdminHomePage.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 06/05/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit


class AdminHomePage: UITableViewController {
	
	/*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
		
		/*if indexPath.row == 0 {
			cell.textLabel!.text = indexPath.row.description
		} else if indexPath.row == 1 {
			cell.textLabel!.text = indexPath.row.description
		}*/
		return cell
	}*/
	
	/*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}*/
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                break
            case 1:
                print("1-1")
                break
            default:
                break
            }
            break
        case 1:
            break
        default:
            break
		/*print("click")
		
		let AddController = AddStationEurekaViewController()
		self.navigationController?.pushViewController(AddController, animated: true)
		*/
		/*if indexPath.row == 0 {
			//here you can enter the action you want to start when cell 1 is clicked
		}*/
        }
		
		
	}
	
	
	
}
