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
    var PickerViewType : UIPickerView!
    var PickerViewCarMarque : UIPickerView!
    var PickerViewCarModele : UIPickerView!
    var PickerViewCarDetail : UIPickerView!
    var cars: [carBrands]?
    var idCar = ""
    var langue = ""
    var marqueEditMode = false
    var formatDate = "dd/MM/yyyy"
    var valTest = false
    @IBOutlet weak var imageViewCar: UIImageView!
    
    /* Liste de marques de voitures et de couleurs */
    let listOfMarques:[String] = ["ALFA ROMEO", "AUDI", "BMW", "CADILLAC", "CHEVROLET", "CHRYSLER", "CITROEN", "DACIA", "DAEWOO", "DAIHATSU", "DODGE", "DS", "FIAT", "FORD", "HONDA", "HUMMER", "HYUNDAI", "INFINITI", "ISUZU", "IVECO", "JAGUAR", "KIA", "LADA", "LANCIA", "LAND ROVER", "LEXUS", "MAZDA", "MERCEDES-BENZ", "MG", "MINI", "MITSUBISHI", "NISSAN", "OPEL", "PEUGEOT", "PORSCHE", "RENAULT", "ROVER", "SAAB", "SEAT", "SIMCA", "SKODA", "SMART", "SUZUKI", "SSANGYONG", "SUBARU", "TALBOT", "TESLA", "TOYOTA", "VOLKSWAGEN", "VOLVO"]
    
    let listTypesFR:[String] = ["MOTO", "SCOOTER", "VOITURE"]
    let listTypesEN:[String] = ["BIKE", "SCOOTER", "CAR"]
    
    let listOfColors:[String] = ["Bleu", "Rouge", "Vert", "Noir", "Gris", "Violet", "Blanc", "Jaune", "Orange", "Bordeaux", "Beige"]
    
    let listOfPseudos:[String] = ["Navy", "Miranda", "Appen", "Luna", "Carl", "Joe", "Kenny", "Ken", "Filou", "Jumbo", "Bingo", "Violetta", "Grisouille", "Bianca", "Polo", "Zoe", "Enzo", "Titine", "Choupinette", "Lisa", "Natacha", "Bolide", "Béhème", "Charette", "Chariot", "Tractor", "Velociraptor", "Raptor", "Speedy", "Brouette", "Trottinette", "Pinky", "Boudin", "Zapette", "Choupette", "Choupinou", "Blue", "Ramses", "Cleopatra", "Princesse", "Inconnu", "Michka", "Masha"]
    
    let listOfScooters:[String] = ["Adly", "Aeon", "Aprilia", "Bajaj", "Baotian", "Benelli", "Beta", "Tata Sco", "BMW", "Daelim", "Dafra", "Derbi", "Garelli", "Genuine", "Gilera", "Gogoro", "Hero", "Honda", "Hyosung", "Junak", "Kawasaki", "Kymco", "Lifan", "Lohia Machinery Limited (LML)", "MBK (formerly Motobécane)", "Modenas", "Peugeot", "PGO Scooters", "API", "Piaggio", "Rieju", "Qingqi", "SFM (formerly Sachs)", "Solifer", "Suzuki", "Taiwan Golden Bee(TGB)", "Tomos", "TVS", "Unu", "Vespa", "Xingyue", "Yamaha", "Zongshen", "Znen"]
    
    let listOfBikes:[String] = ["Adly", "Aeon", "Aprilia", "Bajaj", "Baotian", "Benelli", "Beta", "Tata Sco", "BMW", "Daelim", "Dafra", "Derbi", "Garelli", "Genuine", "Gilera", "Gogoro", "Hero", "Honda", "Hyosung", "Junak", "Kawasaki", "Kymco", "Lifan", "Lohia Machinery Limited (LML)", "MBK (formerly Motobécane)", "Modenas", "Peugeot", "PGO Scooters", "API", "Piaggio", "Rieju", "Qingqi", "SFM (formerly Sachs)", "Solifer", "Suzuki", "Taiwan Golden Bee(TGB)", "Tomos", "TVS", "Unu", "Vespa", "Xingyue", "Yamaha", "Zongshen", "Znen"]
    
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
    @IBOutlet weak var imagePhotoJustif: UIImageView!
    @IBOutlet weak var imageMarque: UIImageView!
    @IBOutlet weak var imageViewVehicleType: UIImageView!
    
    @IBAction func TextFieldTypeVehicule(_ sender: UITextField) {
        
    }
    /* Affichage d'un datePicker au click sur la cellule de date */
    @IBAction func TextFieldDateAchat(_ sender: UITextField) {
        
        let dateAchatPickerView:UIDatePicker = UIDatePicker()
        dateAchatPickerView.datePickerMode = UIDatePickerMode.date
        
        if(self.langue == "fr"){
            dateAchatPickerView.locale = Locale(identifier: "fr_FR")
        }else{
            dateAchatPickerView.locale = Locale(identifier: "en_US")
        }
        
        sender.inputView = dateAchatPickerView
        dateAchatPickerView.addTarget(self, action: #selector(AddCarViewController.dateAchatPickerValueChanged), for: UIControlEvents.valueChanged)
        
    }
    
    /* Affichage d'un datePicker au click sur la cellule de date */
    @IBAction func TextFieldDateImmat(_ sender: UITextField) {
        
        let dateImmatPickerView:UIDatePicker = UIDatePicker()
        dateImmatPickerView.datePickerMode = UIDatePickerMode.date
        
        if(self.langue == "fr"){
            dateImmatPickerView.locale = Locale(identifier: "fr_FR")
        }else{
            dateImmatPickerView.locale = Locale(identifier: "en_US")
        }
        
        sender.inputView = dateImmatPickerView
        dateImmatPickerView.addTarget(self, action: #selector(AddCarViewController.dateImmatPickerValueChanged), for: UIControlEvents.valueChanged)
        
    }

    @IBAction func btnSuggererPseudo(_ sender: UIButton) {
        let randNumber = Int(arc4random_uniform(UInt32(listOfPseudos.count)))
        TextFieldCarPseudo.text = listOfPseudos[randNumber]
    }
    @IBAction func btnAssocierJutifs(_ sender: Any) {
        
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
        
        let car:Car = Car()
        
        if (Validate() == true) {
            
            createCarId()
        
            car.idCar = idCar
            
            if let textType = self.TextFieldTypeVehicule.text{
                car.type = textType
            }
            
            if let textCarMarque = self.TextFieldCarMarque.text{
                car.marque = textCarMarque
            }
            
            if let textCarModele = self.TextFieldCarModele.text{
                car.modele = textCarModele
            }
        
            let textCarImmatriculation = self.TextFieldCarImmatriculation.text
            if (textCarImmatriculation?.count != 10)
            {
                let todaysDate = NSDate()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = formatDate
                let DateInFormat = dateFormatter.string(from: todaysDate as Date)
                print(DateInFormat)
                car.immatriculation = DateInFormat
            }
            if let textCarPseudo = self.TextFieldCarPseudo.text{
                if textCarPseudo.isEmpty {car.pseudo = self.TextFieldCarModele.text!}
                else{car.pseudo = textCarPseudo}
            }
            
            if let textKm = self.TextFieldCarKilometrage.text{
                let usr = UserDefaults.standard
                usr.set(textKm,forKey: "carKM")
                car.kilometrage = Int(textKm)!
            }
            
            if let textReservoir = self.TextFieldCarKilometrage.text{
                car.reservoir = Int(textReservoir)!
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
            
            if let imageCar = UIImagePNGRepresentation(imageViewCar.image!) {
                let bytes = imageCar.count
                let MB = Double(bytes)/1000000.0
                /*let kB = Double(bytes) / 1000.0 // Note the difference
                let KB = Double(bytes) / 1024.0 // Note the difference*/
                print("Taille image : "+MB.description)
                if(MB > 16.0){
                    print("condition OK")
                    
                    let imageTooBigToastMessage = NSLocalizedString("Image trop grande : "+MB.description+" Mo. Choisissez une image dont la taille est inférieure à 16 Mo et de préférence de format carré svp.", comment: "imageTooBigToastMessage")
                    
                    let imageCarAlert = UIAlertController(title: "Image trop grande : "+String(format: "%.3f", MB)+" Mo.", message: "Choisissez une image dont la taille est inférieure à 16 Mo et de préférence de format carré svp.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    imageCarAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        print("L'utilisateur a décidé de supprimer un véhicule")
                        
                    }))
                    
                    self.present(imageCarAlert, animated: true, completion: nil)
                    
                    valTest = false
                }else{
                    valTest = true
                }
            }
            
            let imageCarData = UIImagePNGRepresentation(imageViewCar.image!) as NSData?
            car.data = imageCarData
            
            if ((Validate() == true)&&(valTest == true)) {
                /* Ajouter la voiture dans la base de données */
                try! realm.write {
                    realm.add(car)
                }
            
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
        
        TextFieldDateAchat.delegate = self
        TextFieldDateAchat.tag = 5
        TextFieldDateAchat.returnKeyType = .next
        
        TextFieldCarKilometrage.delegate = self
        TextFieldCarKilometrage.tag = 6
        TextFieldCarKilometrage.returnKeyType = .next
        
        TextFieldCarNumeroSerie.delegate = self
        TextFieldCarNumeroSerie.tag = 7
        TextFieldCarNumeroSerie.returnKeyType = .next
        
        TextFieldDateImmatriculation.delegate = self
        TextFieldDateImmatriculation.tag = 8
        TextFieldDateImmatriculation.returnKeyType = .next
        
        TextFieldCarImmatriculation.delegate = self
        TextFieldCarImmatriculation.tag = 9
        TextFieldCarImmatriculation.returnKeyType = .next
        
        TextFieldCarPressionPneus.delegate = self
        TextFieldCarPressionPneus.tag = 10
        TextFieldCarPressionPneus.returnKeyType = .next
        
        TextFieldCarReservoir.delegate = self
        TextFieldCarReservoir.tag = 11
        TextFieldCarReservoir.returnKeyType = .next
        
        TextFieldCarCommentaire.delegate = self
        TextFieldCarCommentaire.tag = 12
        TextFieldCarCommentaire.returnKeyType = .go
        
        TextFieldDateImmatriculation.delegate = self
        TextFieldDateAchat.delegate = self
        
        //TextFieldDateImmatriculation.inputView = dateImmatPickerView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("entering viewWillAppear -> selectedMarque = "+selectedMarque)
        if (!selectedMarque.isEmpty) {
            print("viewWillAppear : selectedMarque")
            //TextCarMarque.setTitle(selectedMarque, for: .normal)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
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
                
                let popupVehicleNotSelected = UIAlertController(title: popupVehicleNotSelectedTitle, message: popupVehicleNotSelectedMessage, preferredStyle: UIAlertControllerStyle.alert)
                
                popupVehicleNotSelected.addAction(UIAlertAction(title: popupVehicleNotSelectedOK, style: .default, handler:
                    { (action: UIAlertAction!) in
                }))
                
                self.present(popupVehicleNotSelected, animated: true, completion: nil)
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
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.resignFirstResponder()
        
        print(textField)
        if textField == TextFieldTypeVehicule{
            self.pickUpType(TextFieldTypeVehicule)
        }
        if textField == TextFieldCarMarque{
            if(self.selectedType == "CAR"||self.selectedType == "VOITURE"){
                self.pickUpMarque(TextFieldCarMarque)
            }else{
                textField.becomeFirstResponder()
            }
        }
        if textField == TextFieldCarModele{
            //self.pickUpModele(TextFieldCarModele)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        imageViewCar.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
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
        
        if TextFieldTypeVehicule.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldCarPseudo if
            TextFieldTypeVehicule.attributedPlaceholder = NSAttributedString(string: warnTypeVeh, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            print("TextFieldTypeVehicule",false)
            self.AnimationShakeTextField(textField: TextFieldTypeVehicule)
            valid = false
        }else{
            //TextFieldTypeVehicule.backgroundColor
            valid = true
            print("TextFieldTypeVehicule",true)
        }
        if TextFieldCarMarque.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldCarPseudo if
            TextFieldCarMarque.attributedPlaceholder = NSAttributedString(string: warnMarqueVeh, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            print("TextFieldCarMarque",false)
            self.AnimationShakeTextField(textField: TextFieldCarMarque)
            valid = false
        }else{
            valid = true
            print("TextFieldCarMarque",true)
        }
        if TextFieldCarModele.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldStationService if
            TextFieldCarModele.attributedPlaceholder = NSAttributedString(string: warnModeleVeh, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldCarModele)
            print("TextFieldCarModele",false)
        }else{
            valid = true
            print("TextFieldCarModele",true)
        }
        if TextFieldCarKilometrage.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldKilometrage if
            TextFieldCarKilometrage.attributedPlaceholder = NSAttributedString(string: warnKMVeh, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldCarKilometrage)
            print("TextFieldCarKilometrage",false)
        }else{
            valid = true
            print("TextFieldCarKilometrage",true)
        }
        if TextFieldDateAchat.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
            TextFieldDateAchat.attributedPlaceholder = NSAttributedString(string: warnDateAchat, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldDateAchat)
            print("TextFieldDateAchat",false)
        }else{
            valid = true
            print("TextFieldDateAchat",true)
        }
        if TextFieldCarReservoir.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
            TextFieldCarReservoir.attributedPlaceholder = NSAttributedString(string: warnVolReservoir, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldCarReservoir)
            print("TextFieldCarReservoir",false)
        }else{
            valid = true
            print("TextFieldCarReservoir",true)
        }
        if TextFieldDateImmatriculation.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
            TextFieldDateImmatriculation.attributedPlaceholder = NSAttributedString(string: warnDateImmatriculation, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
            self.AnimationShakeTextField(textField: TextFieldDateImmatriculation)
            print("TextFieldDateImmatriculation",false)
        }else{
            
            valid = true
            print("TextFieldDateImmatriculation",true)
        }
        /*if TextFieldCarImmatriculation.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
            TextFieldCarImmatriculation.attributedPlaceholder = NSAttributedString(string: warnImmatriculation, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            //valid = false
            self.AnimationShakeTextField(textField: TextFieldCarImmatriculation)
            print("TextFieldCarImmatriculation",false)
        }else{
            
            valid = true
            print("TextFieldCarImmatriculation",true)
        }*/ //Immatriculation non obligatoire (info perso)
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
}
