//
//  ViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 18/07/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit

class NavigationItem: UINavigationItem {
    @IBInspectable public var barTintColor: UIColor?
}

class NavigationController: UINavigationController, UIGestureRecognizerDelegate {
    func applyTint(_ navigationItem: UINavigationItem?) {
        if let item = navigationItem as? NavigationItem {
            self.navigationBar.barTintColor = item.barTintColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTint(self.topViewController?.navigationItem)
        self.interactivePopGestureRecognizer?.delegate = self
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        applyTint(viewController.navigationItem)
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let viewController = super.popViewController(animated: animated)
        
        applyTint(self.topViewController?.navigationItem)
        return viewController
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let result = super.popToViewController(viewController, animated: animated)
        
        applyTint(viewController.navigationItem)
        return result
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let result = super.popToRootViewController(animated: animated)
        
        applyTint(self.topViewController?.navigationItem)
        return result
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
