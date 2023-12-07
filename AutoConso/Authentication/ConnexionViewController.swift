//
//  ConnexionViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 26/03/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import FirebaseAuth
import CWProgressHUD
import SCLAlertView
import Firebase

class ConnexionViewController: UIViewController, UITextFieldDelegate{
	
	var checkLogin:Bool?
	var stRappelMdP:Bool?
	var password:String?
	var identifiant:String?
	
    @IBOutlet weak var btnEyeOpen: UIButton!
    @IBOutlet weak var btnEyeClosed: UIButton!
    @IBOutlet weak var switchRappelMdP: UISwitch!
	@IBOutlet weak var editTextMail: UITextField!
	@IBOutlet weak var editTextMotDePasse: UITextField!
	@IBAction func buttonValider(_ sender: UIButton) {
		connectToSystem()
		/*Utility.isConnectedToFirebase(completion: {
			(status) in
			}
		})*/
	}
	@IBAction func buttonAnnuler(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	@IBAction func switchRappelMdP(_ sender: UISwitch) {
		if sender.isOn {
			self.stRappelMdP = true
			print("stRappelMdP = true")
			UserDefaults.standard.set(editTextMotDePasse.text, forKey: "password")
			UserDefaults.standard.set(editTextMail.text, forKey: "identifiant")
			UserDefaults.standard.set(true, forKey: "prefsRappelMdp")
		}else{
			self.stRappelMdP = false
			print("stRappelMdP = false")
			UserDefaults.standard.set("", forKey: "password")
			UserDefaults.standard.set("", forKey: "identifiant")
			UserDefaults.standard.set(false, forKey: "prefsRappelMdp")
		}
	}
	@IBAction func buttonForgetPwd(_ sender: UIButton) {
		let mail = self.editTextMail.text
		if mail == "" {
			let title = NSLocalizedString("Champ mail vide", comment: "titleMailEmpty")
			let message = NSLocalizedString("Veuillez saisir un mail valide", comment: "messageMailEmpty")
			alertMessage(title: title, message: message)
		}else{
			sendPasswordReset(withEmail: mail!)
			let title = NSLocalizedString("Mail envoyé", comment: "titleResetMdPSent")
			let message = NSLocalizedString("Un mail de réinitialisation a été envoyé.", comment: "messageResetMdPSent")
			alertMessage(title: title, message: message)
		}
	}
    @IBAction func buttonInscription(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "registerVC") as! InscriptionViewController
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func btnEyeOpen(_ sender: UIButton) {
        self.btnEyeClosed.isHidden = false
        self.btnEyeOpen.isHidden = true
		self.editTextMotDePasse.isSecureTextEntry = false
    }
    @IBAction func btnEyeClosed(_ sender: UIButton) {
        self.btnEyeOpen.isHidden = false
        self.btnEyeClosed.isHidden = true
		self.editTextMotDePasse.isSecureTextEntry = true
    }
    func settingsDataAlreadyExist(Key: String) -> Bool {
		return UserDefaults.standard.object(forKey: Key) != nil
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if(!settingsDataAlreadyExist(Key: "prefsRappelMdp")){//prefsRappelMdp
			// Si cguAccept n'existe pas (ie premier lancement) on initialise la valeur a false
			print("stRappelMdp n'existe pas",false)
			self.switchRappelMdP.setOn(false, animated: true)
			
		}else{
			if(UserDefaults.standard.bool(forKey: "prefsRappelMdp")) == true {
				self.password = UserDefaults.standard.string(forKey: "password")
				self.identifiant = UserDefaults.standard.string(forKey: "identifiant")
				self.editTextMotDePasse.text = self.password
				self.editTextMail.text = self.identifiant
				self.switchRappelMdP.setOn(true, animated: true)
			}else{
				self.password = ""
				self.identifiant = ""
			}
		}
		//
		self.checkLogin = false
		
		/* Hide keyboard and manage fields navigation */
		editTextMail.delegate = self
		editTextMail.tag = 0
		editTextMail.returnKeyType = .next
		
		editTextMotDePasse.delegate = self
		editTextMotDePasse.tag = 1
		editTextMotDePasse.returnKeyType = .go
		
	}
	
	func login(withEmail email: String, password: String, _ callback: ((Error?) -> ())? = nil){
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			if let e = error{
				callback?(e)
				self.checkLogin = false
				return
			}else{
				self.checkLogin = true
			}
			callback?(nil)
		}
	}
	
	func sendPasswordReset(withEmail email: String, _ callback: ((Error?) -> ())? = nil){
		Auth.auth().sendPasswordReset(withEmail: email) { error in
			callback?(error)
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		/* Activer ce snippet pour passer d'un champ à l'autre en incrémentant */
		if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
			nextField.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
			return true;
		}
		return false
		
		/* On cache le clavier */
		textField.resignFirstResponder()
		return true;
	}
	
	func alertMessage(title: String, message: String){
		let alert = SCLAlertView()
		alert.showInfo(title, subTitle: message)
	}
	/* Fonctions utilitaires */
	
	func UIColorFromRGB(rgbValue: UInt) -> UIColor {
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	func authentication(email: String, password: String, completion: @escaping(_ res: Bool) -> Void){
		Auth.auth().signIn(withEmail: editTextMail.text!, password: editTextMotDePasse.text!) {
			(user, error) in
			
			if error == nil{
				if let userInfo = user {
					let uid = userInfo.user.uid
					UserDefaults.standard.set(uid, forKey: "userID")
					if(uid != nil){
						let tableUsersRef = Database.database().reference().child("Users").child(uid)
						
						tableUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
							print(snapshot)

							let user = snapshot as! DataSnapshot
							let userDict = user.value as! NSDictionary
							
							let profil = userDict["profil"] as! String
							let nbConn = userDict["nbConnections"] as! Int
							let userMail = userDict["userMail"] as! String
							let userPseudo = userDict["userPseudo"] as! String
							let userPoints = userDict["points"] as! Int
							let userCountry = userDict["Pays"] as! String
								
							let newNbConn = nbConn + 1
							UserDefaults.standard.setValue(profil, forKey: "usrProfil")
							UserDefaults.standard.set(uid, forKey: "userId")
							UserDefaults.standard.set(userMail, forKey: "usrEmail")
							UserDefaults.standard.set(userPseudo, forKey: "usrPseudo")
							UserDefaults.standard.set(self.getTimestamp(), forKey: "usrLastConnection")
							UserDefaults.standard.set(newNbConn, forKey: "usrNbConnections")
							UserDefaults.standard.set(userPoints, forKey: "usrPoints")
							UserDefaults.standard.set(userCountry, forKey: "usrCountry")
							
							self.updateUserInfo(usrId: uid, nbConn: newNbConn, profil: profil){
								(updateUsr) in
								
								if(updateUsr == true){
									completion(true)
								}
							}
						})
					}else{
						completion(true)
					}
				}
				//guard let usrId = Auth.auth().currentUser?.uid else { return }
				
			}else{
				completion(false)
				CWProgressHUD.dismiss()
				let title = NSLocalizedString("Erreur d'authentification", comment: "titleIncorrectLoginOrPwd")
				let message = NSLocalizedString("Login ou Mot de passe incorrect", comment: "messageIncorrectLoginOrPwd")
				self.alertMessage(title: title, message: message)
			}
		}
	}
	
	func updateUserInfo(usrId: String, nbConn: Int, profil: String, completion: @escaping(_ updateUsr: Bool) -> Void){
		let dateheure = getTimestamp()
		var db = Database.database().reference().child("Users").child(usrId)
		db.updateChildValues(["nbConnections":nbConn])
		db.updateChildValues(["lastConnexion":dateheure])
		db.updateChildValues(["profil":profil])
		completion(true)
	}
	
	func getTimestamp() -> String {
		let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
		return timestamp
	}
	
	func checkUser(usrID: String, completion: @escaping (Bool) -> Void){
		
		// create user
		let tableUsers = Database.database().reference().child("Users").child(usrID)
		
		/*if(tableUsers == nil){
			let usersDisctionary : NSDictionary =
				[
					"id" : "",
					"userMail" : self.textFieldMail.text,
					"userPseudo" : self.textFieldPseudo.text,
					"createdAt" : self.getTimestamp(),
					"lastConnexion" : self.getTimestamp(),
					"nbConnections" : 0,
					"profil" : "user",
					"Pays" : self.selectedPays,
			]
		}
		tableUsers.childByAutoId().setValue(usersDisctionary) {
			(error, ref) in
			if error != nil {
				print(error!)
			}
			else {
				let usrId = ref.key
				print("user saved successfully!")
				print("userId = %@",ref.key)
				UserDefaults.standard.set(usrId, forKey: "userId")
				UserDefaults.standard.set(self.selectedPays, forKey: "usrCountry")
			}
		}*/
		
	}
	
	func connectToSystem(){
		CWProgressHUD.setStyle(.dark)
		CWProgressHUD.show()
		Utility.connectionTimeOut = 0
		Utility.isConnectedToNetwork(customCompletionHandler:{
			(connected) in
			
			if(connected == true){
				let login = self.editTextMail.text!
				let code = self.editTextMotDePasse.text!
				self.authentication(email: login, password: code){
					(res) in
					print(res)
					let strDict = Utility.parseAppStrings()
					if(res == true){
						print("connect = true & %@",Utility.connectionTimeOut)
						let storyboard = UIStoryboard(name: "Main", bundle: nil)
						let vc = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! UITabBarController
						self.present(vc, animated: true, completion: nil)
						CWProgressHUD.dismiss()
					}
				}
			}
			
			if(connected == false){//&&(Utility.connectionTimeOut > 10)){
				CWProgressHUD.dismiss()
				print("connect = false & %@",Utility.connectionTimeOut)
				let strDict = Utility.parseAppStrings()
				
				let title = textStrings.titleNetworkNOK
				let message = textStrings.messageNetworkNOK
				let buttonOK = textStrings.strContinuer
				let buttonRelaunch = textStrings.strRelancer
				
				let appearance = SCLAlertView.SCLAppearance(
					showCloseButton: false
				)
				let popup = SCLAlertView(appearance: appearance)
				
				popup.addButton(buttonOK, backgroundColor: UIColor.orange, textColor: UIColor.white){
					let storyboard = UIStoryboard(name: "Main", bundle: nil)
					let vc = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! UITabBarController
					self.present(vc, animated: true, completion: nil)
					CWProgressHUD.dismiss()
				}
				popup.addButton(buttonRelaunch, backgroundColor: UIColor.green, textColor: UIColor.white){
					CWProgressHUD.dismiss()
					CWProgressHUD.setStyle(.dark)
					CWProgressHUD.show()
					self.connectToSystem()
				}
				popup.showWarning(title, subTitle: message)
			}
			print("Network connection is %@",connected)
		})
	}
}
