//
//  InscriptionViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 26/03/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import CoreLocation
import SCLAlertView

class InscriptionViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	
	var selectedPays:String?
	var pseudoEdit:Bool?
	let locationManager = CLLocationManager()
	var countriesList = ["France", "United States", "United Kingdom", "Germany", "Switzerland", "Netherlands", "Spain"]
	@IBOutlet weak var textFieldMail: UITextField!
	@IBOutlet weak var textFieldPseudo: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldPasswordRepeat: UITextField!
    @IBOutlet weak var cityPickerView: UIPickerView!
    
    @IBAction func buttonValider(_ sender: Any) {
		
		if textFieldPassword.text != textFieldPasswordRepeat.text {
			
			let titlePasswordIncorrect = NSLocalizedString("Mot de passe incorrect.", comment: "titlePasswordIncorrect")
			let messagePasswordIncorrect = NSLocalizedString("Vos mots de passe ne correspondent pas", comment: "messagePasswordIncorrect")
			
			let popupPwdIncorrect = SCLAlertView()
			popupPwdIncorrect.showError(titlePasswordIncorrect, subTitle: messagePasswordIncorrect)
		}
		else{
			Auth.auth().createUser(withEmail: textFieldMail.text!, password: textFieldPassword.text!){ (user, error) in
				if error == nil {
					//self.performSegue(withIdentifier: "signupToHome", sender: self)
					let uid = user?.user.uid
					// create user
					let tableUsers = Database.database().reference().child("Users")
					
					let usersDisctionary : NSDictionary =
						[
							"id" : "",
							"userMail" : self.textFieldMail.text,
							"userPseudo" : self.textFieldPseudo.text,
							"createdAt" : self.getTimestamp(),
							"lastConnexion" : self.getTimestamp(),
							"nbConnections" : 0,
							"profil" : "user",
							"points" : 0,
							"Pays" : self.selectedPays
					]
					
					tableUsers.child(uid!).setValue(usersDisctionary) {
						(error, ref) in
						if error != nil {
							print(error!)
						}
						else {
							let usrId = ref.key
							print("user saved successfully!")
							print("userId = %@",ref.key)
							UserDefaults.standard.set(usrId, forKey: "userId")
							UserDefaults.standard.set(self.textFieldMail.text, forKey: "usrEmail")
							UserDefaults.standard.set(self.textFieldPseudo.text, forKey: "usrPseudo")
							UserDefaults.standard.set(self.getTimestamp(), forKey: "usrLastConnection")
							UserDefaults.standard.set(0, forKey: "usrNbConnections")
							UserDefaults.standard.set(0, forKey: "usrPoints")
							UserDefaults.standard.set("user", forKey: "usrProfil")
							UserDefaults.standard.set(self.selectedPays, forKey: "usrCountry")
							UserDefaults.standard.set(self.getTimestamp(), forKey: "usrDateInscription")
						}
					}
					
					let storyboard = UIStoryboard(name: "Main", bundle: nil)
					let vc = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! UITabBarController
					self.present(vc, animated: true, completion: nil)
				}
				else{
					
					let popup = SCLAlertView()
					popup.showError("Error", subTitle: error!.localizedDescription)
				}
			}
		}
        
    }
    @IBAction func buttonAnnuler(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		self.pseudoEdit = true
		self.cityPickerView.delegate = self
		self.cityPickerView.dataSource = self
		
		self.selectedPays = "France"
		/* Hide keyboard and manage fields navigation */
		textFieldPseudo.delegate = self
		textFieldPseudo.tag = 0
		textFieldPseudo.returnKeyType = .next
		
		textFieldMail.delegate = self
		textFieldMail.tag = 1
		textFieldMail.returnKeyType = .next
		
		textFieldPassword.delegate = self
		textFieldPassword.tag = 2
		textFieldPassword.returnKeyType = .next
		
		textFieldPasswordRepeat.delegate = self
		textFieldPasswordRepeat.tag = 3
		textFieldPasswordRepeat.returnKeyType = .done
		
        /*let bundle = Bundle.main
        let plistURL = bundle.url(forResource: "countries", withExtension: ".plist")
        let countriesDict = NSDictionary(contentsOf: plistURL!) as! [String: [String]]
        let allWeights = countriesDict.keys*/
        //convertFrom = allWeights.sorted()

        
		//textFieldMail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return countriesList.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return countriesList[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		self.selectedPays = countriesList[row] as String
		// use the row to get the selected row from the picker view
		// using the row extract the value from your datasource (array[row])
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
	
	func getTimestamp() -> String {
		let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
		return timestamp
	}
	
	func createUser(email: String, password: String, _ callback: ((Error?) -> ())? = nil){
		Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
			if let e = error{
				callback?(e)
				return
			}
			callback?(nil)
		}
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
}
