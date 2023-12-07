//
//  CGUViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 07/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView

class CGUViewController: UIViewController {

    @IBOutlet weak var btnAnnuler: UIButton!
    @IBOutlet weak var btnAccepter: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var textFr: UITextView!
    @IBOutlet weak var textEn: UITextView!
    var cguAccept:Bool = false
    @IBAction func btnAccepter(_ sender: Any) {
        if(self.cguAccept == false){
            
            let popupCheckTitle = NSLocalizedString("Consentement utilisateur", comment: "popupCheckTitle")
            let popupCheckMessage = NSLocalizedString("Veuillez confirmer votre consentement en cochant la case avant de valider", comment: "popupCheckMessage")
            let popupCheckYes = NSLocalizedString("J'ai compris", comment: "popupCheckYes")
			
			SweetAlert().showAlert(popupCheckTitle, subTitle: popupCheckMessage, style: AlertStyle.warning, buttonTitle:popupCheckYes, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0)) { (isOtherButton) -> Void in
				print("L'utilisateur a donné son consentementn mais n'a pas coché la case")
				print("popupCheck",self.cguAccept)
			}
        }else{
            print("L'utilisateur a donné son consentement et a coché la case")
            UserDefaults.standard.set(true, forKey: "cguAccept")
            print("popupCheck",self.cguAccept)
            self.cguAccept = true
            self.dismiss(animated: true)
        }
        
    }
    @IBAction func btnAnnuler(_ sender: Any) {
        alertCGUDecline()
        //SCAlertViewDecline()
    }
    
    /* Cette fonction ne gère que l'affichage de la case à cocher. N'intervient pas sur le résultat */
    @IBAction func BtnCheck(_ sender: UIButton) {
        if(self.cguAccept == false){
            print("checkPressFalse",self.cguAccept)
            self.cguAccept = true
			btnCheck.setBackgroundImage(UIImage(named: "icon_checked"), for: UIControl.State.normal)
        }else{
            print("checkPressTrue",self.cguAccept)
            self.cguAccept = false
			btnCheck.setBackgroundImage(UIImage(named: "icon_unchecked"), for: UIControl.State.normal)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /* Vérification de la langue de l'iphone */
        let strLangue = Locale.current.languageCode

        if(strLangue == "fr"){
            self.textEn.isHidden = true
        }else{
            self.textEn.isHidden = false
        }
        
        /* Vérification de l'état d'acceptation des CGU */
        self.cguAccept = UserDefaults.standard.bool(forKey: "cguAccept")
        print("CGUviewDidLoad, CGUAcceptState",self.cguAccept)
        if(self.cguAccept == false){
			btnCheck.setBackgroundImage(UIImage(named: "icon_unchecked"), for: UIControl.State.normal)
        }else{
			btnCheck.setBackgroundImage(UIImage(named: "icon_checked"), for: UIControl.State.normal)
        }
        
    }
    
    func alertCGUDecline(){
        let CGUDeclineTitle = NSLocalizedString("Réinitialisation", comment: "CGUDeclineTitle")
        let CGUDeclineMessage = NSLocalizedString("En refusant les conditions générales d'utilisation, vous êtes sur le point d'effacer toutes les données de l'application. Voulez-vous continuer ?", comment: "CGUDeclineMessage")
        let CGUDeclineYes = NSLocalizedString("Oui", comment: "CGUDeclineYes")
        let CGUDeclineNo = NSLocalizedString("Non", comment: "CGUDeclineNo")
		let confirmEraseTitle = NSLocalizedString("Réinitialisé", comment: "confirmEraseTitle")
		let confirmEraseMessage = NSLocalizedString("L'application a été réinitialisée !", comment: "confirmEraseMessage")
		
		SweetAlert().showAlert(CGUDeclineTitle, subTitle: CGUDeclineMessage, style: AlertStyle.warning, buttonTitle:CGUDeclineNo, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0) , otherButtonTitle:  CGUDeclineYes, otherButtonColor: self.UIColorFromRGB(rgbValue: 0xDD6B55)) { (isOtherButton) -> Void in
			if isOtherButton == true {
				print("Cancel Button Pressed")
				print("CGUDeclineNo(Cancel)",UserDefaults.standard.object(forKey: "cguAccept"))
			}
			else {
				print("L'utilisateur a décliné les CGU")
				UserDefaults.standard.set(false, forKey: "cguAccept")
				print("CGUDeclineYes",UserDefaults.standard.object(forKey: "cguAccept"))
				self.eraseAllData()
				SweetAlert().showAlert(confirmEraseTitle, subTitle: confirmEraseMessage, style: AlertStyle.success)
			}
		}
    }
    

    func eraseAllData(){
        print("CGUViewController:eraseAllData")
        let realm = try! Realm()
        try! realm.write{
            realm.deleteAll()
        }
    }
    
    func SCAlertViewDecline(){
        let CGUDeclineTitle = NSLocalizedString("Réinitialisation", comment: "CGUDeclineTitle")
        let CGUDeclineMessage = NSLocalizedString("En refusant les conditions générales d'utilisation, vous êtes sur le point d'effacer toutes les données de l'application. Voulez-vous continuer ?", comment: "CGUDeclineMessage")
        let CGUDeclineYes = NSLocalizedString("Oui", comment: "CGUDeclineYes")
        let CGUDeclineNo = NSLocalizedString("Non", comment: "CGUDeclineNo")
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton(CGUDeclineYes){
            print("L'utilisateur a décliné les CGU")
            UserDefaults.standard.set(false, forKey: "cguAccept")
            print("CGUDeclineYes",UserDefaults.standard.object(forKey: "cguAccept"))
            self.eraseAllData()
            //self.dismiss(animated: true)
        }
        alertView.addButton(CGUDeclineNo) {
            print("CGUDeclineNo(Cancel)",UserDefaults.standard.object(forKey: "cguAccept"))
        }
        
        alertView.showWarning(CGUDeclineTitle, subTitle: CGUDeclineMessage)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
