//
//  LoginViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 10/03/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn


class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().uiDelegate = self
	}
	// Present a sign-in with Google window
	@IBAction func googleSignIn(_ sender: Any) {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "registerVC") as! InscriptionViewController
		self.present(vc, animated: true, completion: nil)
		
		/*GIDSignIn.sharedInstance().signIn()
		
		
		let userID = Auth.auth().currentUser!.uid
		print("userID",userID)
		UserDefaults.standard.set(userID, forKey: "userID")
		
		let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let mainViewController = storyBoard.instantiateViewController(withIdentifier: "mainViewController") as! UITabBarController
		self.present(mainViewController, animated: true, completion: nil)*/
	}
	@IBAction func buttonConnexion(_ sender: UIButton) {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ConnexionViewController
		self.present(vc, animated: true, completion: nil)

		
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		/*print("Google Sing In didSignInForUser")
		if let error = error {
			print(error.localizedDescription)
			return
		}
		guard let authentication = user.authentication else { return }
		let credential = GoogleAuthProvider.credential(withIDToken: (authentication.idToken)!, accessToken: (authentication.accessToken)!)
		// When user is signed in
		Auth.auth().signIn(with: credential, completion: { (user, error) in
			if let error = error {
				print("Login error: \(error.localizedDescription)")
				return
			}
		})*/
	}
	// Start Google OAuth2 Authentication
	func sign(_ signIn: GIDSignIn?, present viewController: UIViewController?) {
		
		// Showing OAuth2 authentication window
		if let aController = viewController {
			present(aController, animated: true) {() -> Void in }
		}
	}
	// After Google OAuth2 authentication
	func sign(_ signIn: GIDSignIn?, dismiss viewController: UIViewController?) {
		// Close OAuth2 authentication window
		dismiss(animated: true) {() -> Void in }
	}
	
}
