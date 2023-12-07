//
//  EditCarViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 24/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation

class EditCarViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    //var carItem: Car!
    let realm = try! Realm()
    var data:Results<Car>!
    var car:Car?
    var carImmat:String?
    var langue = ""
    var formatDate = "dd/MM/yyyy"

    @IBOutlet weak var imageViewVehicule: UIImageView!
    @IBOutlet weak var editFieldCarMarque: UITextField!
    @IBOutlet weak var editFieldCarModele: UITextField!
    @IBOutlet weak var editFieldCarPseudo: UITextField!
    @IBOutlet weak var editFieldDateAchat: UITextField!
    @IBOutlet weak var editFieldKilometrage: UITextField!
    @IBOutlet weak var editFieldSerialNumber: UITextField!
    @IBOutlet weak var editFieldNotes: UITextField!
    @IBOutlet weak var editFieldEnergie: UITextField!
    @IBOutlet weak var editFieldCarImmatriculation: UITextField!
    @IBOutlet weak var editFieldDateImmatriculation: UITextField!
    @IBOutlet weak var imageMarque: UIImageView!
    @IBOutlet weak var imageCarteGrise: UIImageView!
    
    /* Listes déroulantes dynamiques */
    var PickerViewCarMarque: UIPickerView!
    var PickerViewCarModele : UIPickerView!
    var PickerViewCarDetail : UIPickerView!
    var PickerViewCarEnergy : UIPickerView!
    
    /* Variables de sélection */
    var selectedCar = ""
    var selectedColour = ""
    var selectedMarque = ""
    var selectedType = ""
    var selectedEnergy = ""
    
    /* Listes déroulantes statiques */
    let listOfMarques:[String] = ["ALFA ROMEO", "AUDI", "BMW", "CADILLAC", "CHEVROLET", "CHRYSLER", "CITROEN", "DACIA", "DAEWOO", "DAIHATSU", "DODGE", "DS", "FIAT", "FORD", "HONDA", "HUMMER", "HYUNDAI", "INFINITI", "ISUZU", "IVECO", "JAGUAR", "KIA", "LADA", "LANCIA", "LAND ROVER", "LEXUS", "MAZDA", "MERCEDES-BENZ", "MG", "MINI", "MITSUBISHI", "NISSAN", "OPEL", "PEUGEOT", "PORSCHE", "RENAULT", "ROVER", "SAAB", "SEAT", "SIMCA", "SKODA", "SMART", "SUZUKI", "SSANGYONG", "SUBARU", "TALBOT", "TESLA", "TOYOTA", "VOLKSWAGEN", "VOLVO"]
    let listTypesFR:[String] = ["MOTO", "SCOOTER", "VOITURE"]
    let listTypesEN:[String] = ["BIKE", "SCOOTER", "CAR"]
    let listOfPseudos:[String] = ["Navy", "Miranda", "Appen", "Luna", "Carl", "Joe", "Kenny", "Ken", "Filou", "Jumbo", "Bingo", "Violetta", "Grisouille", "Bianca", "Polo", "Zoe", "Enzo", "Titine", "Choupinette", "Lisa", "Natacha", "Bolide", "Béhème", "Charette", "Chariot", "Tractor", "Velociraptor", "Raptor", "Speedy", "Brouette", "Trottinette", "Pinky", "Boudin", "Zapette", "Choupette", "Choupinou", "Blue", "Ramses", "Cleopatra", "Princesse", "Inconnu", "Michka", "Masha"]
    let listOfEnergiesFR:[String] = ["Essence", "Diesel", "Hybride", "Electrique", "Manuel", "Autre"]
    let listOfEnergiesENG:[String] = ["Gasoline", "Diesel", "Hybrid", "Electric", "Manual", "Other"]
    
    
    @IBAction func btnModifyCarInfos(_ sender: UIBarButtonItem) {
        print("EditCarViewController:realmInit")
        
        let carItem = self.car
        
        let dateFormatter = DateFormatter()
        let dateFormat = "dd/MM/yyyy"
        dateFormatter.dateFormat = dateFormat
        let dateAchat = dateFormatter.date(from: (editFieldDateAchat?.text!)!)
        
        let dateFormatterImmat = DateFormatter()
        let dateFormatImmat = "dd/MM/yyyy"
        dateFormatterImmat.dateFormat = dateFormatImmat
        let dateImmat = dateFormatterImmat.date(from: (editFieldDateImmatriculation?.text!)!)
        
        try! realm.write {
            
			let imageVehicule = imageViewVehicule.image!.pngData() as NSData?
            //let cartegrise = NSData(data: UIImageJPEGRepresentation(imageCarteGrise.image!,0.9)!)
            
            carItem!.dateAchat = dateAchat!
            carItem!.kilometrage = Int((editFieldKilometrage?.text)!)!
            carItem!.marque = (editFieldCarMarque?.text)!
            carItem!.modele = (editFieldCarModele?.text)!
            carItem!.pseudo = (editFieldCarPseudo?.text)!
            carItem!.energy = (editFieldEnergie?.text)!
            carItem!.numeroSerie = (editFieldSerialNumber?.text)!
            carItem!.commentaire = (editFieldNotes?.text)!
            carItem!.data = imageVehicule
            carItem!.immatriculation = (editFieldCarImmatriculation?.text)!
            carItem!.dateImmat = dateImmat!
            //carItem!.cartegrise = cartegrise
            
            /* Ajouter la voiture dans la base de données */
			realm.add(car!, update: .modified)
        }
        
        self.toastMessage("La voiture "+(carItem!.modele)+" a bien été modifiée")
        
        /* Rafraichir la liste des voitures avant affichage */
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnCloseCar(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChangerImage(_ sender: Any) {
            
        PhotoChooser.shared.showAttachmentActionSheet(vc: self)
        PhotoChooser.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.imageViewVehicule.image = image
        }
    }
    
    @IBAction func editFieldDateAchat(_ sender: UITextField) {
        let dateAchatPickerView:UIDatePicker = UIDatePicker()
		dateAchatPickerView.datePickerMode = UIDatePicker.Mode.date
        
        if(self.langue == "fr"){
            dateAchatPickerView.locale = Locale(identifier: "fr_FR")
        }else{
            dateAchatPickerView.locale = Locale(identifier: "en_US")
        }
        
        sender.inputView = dateAchatPickerView
		dateAchatPickerView.addTarget(self, action: #selector(EditCarViewController.dateAchatPickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @IBAction func editFieldDateImmat(_ sender: UITextField) {
        let dateImmatPickerView:UIDatePicker = UIDatePicker()
		dateImmatPickerView.datePickerMode = UIDatePicker.Mode.date
        
        if(self.langue == "fr"){
            dateImmatPickerView.locale = Locale(identifier: "fr_FR")
        }else{
            dateImmatPickerView.locale = Locale(identifier: "en_US")
        }
        
        sender.inputView = dateImmatPickerView
		dateImmatPickerView.addTarget(self, action: #selector(EditCarViewController.dateImmatPickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @IBAction func buttonCarteGrise(_ sender: UIButton) {
        PhotoChooser.shared.showAttachmentActionSheet(vc: self)
        PhotoChooser.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.imageCarteGrise.image = image
            self.saveImageToAppFolder(image: image)
            
        }
    }
    
    func saveImageToAppFolder(image: UIImage){
        
        let filename = self.car?.idCar
        let fileStr = "AutoConso/" + filename! + ".jpeg"
        
        print("saveImageToAppFolder", fileStr)
		if let data = image.jpegData(compressionQuality: 1.0),
            !FileManager.default.fileExists(atPath: fileStr) {
            
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = dir!.appendingPathComponent(fileStr)
            
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
                showToast(message: "la carte grise a bien été enregistrée dans votre iPhone")
            } catch {
                print("error saving file:", error)
                showToast(message: "Erreur à l'enregistrement de la photo")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Vérification de la langue de l'iphone */
        let strLangue = Locale.current.languageCode
        
        if(strLangue == "fr"){
            self.langue = "fr"
            self.formatDate = "dd/MM/yyyy"
        }else{
            self.langue = "en"
            self.formatDate = "MM/dd/yy"
        }
    
        let realm = try! Realm()
        self.data = realm.objects(Car.self)
        let carItem = self.car
        
        print("EditCarViewController -> reception",carItem!.pseudo)
        
        let carImage = UIImage(data: carItem!.data! as Data)
        //let carteGrise = UIImage(data: carItem!.cartegrise! as Data)
        
        imageViewVehicule.image = carImage
        //imageCarteGrise.image = carteGrise
        editFieldCarMarque.text? = carItem!.marque
        editFieldCarModele.text? = carItem!.modele
        editFieldCarPseudo.text? = carItem!.pseudo
        editFieldEnergie.text? = carItem!.energy
        editFieldCarImmatriculation.text? = carItem!.immatriculation
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        editFieldDateAchat.text? = formatter.string(from: carItem!.dateAchat)
        editFieldDateImmatriculation.text? = formatter.string(from: carItem!.dateImmat)
        editFieldKilometrage.text? = carItem!.kilometrage.description
        editFieldSerialNumber.text? = carItem!.numeroSerie
        
        editFieldCarMarque.delegate = self
        editFieldCarMarque.tag = 0
        editFieldCarMarque.returnKeyType = .next
        
        editFieldCarModele.delegate = self
        editFieldCarModele.tag = 1
        editFieldCarModele.returnKeyType = .next
        
        editFieldCarPseudo.delegate = self
        editFieldCarPseudo.tag = 2
        editFieldCarPseudo.returnKeyType = .next
        
        editFieldEnergie.delegate = self
        editFieldEnergie.tag = 3
        editFieldEnergie.returnKeyType = .next
        
        editFieldDateAchat.delegate = self
        editFieldDateAchat.tag = 4
        editFieldDateAchat.returnKeyType = .next
        
        editFieldKilometrage.delegate = self
        editFieldKilometrage.tag = 5
        editFieldKilometrage.returnKeyType = .next
        
        editFieldSerialNumber.delegate = self
        editFieldSerialNumber.tag = 6
        editFieldSerialNumber.returnKeyType = .next
        
        editFieldDateImmatriculation.delegate = self
        editFieldDateImmatriculation.tag = 7
        editFieldDateImmatriculation.returnKeyType = .next
        
        editFieldCarImmatriculation.delegate = self
        editFieldCarImmatriculation.tag = 8
        editFieldCarImmatriculation.returnKeyType = .go
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /* On cache le clavier */
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
    
    
    /**
     * Gestion des listes dynamiques
     */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* Gestion du nombre de lignes dans les objets PickerView */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == PickerViewCarMarque){
            return listOfMarques.count
        }
        if(pickerView == PickerViewCarMarque){
            if(self.selectedType == "VOITURE"||self.selectedType == "CAR"){
                return listOfMarques.count
            }
        }
        if(pickerView == PickerViewCarEnergy){return listOfEnergiesFR.count}
        return 1
    }

    /* Gestion de l'affichage des listes */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == PickerViewCarMarque){
            self.selectedMarque = listOfMarques[row]
            print("selectedMarque = "+self.selectedMarque)
            return self.selectedMarque
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
            editFieldCarMarque?.text = listOfMarques[row]
            let marque = listOfMarques[row]
            imageMarque.image = UIImage(named: marque)
        }
        if(pickerView == PickerViewCarEnergy){
            print("Energy = "+listOfEnergiesFR[row])
            
            /* Détection de la langue de l'iPhone */
            if(self.langue == "fr"){
                editFieldEnergie?.text = listOfEnergiesFR[row]
            }else{
                editFieldEnergie?.text = listOfEnergiesENG[row]
            }
        }
    }
    
    /**
     * Construction des listes dynamiques
     **/
    
    /* Liste déroulante pour choix du type */
    func pickUpCarEnergy(_ textField : UITextField){
        
        let doneBtn = NSLocalizedString("Choisir", comment: "doneBtn")
        let cancelBtn = NSLocalizedString("Fermer", comment: "cancelBtn")
        // UIPickerView
        self.PickerViewCarEnergy = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewCarEnergy.delegate = self
        self.PickerViewCarEnergy.dataSource = self
        self.PickerViewCarEnergy.backgroundColor = UIColor.white
        editFieldEnergie.inputView = self.PickerViewCarEnergy
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: doneBtn, style: .plain, target: self, action: #selector(EditCarViewController.doneCarEnergyClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: cancelBtn, style: .plain, target: self, action: #selector(EditCarViewController.cancelCarEnergyClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        editFieldEnergie.inputAccessoryView = toolBar
        
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
        editFieldCarMarque.inputView = self.PickerViewCarMarque
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: doneBtn, style: .plain, target: self, action: #selector(EditCarViewController.doneMarqueClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: cancelBtn, style: .plain, target: self, action: #selector(EditCarViewController.cancelMarqueClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        editFieldCarMarque.inputAccessoryView = toolBar
        
    }
    
    
    /* Affichage de la liste déroulante au clic sur le champ */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.resignFirstResponder()
        
        print(textField)
        if textField == editFieldEnergie{
            self.pickUpCarEnergy(editFieldEnergie)
        }
        if textField == editFieldCarMarque{
            self.pickUpMarque(editFieldCarMarque)
        }
        if textField == editFieldDateAchat{
            if editFieldDateAchat.text!.isEmpty {
                let formatter = DateFormatter()
                if(self.langue == "fr"){
                    formatter.dateFormat = "dd/MM/yyyy"
                }else{
                    formatter.dateFormat = "MM/dd/yy"
                }
                
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                editFieldDateAchat.text = formatter.string(from: Date())
            }
        }
        if textField == editFieldDateImmatriculation{
            if editFieldDateImmatriculation.text!.isEmpty {
                let formatter = DateFormatter()
                if(self.langue == "fr"){
                    formatter.dateFormat = "dd/MM/yyyy"
                }else{
                    formatter.dateFormat = "MM/dd/yy"
                }
                
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                editFieldDateImmatriculation.text = formatter.string(from: Date())
            }
        }
    }
    
    @objc func doneMarqueClick() {
        editFieldCarMarque.resignFirstResponder()
    }
    @objc func cancelMarqueClick() {
        editFieldCarMarque.resignFirstResponder()
    }
    
    @objc func doneCarEnergyClick() {
        editFieldEnergie.resignFirstResponder()
    }
    @objc func cancelCarEnergyClick() {
        editFieldEnergie.resignFirstResponder()
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
        editFieldDateAchat.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func dateImmatPickerValueChanged(sender:UIDatePicker) {
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
        editFieldDateImmatriculation.text = dateFormatter.string(from: sender.date)
    }
}
