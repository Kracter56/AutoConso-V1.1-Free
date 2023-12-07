//
//  AddCarViewController.swift
//  AutoConso-v0
//
//  Created by Edgar PETRUS on 01/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation
import SCLAlertView
import CWProgressHUD

/*struct carBrand : Decodable {
    let brand : String
    let models : [String]
}*/

class AddCarViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var realm:Realm?
    var carsVC : CarsViewController!
    var currentCar: Car?
    var selectedCar = ""
    var selectedColour = ""
    var selectedMarque = ""
    var selectedType = ""
    var selectedEnergy = ""
    var PickerViewType : UIPickerView!
    var PickerViewCarMarque : UIPickerView!
    var PickerViewCarModele : UIPickerView!
    var PickerViewCarDetail : UIPickerView!
    var PickerViewCarEnergy : UIPickerView!
    var cars: [carBrands]?
    var idCar = ""
    var langue = ""
    var marqueEditMode = false
    var formatDate = "dd/MM/yyyy"
    var valTest = false
    var settings:UserDefaults?
    var settingsDataAlreadyExist:UserDefaults?
    @IBOutlet weak var imageViewCar: UIImageView!
    
    /* Liste de marques de voitures et de couleurs */
    let listOfMarques:[String] = ["ALFA ROMEO", "AUDI", "BMW", "CADILLAC", "CHEVROLET", "CHRYSLER", "CITROEN", "DACIA", "DAEWOO", "DAIHATSU", "DODGE", "DS", "FIAT", "FORD", "HONDA", "HUMMER", "HYUNDAI", "INFINITI", "ISUZU", "IVECO", "JAGUAR", "KIA", "LADA", "LANCIA", "LAND ROVER", "LEXUS", "MAZDA", "MERCEDES", "MG", "MINI", "MITSUBISHI", "NISSAN", "OPEL", "PEUGEOT", "PORSCHE", "RENAULT", "ROVER", "SAAB", "SEAT", "SIMCA", "SKODA", "SMART", "SUZUKI", "SSANGYONG", "SUBARU", "TALBOT", "TESLA", "TOYOTA", "VOLKSWAGEN", "VOLVO"]
    
    let listTypesFR:[String] = ["MOTO", "SCOOTER", "VOITURE"]
    let listTypesEN:[String] = ["BIKE", "SCOOTER", "CAR"]
    
    let listOfColors:[String] = ["Bleu", "Rouge", "Vert", "Noir", "Gris", "Violet", "Blanc", "Jaune", "Orange", "Bordeaux", "Beige"]
    
    let listOfPseudos:[String] = ["Navy", "Miranda", "Appen", "Luna", "Carl", "Joe", "Kenny", "Ken", "Filou", "Jumbo", "Bingo", "Violetta", "Grisouille", "Bianca", "Polo", "Zoe", "Enzo", "Titine", "Choupinette", "Lisa", "Natacha", "Bolide", "Béhème", "Charette", "Chariot", "Tractor", "Velociraptor", "Raptor", "Speedy", "Brouette", "Trottinette", "Pinky", "Boudin", "Zapette", "Choupette", "Choupinou", "Blue", "Ramses", "Cleopatra", "Princesse", "Inconnu", "Michka", "Masha"]
    
    let listOfScooters:[String] = ["Adly", "Aeon", "Aprilia", "Bajaj", "Baotian", "Benelli", "Beta", "Tata Sco", "BMW", "Daelim", "Dafra", "Derbi", "Garelli", "Genuine", "Gilera", "Gogoro", "Hero", "Honda", "Hyosung", "Junak", "Kawasaki", "Kymco", "Lifan", "Lohia Machinery Limited (LML)", "MBK (formerly Motobécane)", "Modenas", "Peugeot", "PGO Scooters", "API", "Piaggio", "Rieju", "Qingqi", "SFM (formerly Sachs)", "Solifer", "Suzuki", "Taiwan Golden Bee(TGB)", "Tomos", "TVS", "Unu", "Vespa", "Xingyue", "Yamaha", "Zongshen", "Znen"]
    
    let listOfBikes:[String] = ["Adly", "Aeon", "Aprilia", "Bajaj", "Baotian", "Benelli", "Beta", "Tata Sco", "BMW", "Daelim", "Dafra", "Derbi", "Garelli", "Genuine", "Gilera", "Gogoro", "Hero", "Honda", "Hyosung", "Junak", "Kawasaki", "Kymco", "Lifan", "Lohia Machinery Limited (LML)", "MBK (formerly Motobécane)", "Modenas", "Peugeot", "PGO Scooters", "API", "Piaggio", "Rieju", "Qingqi", "SFM (formerly Sachs)", "Solifer", "Suzuki", "Taiwan Golden Bee(TGB)", "Tomos", "TVS", "Unu", "Vespa", "Xingyue", "Yamaha", "Zongshen", "Znen"]
    
    let listOfEnergiesFR:[String] = ["Essence", "Diesel", "Hybride", "Electrique", "Manuel", "Autre"]
    let listOfEnergiesENG:[String] = ["Gasoline", "Diesel", "Hybrid", "Electric", "Manual", "Other"]
    
    //@IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet weak var contentView: UIView!
    @IBOutlet weak var TextFieldTypeVehicule: UITextField!
    @IBOutlet weak var TextFieldCarModele: UITextField!
    @IBOutlet weak var TextFieldCarMarque: UITextField!
    @IBOutlet weak var TextFieldCarMotorisation: UITextField!
    @IBOutlet weak var TextFieldDateAchat: UITextField!
    @IBOutlet weak var TextFieldCarPressionPneus: UITextField!
    @IBOutlet weak var TextFieldDateImmatriculation: UITextField!
    @IBOutlet weak var TextFieldCarNumeroSerie: UITextField!
    @IBOutlet weak var TextFieldCarPseudo: UITextField!
    @IBOutlet weak var TextFieldCarImmatriculation: UITextField!
    @IBOutlet weak var TextFieldCarKilometrage: UITextField!
    @IBOutlet weak var TextFieldCarReservoir: UITextField!
    @IBOutlet weak var TextFieldCarCommentaire: UITextField!
    @IBOutlet weak var TextFieldCarEnergy: UITextField!
    @IBOutlet weak var imagePhotoJustif: UIImageView!
    @IBOutlet weak var imageMarque: UIImageView!
    @IBOutlet weak var imageViewVehicleType: UIImageView!
    
    @IBAction func TextFieldTypeVehicule(_ sender: UITextField) {
        
    }
    /* Affichage d'un datePicker au click sur la cellule de date */
    @IBAction func TextFieldDateAchat(_ sender: UITextField) {
        
        let dateAchatPickerView:UIDatePicker = UIDatePicker()
		dateAchatPickerView.datePickerMode = UIDatePicker.Mode.date
        
        if(self.langue == "fr"){
            dateAchatPickerView.locale = Locale(identifier: "fr_FR")
        }else{
            dateAchatPickerView.locale = Locale(identifier: "en_US")
        }
        
        sender.inputView = dateAchatPickerView
		dateAchatPickerView.addTarget(self, action: #selector(AddCarViewController.dateAchatPickerValueChanged), for: UIControl.Event.valueChanged)
        
    }
    
    /* Affichage d'un datePicker au click sur la cellule de date */
    @IBAction func TextFieldDateImmat(_ sender: UITextField) {
        
        let dateImmatPickerView:UIDatePicker = UIDatePicker()
		dateImmatPickerView.datePickerMode = UIDatePicker.Mode.date
        
        if(self.langue == "fr"){
            dateImmatPickerView.locale = Locale(identifier: "fr_FR")
        }else{
            dateImmatPickerView.locale = Locale(identifier: "en_US")
        }
        
        sender.inputView = dateImmatPickerView
		dateImmatPickerView.addTarget(self, action: #selector(AddCarViewController.dateImmatPickerValueChanged), for: UIControl.Event.valueChanged)
        
    }

    @IBAction func btnSuggererPseudo(_ sender: UIButton) {
        let randNumber = Int(arc4random_uniform(UInt32(listOfPseudos.count)))
        TextFieldCarPseudo.text = listOfPseudos[randNumber]
    }
    @IBAction func btnAssocierJutifs(_ sender: Any) {
        PhotoChooser.shared.showAttachmentActionSheet(vc: self)
        PhotoChooser.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.settings?.set(true, forKey: "presenceCarteGrise")
            self.imagePhotoJustif.image = image
        }
    }
    @IBAction func btnChangerPhoto(_ sender: UIButton) {
        PhotoChooser.shared.showAttachmentActionSheet(vc: self)
        PhotoChooser.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.imageViewCar.image = image
        }
    }
    
    @IBAction func btnSaveCar(_ sender: UIBarButtonItem) {
        /* Initialisation de Realm */
        let realm = try! Realm()
        print("AddCarViewController:realmInit")
		CWProgressHUD.setStyle(.dark)
		CWProgressHUD.show()
		
        let car:Car = Car()
		
		/*var lastId = realm.objects(Car.self).last?.id
		// MAJ de l'id de la voiture
		if (lastId != nil){
			car.id = lastId! + 1
		}*/
        if (Validate() == true) {
            
            createCarId()
        
            car.idCar = idCar
            valTest = true
			
            if let textType = self.TextFieldTypeVehicule.text{
                car.type = textType
            }
            
            if let textCarMarque = self.TextFieldCarMarque.text{
                car.marque = textCarMarque
            }
            
            if let textCarModele = self.TextFieldCarModele.text{
                car.modele = textCarModele
            }
        
            if let textCarEnergy = self.TextFieldCarEnergy.text{
                car.energy = textCarEnergy
            }
            
            if let textCarImmatriculation = self.TextFieldCarImmatriculation.text{
                car.immatriculation = textCarImmatriculation
            }
            
            if let textCarPseudo = self.TextFieldCarPseudo.text{
                if textCarPseudo.isEmpty {car.pseudo = self.TextFieldCarModele.text!}
                else{car.pseudo = textCarPseudo}
            }
            
            if let textKm = self.TextFieldCarKilometrage.text{
                let usr = UserDefaults.standard
                usr.set(textKm,forKey: "carKM")
                if(textKm == ""){
                    car.kilometrage = 0
                }else{
                    car.kilometrage = Int(textKm)!
                }
            }
            
            if let textReservoir = self.TextFieldCarReservoir.text{
                if(textReservoir == ""){
                    car.reservoir = 0
                }else{
                    car.reservoir = Int(textReservoir)!
                }
            }
            
            if let textCommentaire = self.TextFieldCarCommentaire.text{
                car.commentaire = textCommentaire
            }
            
            if let textdateImmatriculation = self.TextFieldDateImmatriculation.text{
                
                let dateFormatter = DateFormatter()
                let dateFormat = formatDate
                dateFormatter.dateFormat = dateFormat
                
                guard let dateImmat = dateFormatter.date(from: textdateImmatriculation) else {
                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                }
                
                car.dateImmat = dateImmat
            }
            
            if let textdateAchat = self.TextFieldDateAchat.text{
                
                let dateFormatter = DateFormatter()
                let dateFormat = formatDate
                dateFormatter.dateFormat = dateFormat
                
                guard let dateAchat = dateFormatter.date(from: textdateAchat) else {
                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                }
                
                car.dateAchat = dateAchat
            }
            
            if let textMotorisation = self.TextFieldCarMotorisation.text{
                car.motorisation = textMotorisation
            }
            
            if let textNumeroSerie = self.TextFieldCarNumeroSerie.text{
                car.numeroSerie = textNumeroSerie
            }
            
            if let textPressionPneu = self.TextFieldCarPressionPneus.text{
                car.pressionPneu = textPressionPneu
            }
            
			if let imageCar = imageViewCar.image?.pngData() {
                let bytes = imageCar.count
                let MB = Double(bytes)/1000000.0
                /*let kB = Double(bytes) / 1000.0 // Note the difference
                let KB = Double(bytes) / 1024.0 // Note the difference*/
                print("Taille image : "+MB.description)
                if(MB > 16.0){
                    print("image condition NOK")
                    
                    let imageTooBigTitle = NSLocalizedString("Image trop grande : ",comment: "imageTooBigTitle")
                    let imageTooBigMessage = NSLocalizedString("Choisissez une photo de véhicule dont la taille est inférieure à 16 Mo et de préférence de format carré svp.", comment: "imageTooBigMessage")
					let textOk = NSLocalizedString("OK", comment: "textOk")
					
					SweetAlert().showAlert(imageTooBigTitle, subTitle: imageTooBigMessage, style: AlertStyle.error, buttonTitle:textOk, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0)) { (isOtherButton) -> Void in
					}
                    CWProgressHUD.dismiss()
                    valTest = false
                }else{
                    car.data = imageCar as NSData
                    valTest = true
					print("image condition OK")
                }
            }
            
            if (imagePhotoJustif.image !== nil){
				let cartegrise = imagePhotoJustif.image!.jpegData(compressionQuality: 0.7)
				car.cartegrise = cartegrise as NSData?
            }
            
            if ((Validate() == true)&&(valTest == true)) {
                /* Ajouter la voiture dans la base de données */
                try! realm.write {
                    realm.add(car)
                }
            	CWProgressHUD.dismiss()
                self.toastMessage("La voiture "+idCar+" a bien été créée")
            
                /* Rafraichir la liste des voitures avant affichage */
                //self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
                /* Notifier le rechargement de la liste après insertion dans bdd */
                NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: nil)
            }
        }
    }
    @IBAction func btnCancelCar(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true)
    }
    
    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.cars as Any)
        
        /* Vérification de la langue de l'iphone */
        let strLangue = Locale.current.languageCode
        
        if(strLangue == "fr"){
            self.langue = "fr"
            self.formatDate = "dd/MM/yyyy"
        }else{
            self.langue = "en"
            self.formatDate = "MM/dd/yy"
        }
        
        let settings = UserDefaults.standard
        
        if !settingsDataAlreadyExist(Key: "presenceCarteGrise"){
            settings.set(false, forKey: "presenceCarteGrise")
        }
        
        TextFieldTypeVehicule.delegate = self
        TextFieldTypeVehicule.tag = 0
        TextFieldTypeVehicule.returnKeyType = .next
        
        TextFieldCarMarque.delegate = self
        TextFieldCarMarque.tag = 1
        TextFieldCarMarque.returnKeyType = .next
        
        TextFieldCarModele.delegate = self
        TextFieldCarModele.tag = 2
        TextFieldCarModele.returnKeyType = .next
        
        TextFieldCarMotorisation.delegate = self
        TextFieldCarMotorisation.tag = 3
        TextFieldCarMotorisation.returnKeyType = .next
        
        TextFieldCarPseudo.delegate = self
        TextFieldCarPseudo.tag = 4
        TextFieldCarPseudo.returnKeyType = .next
        
        TextFieldCarEnergy.delegate = self
        TextFieldCarEnergy.tag = 5
        TextFieldCarEnergy.returnKeyType = .next
        
        TextFieldDateAchat.delegate = self
        TextFieldDateAchat.tag = 6
        TextFieldDateAchat.returnKeyType = .next
        
        TextFieldCarKilometrage.delegate = self
        TextFieldCarKilometrage.tag = 7
        TextFieldCarKilometrage.returnKeyType = .next
        
        TextFieldCarNumeroSerie.delegate = self
        TextFieldCarNumeroSerie.tag = 8
        TextFieldCarNumeroSerie.returnKeyType = .next
        
        TextFieldDateImmatriculation.delegate = self
        TextFieldDateImmatriculation.tag = 9
        TextFieldDateImmatriculation.returnKeyType = .next
        
        TextFieldCarImmatriculation.delegate = self
        TextFieldCarImmatriculation.tag = 10
        TextFieldCarImmatriculation.returnKeyType = .next
        
        TextFieldCarPressionPneus.delegate = self
        TextFieldCarPressionPneus.tag = 11
        TextFieldCarPressionPneus.returnKeyType = .next
        
        TextFieldCarReservoir.delegate = self
        TextFieldCarReservoir.tag = 12
        TextFieldCarReservoir.returnKeyType = .next
        
        TextFieldCarCommentaire.delegate = self
        TextFieldCarCommentaire.tag = 13
        TextFieldCarCommentaire.returnKeyType = .go
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("entering viewWillAppear -> selectedMarque = "+selectedMarque)
        if (!selectedMarque.isEmpty) {
            print("viewWillAppear : selectedMarque")
            //TextCarMarque.setTitle(selectedMarque, for:settings .normal)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
		if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
    }
    
    // Dismiss the keyboard when the user taps the "Return" key or its equivalent
    // while editing a text field.
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
        //textField.resignFirstResponder()
        //return true;
    }
    
    
    
    override func viewDidLayoutSubviews()
    {
        //print("entering viewDidLayoutSubviews")
        //scrollView.contentSize = contentView.bounds.size
        
        /*let scrollViewBounds = scrollView.bounds
        let containerViewBounds = contentView.bounds
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height;
        scrollViewInsets.top -= contentView.bounds.size.height;
        
        scrollViewInsets.bottom = scrollViewBounds.size.height
        scrollViewInsets.bottom -= contentView.bounds.size.height;
        scrollViewInsets.bottom += 1
        scrollView.contentInset = scrollViewInsets*/
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* Gestion du nombre de lignes dans les objets PickerView */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == PickerViewCarModele){
            return listOfMarques.count
        }
        if(pickerView == PickerViewType){ return listTypesFR.count}
        if(pickerView == PickerViewCarMarque){
            if(self.selectedType == "VOITURE"||self.selectedType == "CAR"){
                return listOfMarques.count
            }
            if(self.selectedType == "MOTO"||self.selectedType == "BIKE"){
                return 0
            }
            if(self.selectedType == "SCOOTER"){
                return 0
            }
        }
        if(pickerView == PickerViewCarEnergy){return listOfEnergiesFR.count}
        return 1
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == PickerViewCarMarque){
            if(self.selectedType == "VOITURE"||self.selectedType == "CAR"){
                self.selectedMarque = listOfMarques[row]
            }
            if(self.selectedType == "MOTO"||self.selectedType == "BIKE"){
                //selectedMarque = listOfScooters[row]
                self.selectedMarque = ""
            }
            if(self.selectedType == "SCOOTER"){
                //selectedMarque = listOfScooters[row]
                self.selectedMarque = ""
            }
            
            print("selectedMarque = "+self.selectedMarque)
            return self.selectedMarque
        }
        if(pickerView == PickerViewType){
            if(self.langue == "fr"){
                self.selectedType = listTypesFR[row]
            }else{
                self.selectedType = listTypesEN[row]
            }
            //print("self.selectedType = "+self.selectedType[row])
            return self.selectedType
        }
        if(pickerView == PickerViewCarEnergy){
            if(self.langue == "fr"){
                self.selectedEnergy = listOfEnergiesFR[row]
            }else{
                self.selectedEnergy = listOfEnergiesENG[row]
            }
            //print("self.selectedType = "+self.selectedType[row])
            return self.selectedEnergy
        }
        if(pickerView == PickerViewCarModele){
            selectedCar = ""
            return selectedCar
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(pickerView == PickerViewCarMarque){
            print("Marque = "+listOfMarques[row])
            let marque = ""
            if(self.selectedType == "VOITURE"||self.selectedType == "CAR"){
                TextFieldCarMarque?.text = listOfMarques[row]
                let marque = listOfMarques[row]
                imageMarque.image = UIImage(named: marque)
            }
            if(self.selectedType == "SCOOTER"){
                /*TextFieldCarMarque?.text = listOfScooters[row]
                let marque = listOfScooters[row]*/
                imageViewCar.image = UIImage(named: "icon_scooter")
            }
            if(self.selectedType == "MOTO"||self.selectedType == "BIKE"){
                /*TextFieldCarMarque?.text = listOfBikes[row]
                let marque = listOfBikes[row]*/
                imageViewCar.image = UIImage(named: "icon_moto")
            }
            if(self.selectedType == ""){
                let popupVehicleNotSelectedTitle = NSLocalizedString("Vehicule non sélectionné", comment: "popupVehicleNotSelectedTitle")
                let popupVehicleNotSelectedMessage = NSLocalizedString("Veuillez sélectionner le type de véhicule avant de choisir une marque", comment: "popupVehicleNotSelectedMessage")
                let popupVehicleNotSelectedOK = NSLocalizedString("OK", comment: "popupVehicleNotSelectedOK")
				
				SweetAlert().showAlert(popupVehicleNotSelectedTitle, subTitle: popupVehicleNotSelectedMessage, style: AlertStyle.error, buttonTitle:popupVehicleNotSelectedOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0)) { (isOtherButton) -> Void in
				}
            }
            print("pickerView didSelectRow -> selectedType",selectedType)
            if (UIImage(named: marque) != nil) {
                print("Image existing")
                imageViewCar.image = UIImage(named: marque)
            }
        }
        if(pickerView == PickerViewType){
            print("Type = "+listTypesFR[row])
            var type:String = ""
            
            /* Détection de la langue de l'iPhone */
            if(self.langue == "fr"){
                TextFieldTypeVehicule?.text = listTypesFR[row]
                type = listTypesFR[row]
            }else{
                TextFieldTypeVehicule?.text = listTypesEN[row]
                type = listTypesEN[row]
            }
            
            /* Image en fonction du type de véhicule */
            if (type == "MOTO"||type == "BIKE") {
                self.imageViewVehicleType.image = UIImage(named: "icon_moto")
            }
            if (type == "SCOOTER") {
                self.imageViewVehicleType.image = UIImage(named: "icon_scooter")
            }
            if ((type == "CAR")||(type == "VOITURE")) {
                self.imageViewVehicleType.image = UIImage(named: "3Dcar")
            }
        }
        if(pickerView == PickerViewCarEnergy){
            print("Energy = "+listOfEnergiesFR[row])
            
            /* Détection de la langue de l'iPhone */
            if(self.langue == "fr"){
                TextFieldCarEnergy?.text = listOfEnergiesFR[row]
            }else{
                TextFieldCarEnergy?.text = listOfEnergiesENG[row]
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.resignFirstResponder()
        
        print(textField)
        if textField == TextFieldTypeVehicule{
            self.pickUpType(TextFieldTypeVehicule)
        }
        if textField == TextFieldCarEnergy{
            self.pickUpCarEnergy(TextFieldCarEnergy)
        }
        if textField == TextFieldCarMarque{
			if(self.TextFieldTypeVehicule.text == ""){
				let titleSelectCarType = NSLocalizedString("Champ type non renseigné", comment: "titleSelectCarType")
				let messageSelectCarType = NSLocalizedString("Veuillez sélectionner un type de véhicule avant de continuer", comment: "titleSelectCarMessage")
				let buttonOK = NSLocalizedString("OK", comment: "buttonOK")
				
				let popup = SCLAlertView()
				popup.showError(titleSelectCarType, subTitle: messageSelectCarType)
			}else{
				if(self.selectedType == "CAR"||self.selectedType == "VOITURE"){
					self.pickUpMarque(TextFieldCarMarque)
				}else{
					textField.becomeFirstResponder()
				}
			}
        }
        if textField == TextFieldCarModele{
            //self.pickUpModele(TextFieldCarModele)
			if(self.TextFieldTypeVehicule.text == ""){
				let titleSelectCarType = NSLocalizedString("Champ type non renseigné", comment: "titleSelectCarType")
				let messageSelectCarType = NSLocalizedString("Veuillez sélectionner un type de véhicule avant de continuer", comment: "titleSelectCarMessage")
				let buttonOK = NSLocalizedString("OK", comment: "buttonOK")
				
				let popup = SCLAlertView()
				popup.showError(titleSelectCarType, subTitle: messageSelectCarType)
			}
        }
        if textField == TextFieldDateAchat{
            if TextFieldDateAchat.text!.isEmpty {
                let formatter = DateFormatter()
                if(self.langue == "fr"){
                    formatter.dateFormat = "dd/MM/yyyy"
                }else{
                    formatter.dateFormat = "MM/dd/yy"
                }
                
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                TextFieldDateAchat.text = formatter.string(from: Date())
            }
        }
        if textField == TextFieldDateImmatriculation{
            if TextFieldDateImmatriculation.text!.isEmpty {
                let formatter = DateFormatter()
                if(self.langue == "fr"){
                    formatter.dateFormat = "dd/MM/yyyy"
                }else{
                    formatter.dateFormat = "MM/dd/yy"
                }
            
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                TextFieldDateImmatriculation.text = formatter.string(from: Date())
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MyTableViewCell {
            
        }*/
        print("selected row",indexPath)
    }
    

    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
    
    func onUserBrandSelected(data: String){
        selectedMarque = data
        let tblMarques = MarquesTableViewController()
        tblMarques.dismiss(animated: true)
        print("onUserBrandSelected = "+selectedMarque)
        //TextCarMarque.setTitle(selectedMarque, for: .normal)
    }
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MarquesVC" {
            let popoverViewController = segue.destination as! MarquesTableViewController
            popoverViewController.delegate = self
        }
    }
    
    /* Fonction qui implémente le changement de date d'immatriculation */
    @objc func dateImmatPickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = formatDate
        TextFieldDateImmatriculation.text = dateFormatter.string(from: sender.date)
    }
    
    /* Liste déroulante pour choix du type */
    func pickUpType(_ textField : UITextField){
        
        let doneBtn = NSLocalizedString("Choisir", comment: "doneBtn")
        let cancelBtn = NSLocalizedString("Fermer", comment: "cancelBtn")
        // UIPickerView
        self.PickerViewType = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewType.delegate = self
        self.PickerViewType.dataSource = self
        self.PickerViewType.backgroundColor = UIColor.white
        TextFieldTypeVehicule.inputView = self.PickerViewType
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: doneBtn, style: .plain, target: self, action: #selector(AddCarViewController.doneTypeClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: cancelBtn, style: .plain, target: self, action: #selector(AddCarViewController.cancelTypeClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        TextFieldTypeVehicule.inputAccessoryView = toolBar
        
    }
    /* Liste déroulante pour choix du type */
    func pickUpCarEnergy(_ textField : UITextField){
        
        let doneBtn = NSLocalizedString("Choisir", comment: "doneBtn")
        let cancelBtn = NSLocalizedString("Fermer", comment: "cancelBtn")
        // UIPickerView
        self.PickerViewCarEnergy = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewCarEnergy.delegate = self
        self.PickerViewCarEnergy.dataSource = self
        self.PickerViewCarEnergy.backgroundColor = UIColor.white
        TextFieldCarEnergy.inputView = self.PickerViewCarEnergy
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: doneBtn, style: .plain, target: self, action: #selector(AddCarViewController.doneCarEnergyClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: cancelBtn, style: .plain, target: self, action: #selector(AddCarViewController.cancelCarEnergyClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        TextFieldCarEnergy.inputAccessoryView = toolBar
        
    }
    func pickUpMarque(_ textField : UITextField){
        let doneBtn = NSLocalizedString("Choisir", comment: "doneBtn")
        let cancelBtn = NSLocalizedString("Fermer", comment: "cancelBtn")
        let editBtn = NSLocalizedString("Saisie libre", comment: "editBtn")
        // UIPickerView
        self.PickerViewCarMarque = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewCarMarque.delegate = self
        self.PickerViewCarMarque.dataSource = self
        self.PickerViewCarMarque.backgroundColor = UIColor.white
        TextFieldCarMarque.inputView = self.PickerViewCarMarque
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: doneBtn, style: .plain, target: self, action: #selector(AddCarViewController.doneMarqueClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: cancelBtn, style: .plain, target: self, action: #selector(AddCarViewController.cancelMarqueClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        TextFieldCarMarque.inputAccessoryView = toolBar
        
    }
    
    func pickUpModele(_ textField : UITextField){
        
        // UIPickerView
        self.PickerViewCarModele = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewCarModele.delegate = self
        self.PickerViewCarModele.dataSource = self
        self.PickerViewCarModele.backgroundColor = UIColor.white
        TextFieldCarModele.inputView = self.PickerViewCarModele
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneBtn = UIBarButtonItem(title: "Valider", style: .plain, target: self, action: #selector(AddCarViewController.doneModeleClick))
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelBtn = UIBarButtonItem(title: "Fermer", style: .plain, target: self, action: #selector(AddCarViewController.cancelModeleClick))
        toolBar.setItems([cancelBtn, spaceBtn, doneBtn], animated: true)
        toolBar.isUserInteractionEnabled = true
        TextFieldCarMarque.inputAccessoryView = toolBar
        
    }
    
    @objc func doneMarqueClick() {
        TextFieldCarMarque.resignFirstResponder()
    }
    @objc func cancelMarqueClick() {
        TextFieldCarMarque.resignFirstResponder()
    }
    @objc func editModeMarqueClick() {
        self.marqueEditMode = true
        TextFieldCarMarque.resignFirstResponder()
    }
    
    
    @objc func doneModeleClick() {
        TextFieldCarModele.resignFirstResponder()
    }
    @objc func cancelModeleClick() {
        TextFieldCarModele.resignFirstResponder()
    }
    
    @objc func doneTypeClick() {
        TextFieldTypeVehicule.resignFirstResponder()
    }
    @objc func cancelTypeClick() {
        TextFieldTypeVehicule.resignFirstResponder()
    }
    
    @objc func doneCarEnergyClick() {
        TextFieldCarEnergy.resignFirstResponder()
    }
    @objc func cancelCarEnergyClick() {
        TextFieldCarEnergy.resignFirstResponder()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
		
		guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else {
			fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
		}
		imageViewCar.image = selectedImage
        imageViewCar.contentMode = .scaleAspectFill
        imageViewCar.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func populateSpinners() {
        let url = Bundle.main.url(forResource: "carModels", withExtension: "json")
        /*let jsonData = try? Data(contentsOf: url!)
        let jsonResponse = try? JSONSerialization.jsonObject(with: jsonData!)*/
        
        URLSession.shared.dataTask(with: url!) { (data, response
            , error) in
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let carData = try decoder.decode([carBrands].self, from: data)
                print(carData)
                self.cars = carData
                print(carData)
                return
            }catch let err {
                print("Err", err)
            }
        }.resume()
    }
    
    /* Fonction qui implémente le changement de date d'achat */
    @objc func dateAchatPickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        if(self.langue == "fr"){
            dateFormatter.locale = Locale(identifier: "FR_fr")
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }else{
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "MM/dd/yy"
        }
        TextFieldDateAchat.text = dateFormatter.string(from: sender.date)
    }
    
    /* Fonction qui crée l'id de la voiture */
    @objc func createCarId() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "ddMMYYYYHHmmss"
        idCar = "Car-" + dateFormatter.string(from: Date())
    }
    
    /* Fonction qui valide les informations avant d'enregistrer */
    
    func Validate() -> Bool{
        var valid:Bool = true
        let warnTypeVeh = NSLocalizedString("Veuillez sélectionner un type", comment: "warnTypeVeh")
        let warnMarqueVeh = NSLocalizedString("Veuillez sélectionner une marque", comment: "warnMarqueVeh")
        let warnModeleVeh = NSLocalizedString("Veuillez saisir le modèle de voiture", comment: "warnModeleVeh")
        let warnKMVeh = NSLocalizedString("Veuillez saisir le kilometrage vehicule", comment: "warnKMVeh")
        let warnDateAchat = NSLocalizedString("Date d'achat", comment: "warnDateAchat")
        let warnDateImmatriculation = NSLocalizedString("Date Immatriculation", comment: "warnDateImmatriculation")
        let warnVolReservoir = NSLocalizedString("Veuillez saisir le volume de votre reservoir", comment: "warnVolReservoir")
        let warnImmatriculation = NSLocalizedString("Saisir l'immatriculation", comment: "warnImmatriculation")
        let warnCarEnergy = NSLocalizedString("Energie", comment: "warnCarEnergy")
        
        if TextFieldTypeVehicule.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldCarPseudo if
			TextFieldTypeVehicule.attributedPlaceholder = NSAttributedString(string: warnTypeVeh, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            print("TextFieldTypeVehicule",false)
            self.AnimationShakeTextField(textField: TextFieldTypeVehicule)
            valid = false
        }else{
            //TextFieldTypeVehicule.backgroundColor
            valid = true
            print("TextFieldTypeVehicule",true)
        }
        if TextFieldCarEnergy.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldCarPseudo if
			TextFieldCarEnergy.attributedPlaceholder = NSAttributedString(string: warnCarEnergy, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            print("TextFieldCarEnergy",false)
            self.AnimationShakeTextField(textField: TextFieldCarEnergy)
            valid = false
        }else{
            //TextFieldTypeVehicule.backgroundColor
            valid = true
            print("TextFieldCarEnergy",true)
        }
        if TextFieldCarMarque.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldCarPseudo if
			TextFieldCarMarque.attributedPlaceholder = NSAttributedString(string: warnMarqueVeh, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            print("TextFieldCarMarque",false)
            self.AnimationShakeTextField(textField: TextFieldCarMarque)
            valid = false
        }else{
            valid = true
            print("TextFieldCarMarque",true)
        }
        if TextFieldCarModele.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldStationService if
			TextFieldCarModele.attributedPlaceholder = NSAttributedString(string: warnModeleVeh, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldCarModele)
            print("TextFieldCarModele",false)
        }else{
            valid = true
            print("TextFieldCarModele",true)
        }
        if TextFieldCarKilometrage.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldKilometrage if
			TextFieldCarKilometrage.attributedPlaceholder = NSAttributedString(string: warnKMVeh, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldCarKilometrage)
            print("TextFieldCarKilometrage",false)
        }else{
            valid = true
            print("TextFieldCarKilometrage",true)
        }
        if TextFieldDateAchat.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
			TextFieldDateAchat.attributedPlaceholder = NSAttributedString(string: warnDateAchat, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldDateAchat)
            print("TextFieldDateAchat",false)
        }else{
            valid = true
            print("TextFieldDateAchat",true)
        }
        if TextFieldCarReservoir.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
			TextFieldCarReservoir.attributedPlaceholder = NSAttributedString(string: warnVolReservoir, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldCarReservoir)
            print("TextFieldCarReservoir",false)
        }else{
            valid = true
            print("TextFieldCarReservoir",true)
        }
        if TextFieldDateImmatriculation.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
			TextFieldDateImmatriculation.attributedPlaceholder = NSAttributedString(string: warnDateImmatriculation, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldDateImmatriculation)
            print("TextFieldDateImmatriculation",false)
        }else{
            
            valid = true
            print("TextFieldDateImmatriculation",true)
        }
        return valid
    }
    
    func AnimationShakeTextField(textField:UITextField){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 5, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 5, y: textField.center.y))
        textField.layer.add(animation, forKey: "position")
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
