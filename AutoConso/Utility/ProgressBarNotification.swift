//
//  ProgressBarNotification.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 28/02/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit

class ProgressBarNotification {
    
    internal static var strLabel = UILabel()
    internal static var messageFrame = UIView()
    internal static var activityIndicator = UIActivityIndicatorView()
    
    internal static func progressBarDisplayer(msg:String,indicator:Bool ){
        
        
        let view1 = UIApplication.shared.delegate?.window!!.rootViewController?.view
        
        view1?.isUserInteractionEnabled = false
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.white
        messageFrame = UIView(frame: CGRect(x: view1!.frame.midX - 90, y: view1!.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
			activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view1!.addSubview(messageFrame)
        
        
    }
    
    internal static func removeProgressBar() {
        
        let view1 = UIApplication.shared.delegate?.window!!.rootViewController?.view
        
        _ = view1?.subviews.filter({ (view) -> Bool in
            if view == ProgressBarNotification.messageFrame {
                view.removeFromSuperview()
            }
            return false
        })
        
        ProgressBarNotification.messageFrame.removeFromSuperview()
        
        view1?.isUserInteractionEnabled = true
        
    }
    
    deinit{
        
    }
}
