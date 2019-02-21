//
//  AddConsoViewController.swift
//  AutoConso-v0
//
//  Created by Edgar PETRUS on 16/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation
import FirebaseUI
import FirebaseFirestore

class AddConsoViewController: UITableViewController , UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //var docRef : DocumentReference!
    var realm:Realm?
    var data:Results<Car>!
    var listOfCars:[Car] = []
    var listConso:[Conso] = []
    var listStations:[Station] = []
    var selectedStationService = ""
    var selectedCar = ""
    var selectedCarburant = ""
    var consoDate = Date()
    var selectedDate = ""
    var langue = ""
    var appDirPath = ""
    var idConso = ""
    var idStation = ""
    var car:Car?
    var searchString = ""
    var source = ""
    var station:Station?
    var oConso:Conso?
    var stationsSearchVC:StationsSearchTableViewController?
    let listOfStationServices:[String] = ["AGIP", "ANTAR", "AUCHAN", "AVIA", "BP", "CARREFOUR", "DYNEFF", "E.LECLERC", "ELF", "ESSO EXPRESS", "ESSO", "EXXON", "FINA", "IRVING", "SHELL", "TOTAL ACCESS", "TOTAL", "U"]
    let listOfTypesCarburants:[String] = ["ESSENCE", "DIESEL", "SUPER", "SANS PLOMB 95", "SANS PLOMB 95 E10", "SANS PLOMB 98", "BP ULTIMATE", "ETC..."]
    
    let listOfTypesCarburantsEN:[String] = ["GAZOLINE", "DIESEL", "ELECTRIC", "ETHANOL", "OTHER"]
    
    /* Section Voiture */
    @IBOutlet weak var imageViewCar: UIImageView!
    @IBOutlet weak var imageViewCarMarque: UIImageView!
    @IBOutlet weak var TextFieldCarPseudo: UITextField!
    @IBOutlet weak var TextFieldCarMarque: UITextField!
    @IBOutlet weak var TextFieldCarModele: UITextField!
    @IBOutlet weak var imageJustificatif: UIImageView!
    
    
    /* Section station service */
    @IBOutlet weak var imageViewStationService: UIImageView!
    @IBOutlet weak var TextFieldDateRavitaillement: UITextField!
    @IBAction func editFieldDateRavitaillement(_ sender: UITextField) {
        
    }
    @IBOutlet weak var TextFieldStationService: UITextField!
    @IBOutlet weak var TextFieldStationServiceAdresse: UITextField!
    @IBOutlet weak var TextFieldCodePostal: UITextField!
    @IBOutlet weak var TextFieldStationServiceCPVille: UITextField!
    @IBAction func btnChercherStation(_ sender: UITextField) {
        /*self.stationsSearchVC = storyboard?.instantiateViewController(withIdentifier: "stationsSearchList") as! StationsSearchTableViewController
        self.stationsSearchVC!.searchString = self.TextFieldStationService.text! + " " + self.TextFieldStationServiceCPVille.text!
        self.stationsSearchVC?.car = self.car
 self.present(stationsSearchVC!, animated: true, completion: nil)*/
    }
    
    /* Section ravitaillement */
    @IBOutlet weak var TextFieldKilometrage: UITextField!
    @IBOutlet weak var TextFieldDistanceParcourue: UITextField!
    @IBOutlet weak var TextFieldTypeCarburant: UITextField!
    @IBAction func TextFieldTypeCarburant(_ sender: UITextField) {
        
    }
    @IBOutlet weak var TextFieldVolumeCarburant: UITextField!
    @IBOutlet weak var TextFieldPrixConso: UITextField!
    @IBOutlet weak var TextFieldCoutLitre: UITextField!
    @IBOutlet weak var TextFieldConsoCalculee: UITextField!
    @IBOutlet weak var imageViewTypeCarburant: UIImageView!
    @IBOutlet weak var imageViewCoutLitre: UIImageView!
    
    /* Section Mes Notes */
    @IBOutlet weak var TextFieldNotesConso: UITextField!
    
    /* PickerViews */
    var PickerViewCar : UIPickerView!
    var PickerViewStationService : UIPickerView!
    var PickerViewTypesCarburants : UIPickerView!
    
    /* Objets pour datePicker */
    var PickerViewDateRavitaillement:UIDatePicker = UIDatePicker()
    let toolBarDateRavitaillement = UIToolbar()
    
    /* ImagePicker pour choisir une image dans la galerie */
    var imagePicker = UIImagePickerController()
    
    @IBAction func btnChooseImage(_ sender: UIButton) {
        PhotoChooser.shared.showAttachmentActionSheet(vc: self)
        PhotoChooser.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.imageJustificatif.image = image
            self.saveImageToAppFolder(image: image)
            
        }
    }
    
    @IBAction func textFieldDateRavitaillement(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        if(self.langue == "fr"){
            datePickerView.locale = Locale(identifier: "fr_FR")
        }else{
            datePickerView.locale = Locale(identifier: "en_US")
        }
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AddConsoViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    @IBAction func calculerCoutLitre(_ sender: UIButton) {
        calculerCoutLitre()
    }
    @IBAction func btnCalculerConso(_ sender: UIButton) {
        calculerConso()
    }
    
    @IBAction func btnCancelAddConso(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSaveAddConso(_ sender: UIBarButtonItem) {
        let conso:Conso = Conso()
        
        if (Validate() == true) {
        
            conso.idConso = idConso
            
            if let textStationService = self.TextFieldStationService.text{
                conso.nomStation = textStationService
                conso.station?.nomStation = textStationService
            }
            
            if let textAdresseStationService = self.TextFieldStationServiceAdresse.text{
                conso.adresseStation = textAdresseStationService
                self.station!.adresse = textAdresseStationService
            }
            
            if let textCPStationService = self.TextFieldCodePostal.text{
                conso.CPStation = textCPStationService
                self.station!.codePostal = textCPStationService
            }
            
            if let textVilleStationService = self.TextFieldStationServiceCPVille.text{
                conso.villeStation = textVilleStationService
                self.station!.ville = textVilleStationService
            }
            
            if let textDistanceParcourue = self.TextFieldDistanceParcourue.text{
                let strDist = textDistanceParcourue.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
                conso.carKmParcourus = Float(strDist)!
            }
            
            if let textTypeCarburant = self.TextFieldTypeCarburant.text{
                conso.typeCarburant = textTypeCarburant
                station!.carburant = textTypeCarburant
            }
            
            if let textVolCarb = self.TextFieldVolumeCarburant.text{
                let strVolCarb = textVolCarb.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
                conso.volConso = Float(strVolCarb)!
            }
            
            if let textPrix = self.TextFieldPrixConso.text{
                let strPrixCarb = textPrix.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
                conso.prix = Float(strPrixCarb)!
            }
            
            if let textKM = self.TextFieldKilometrage.text{
                conso.carKilometrage = Int(textKM)!
            }
            if(self.TextFieldCoutLitre.text == ""){
                calculerCoutLitre()
            }else{
                conso.coutLitre = Float(self.TextFieldCoutLitre.text!)!
            }
            if(self.TextFieldConsoCalculee.text == ""){
                calculerConso()
            }else{
                conso.conso = Float(self.TextFieldConsoCalculee.text!)!
            }
            if let textCommentaire = self.TextFieldNotesConso.text{
                conso.commentaire = textCommentaire
            }
            
            if let textDateConso = self.TextFieldDateRavitaillement.text{
                let dateFormatter = DateFormatter()
                if(self.langue == "fr"){
                    let dateFormat = "dd/MM/yyyy"
                    dateFormatter.dateFormat = dateFormat
                }else{
                    let dateFormat = "MM/dd/yy"
                    dateFormatter.dateFormat = dateFormat
                }
                
                guard let dated = dateFormatter.date(from: textDateConso /* your_date_string */) else {
                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                }
                
                conso.dateConso = dated
            }
        
            conso.carName = (TextFieldCarPseudo?.text)!
            
            let imageStation = UIImagePNGRepresentation(imageViewStationService.image!) as NSData?
            conso.data = imageStation
            station!.data = imageStation
            let realm = try! Realm()
            /* Ajouter l'opération de ravitaillement dans la base de données */
            try! realm.write {
                realm.add(conso)
            }
            try! realm.write {
                realm.add(station!)
            }
            /* Rafraichir la liste des voitures avant affichage */
            self.navigationController?.popViewController(animated: true)    // A utiliser si le VC a été lancé par code en utilisant un navigation controller
            
            /* Notifier le rechargement de la liste après insertion dans bdd */
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            
            synchronizeWithFirestore()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Initialisation de Realm */
        let realm = try! Realm()
        print("AddConsoViewController:realmInit")
        
        //docRef = Firestore.firestore().document("Station")
        
        /* On génère l'id de l'objet pour pouvoir l'utiliser dans le nommage de l'image */
        createConsoId()
        
        /*if(source == "stationSearch"){
            self.TextFieldStationService?.text = self.station?.nomStation
            self.TextFieldStationServiceAdresse?.text = self.station?.adresse
            self.TextFieldCodePostal?.text = self.station?.codePostal
            self.TextFieldStationServiceCPVille?.text = self.station?.ville
        }*/
        
        if(station == nil){
            station = Station()
        }
        
        self.stationsSearchVC?.dismiss(animated: true, completion: nil)
        self.TextFieldStationService?.text = station!.nomStation
        self.TextFieldStationServiceAdresse?.text = station!.adresse
        self.TextFieldStationServiceCPVille?.text = station!.ville
        self.TextFieldCodePostal?.text = station!.codePostal
        
        //self.oConso?.dateConso = self.TextFieldDateRavitaillement?.text

        let carData = self.car?.data
        let carImage = UIImage(data: carData! as Data)
        imageViewCar.image = carImage

        /* On assigne un évenement tap au justificatif */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageJustificatif.isUserInteractionEnabled = true
        imageJustificatif.addGestureRecognizer(tapGestureRecognizer)
        
        /* récupération de la langue de l'iphone */
        self.langue = UserDefaults.standard.string(forKey: "phoneLanguage")!
        self.appDirPath = UserDefaults.standard.string(forKey: "appFolder")!
        imagePicker.delegate = self
        
        imageViewTypeCarburant.layer.masksToBounds = true
        imageViewTypeCarburant.layer.cornerRadius = 5.0
        
        imageViewCoutLitre.layer.masksToBounds = true
        imageViewCoutLitre.layer.cornerRadius = 5.0
        
        // Do any additional setup after loading the view.
        TextFieldCarPseudo.delegate = self
        TextFieldCarPseudo.tag = 0
        TextFieldCarPseudo.returnKeyType = .next
        
        TextFieldCarMarque.delegate = self
        TextFieldCarMarque.tag = 1
        TextFieldCarMarque.returnKeyType = .next
        
        TextFieldCarModele.delegate = self
        TextFieldCarModele.tag = 2
        TextFieldCarModele.returnKeyType = .next
        
        TextFieldDateRavitaillement.delegate = self
        TextFieldDateRavitaillement.tag = 3
        TextFieldDateRavitaillement.returnKeyType = .next
        
        TextFieldStationService.delegate = self
        TextFieldStationService.tag = 4
        TextFieldStationService.returnKeyType = .next
        
        TextFieldStationServiceAdresse.delegate = self
        TextFieldStationServiceAdresse.tag = 5
        TextFieldStationServiceAdresse.returnKeyType = .next
        
        TextFieldStationServiceCPVille.delegate = self
        TextFieldStationServiceCPVille.tag = 6
        TextFieldStationServiceCPVille.returnKeyType = .next
        
        TextFieldKilometrage.delegate = self
        TextFieldKilometrage.tag = 7
        TextFieldKilometrage.returnKeyType = .next
        
        TextFieldDistanceParcourue.delegate = self
        TextFieldDistanceParcourue.tag = 8
        TextFieldDistanceParcourue.returnKeyType = .next
        
        TextFieldTypeCarburant.delegate = self
        TextFieldTypeCarburant.tag = 9
        TextFieldTypeCarburant.returnKeyType = .next
        
        TextFieldVolumeCarburant.delegate = self
        TextFieldVolumeCarburant.tag = 10
        TextFieldVolumeCarburant.returnKeyType = .next
        
        TextFieldPrixConso.delegate = self
        TextFieldPrixConso.tag = 11
        TextFieldPrixConso.returnKeyType = .next
        
        TextFieldCoutLitre.delegate = self
        TextFieldCoutLitre.tag = 12
        TextFieldCoutLitre.returnKeyType = .next
        
        TextFieldConsoCalculee.delegate = self
        TextFieldConsoCalculee.tag = 13
        TextFieldConsoCalculee.returnKeyType = .next
        
        TextFieldNotesConso.delegate = self
        TextFieldNotesConso.tag = 14
        TextFieldNotesConso.returnKeyType = .go
        
        /* Constitution de la liste de pseudos d'amis pour alimenter le PickerView  */
        self.listOfCars = Array(realm.objects(Car.self))
        self.listConso = Array(realm.objects(Conso.self))
        TextFieldDateRavitaillement.delegate = self
        
        TextFieldCarMarque?.text = self.car?.marque
        TextFieldCarModele?.text = self.car?.modele
        TextFieldCarPseudo?.text = self.car?.pseudo
        
    }
    
    func synchronizeWithFirestore(){
        //let stationCollection = Firestore.firestore().collection("stations")
        
        /*let dataToSave : [String: Any] = ["nomStation": self.TextFieldStationService.text, "adresse": self.TextFieldStationServiceAdresse, "ville": self.TextFieldStationServiceCPVille]
        docRef.setData(dataToSave){ (error) in
            if let error = error {
                print("Oh no! Some error \(error.localizedDescription)")
            }else {
                print("Data has been saved")
            }
        }
        let station (
                nomStation: TextFieldStationService.text,
                coordGPS: "",
                adresse: TextFieldStationServiceAdresse.text,
                ville: TextFieldStationServiceCPVille.text,
                codePostal: "",
                commentaire: "",
                carburant: "",
                prixCarburant: ""
            )
        stationCollection.addDocument(data: station.dictionary)*/
    }
    
    @IBAction func unwindStationsVCtoAddConsoVC(segue:UIStoryboardSegue) {
        print("Reception data")
        /*if segue.source is StationsSearchTableViewController {
            if let senderVC = segue.source as? StationsSearchTableViewController {
                let stationName = senderVC.coordGPS
                
                self.TextFieldStationServiceAdresse?.text = senderVC.station?.adresse
                self.TextFieldCodePostal?.text = senderVC.station?.codePostal
                self.TextFieldStationServiceCPVille?.text = senderVC.station?.ville
                
            }
        }*/
    }
    
    func saveImageToAppFolder(image: UIImage){
        
        let fileStr = "AutoConso/" + idConso + ".jpeg"
        
        
        print("saveImageToAppFolder", fileStr)
        if let data = UIImageJPEGRepresentation(image, 1.0),
            !FileManager.default.fileExists(atPath: fileStr) {

            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = dir!.appendingPathComponent(fileStr)
            
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
                showToast(message: "le justificatif a bien été enregistré dans votre iPhone")
            } catch {
                print("error saving file:", error)
                showToast(message: "Erreur à l'enregistrement du justificatif")
            }
        }
    }
    
    func saveDocToAppFolder(docURL: URL){
        let ext = docURL.path.suffix(4)
        let destURL = appDirPath + "/" + idConso + ext
        print("saveDocToAppFolder", destURL)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: destURL) == false {
            
            do {
                // Move 'hello.swift' to 'subfolder/hello.swift'
                try fileManager.moveItem(atPath: docURL.path, toPath: destURL)
                print("Move successful")
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
            
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let chemin = self.appDirPath + "/" + self.idConso + ".jpeg"
        let fd = open(chemin, O_WRONLY|O_CREAT, 0o666)
        
        if fd < 0 {
            perror("could not open " + chemin)
        } else {
            print("fichier ouvert!")
        }
        // Your action
    }
    
    
    /* Gestion du pickerView qui affiche les voitures */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == PickerViewStationService){ return listOfStationServices.count}
        if(pickerView == PickerViewCar){ return listOfCars.count}
        if(pickerView == PickerViewTypesCarburants){
            if(self.langue == "fr"){
                return listOfTypesCarburants.count
            }else{
                return listOfTypesCarburantsEN.count
            }
        }
        return 1
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == PickerViewStationService){
            selectedStationService = listOfStationServices[row]
            print("Station service = "+selectedStationService)
            return selectedStationService
        }
        if(pickerView == PickerViewCar){
            print("car = "+listOfCars[row].pseudo)
            return listOfCars[row].pseudo
        }
        if(pickerView == PickerViewTypesCarburants){
            if(self.langue == "fr"){
                selectedCarburant = listOfTypesCarburants[row]
                print("carburant = "+listOfTypesCarburants[row])
            }else{
                selectedCarburant = listOfTypesCarburantsEN[row]
                print("carburant = "+listOfTypesCarburantsEN[row])
            }
            return selectedCarburant
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(pickerView == PickerViewStationService){
            
            print("selected Station service is "+listOfStationServices[row])
            TextFieldStationService?.text = listOfStationServices[row]
            
            let nomStation = listOfStationServices[row]

            if (UIImage(named: nomStation) != nil) {
                print("Image station existing")
                imageViewStationService.image = UIImage(named: nomStation)
            }
            else {
                print("Image station is not existing")
                imageViewStationService.image = UIImage(named: "icon_fuel_3D")
            }
        }
        if(pickerView == PickerViewTypesCarburants){
            if(self.langue == "fr"){
                print("selected carburant is "+listOfTypesCarburants[row])
                TextFieldTypeCarburant?.text = listOfTypesCarburants[row]
            }else{
                print("selected carburant is "+listOfTypesCarburantsEN[row])
                TextFieldTypeCarburant?.text = listOfTypesCarburantsEN[row]
            }
            
        }
        if(pickerView == PickerViewCar){
            selectedCar = listOfCars[row].pseudo
            print("selected Car is "+selectedCar)
            
            let marque = listOfCars[row].marque
            TextFieldCarPseudo?.text = listOfCars[row].pseudo
            TextFieldCarMarque?.text = marque
            TextFieldCarModele?.text = listOfCars[row].modele
            
            if (UIImage(named: marque) != nil) {
                print("Image station existing")
                imageViewCarMarque.image = UIImage(named: marque)
            }
            else {
                print("Image station is not existing")
                imageViewCarMarque.image = UIImage(named: "icon_car")
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is StationsSearchTableViewController
        {
            /* On créer l'id de la station à sélectionner */
            createStationId()
            let station = Station.self
            
            let vc = segue.destination as? StationsSearchTableViewController
            var searchString = self.TextFieldStationService.text!
            
            if(self.TextFieldCodePostal.text != ""){
                searchString = searchString + " " + self.TextFieldCodePostal.text!
            }else{
                if(self.TextFieldStationServiceCPVille.text != ""){
                    searchString = searchString + " " + self.TextFieldStationServiceCPVille.text!
                }
            }
            print("searchString",searchString)
            self.oConso = Conso()
            self.oConso?.carName = (self.TextFieldCarPseudo?.text)!
            
            /* Envoi de la recherche */
            vc!.senderVC = "AddConsoVC"
            vc!.stationName = self.TextFieldStationService.text!
            vc!.stationVille = self.TextFieldStationServiceCPVille.text!
            vc!.searchString = searchString
            vc!.car = self.car
            vc!.oConso = self.oConso
            vc?.addConsoVC = self // Je lie les 2 viewControllers pour que quand je sélectionne une donnée de vc, je puisse appeler une fonction de addConso
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
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        let setting = UserDefaults.standard
        let strkmdebut: String = setting.object(forKey: "carKM") as! String
        let kmdebut = Int(strkmdebut)
        
        if textField == TextFieldKilometrage{
            let kmSaisi = Int(TextFieldKilometrage.text!)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.resignFirstResponder()
        print(textField)
        if textField == TextFieldStationService{
            self.pickUpStationService(TextFieldStationService)
        }
        if textField == TextFieldCarPseudo{
            if listOfCars.count == 1 {
                TextFieldCarPseudo.text = listOfCars[0].pseudo
                TextFieldCarMarque.text = listOfCars[0].marque
                TextFieldCarModele.text = listOfCars[0].modele
                selectedCar = listOfCars[0].pseudo
            }else{
                self.pickUpCar(TextFieldCarPseudo)
            }
        }
        if textField == TextFieldTypeCarburant{
            self.pickUpCarburant(TextFieldTypeCarburant)
        }
        if textField == TextFieldDateRavitaillement{
            //launchAlertDatePicker()
            /*textField.inputView = self.PickerViewDateRavitaillement
            textField.inputAccessoryView = self.toolBarDateRavitaillement*/
            //self.pickupDateRavitaillement(textField)
            
            if TextFieldDateRavitaillement.text!.isEmpty {
                if(self.langue == "fr"){
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy"
                    formatter.dateStyle = .short
                    formatter.timeStyle = .none
                    TextFieldDateRavitaillement.text = formatter.string(from: Date())
                }else{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yy"
                    formatter.dateStyle = .short
                    formatter.timeStyle = .none
                    TextFieldDateRavitaillement.text = formatter.string(from: Date())
                }
            }
            
        }
        if textField == TextFieldVolumeCarburant{
            
        }
        if textField == TextFieldDistanceParcourue{
            /*if(TextFieldKilometrage?.text != nil){
                if(self.listConso.count > 0){
                    if let lastKM = self.realm!.objects(Conso.self).sorted(byKeyPath: "dateConso").last?.carKilometrage {
                        var KMcalc:Int = Int((TextFieldKilometrage?.text)!)!  - lastKM
                        TextFieldDistanceParcourue?.text = KMcalc.description
                    }else{
                        var KMcalc:Int = 0
                        TextFieldDistanceParcourue?.text = ""
                    }
                }
            }*/
        }
    }
    
    /***
     
     SECTION QUI CONTIENT LES DIFFERENTS PICKERS DE L'INTERFACE
     
     ***/
    
    /* pickUpCar permet la sélection d'une voiture dans la liste des voitures */
    func pickUpCar(_ textField : UITextField){
        
        // UIPickerView pour les voitures
        self.PickerViewCar = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewCar.delegate = self
        self.PickerViewCar.dataSource = self
        self.PickerViewCar.backgroundColor = UIColor.white
        TextFieldCarPseudo.inputView = self.PickerViewCar
        
        // Barre d'outils
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 102/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Enrichissement de la barre d'outils
        let doneButton = UIBarButtonItem(title: "Valider", style: .plain, target: self, action: #selector(AddConsoViewController.doneCarClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Fermer", style: .plain, target: self, action: #selector(AddConsoViewController.cancelCarClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        TextFieldCarPseudo.inputAccessoryView = toolBar
    }
    
    @objc func doneCarClick() {
        TextFieldCarPseudo.resignFirstResponder()
    }
    @objc func cancelCarClick() {
        TextFieldCarPseudo.resignFirstResponder()
    }
    
    
    /*
     *  pickUpStationService : Permet la sélection des stations services
     */
    
    func pickUpStationService(_ textField : UITextField){
        
        // UIPickerView
        self.PickerViewStationService = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewStationService.delegate = self
        self.PickerViewStationService.dataSource = self
        self.PickerViewStationService.backgroundColor = UIColor.white
        TextFieldStationService.inputView = self.PickerViewStationService
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 102/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Valider", style: .plain, target: self, action: #selector(AddConsoViewController.doneStationServiceClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Fermer", style: .plain, target: self, action: #selector(AddConsoViewController.cancelStationServiceClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        TextFieldStationService.inputAccessoryView = toolBar
    }
    
    @objc func doneStationServiceClick() {
        TextFieldStationService.resignFirstResponder()
    }
    @objc func cancelStationServiceClick() {
        TextFieldStationService.resignFirstResponder()
    }
    
    func onStationServiceSelected(station:Station)
    {
        print(onStationServiceSelected)
        //self.stationsSearchVC?.dismiss(animated: true, completion: nil)
        self.TextFieldStationService?.text = station.nomStation
        self.TextFieldStationServiceAdresse?.text = station.adresse
        self.TextFieldStationServiceCPVille?.text = station.ville
        self.TextFieldCodePostal?.text = station.codePostal
        
        /*var navigationArray = self.navigationController?.viewControllers //To get all UIViewController stack as Array
        navigationArray!.remove(at: (navigationArray?.count)! - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray!*/
    }
    
    /*
     *  pickupDateRavitaillement : Permet la sélection de la date de ravitaillement
     */
    
    func pickupDateRavitaillement(_ textField : UITextField){
        
        
        self.PickerViewDateRavitaillement = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewDateRavitaillement.backgroundColor = .white
        self.PickerViewDateRavitaillement.datePickerMode = .date
        textField.inputView = self.PickerViewDateRavitaillement
        
        /* Barre d'outils */
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 102/255, alpha: 1)
        toolBar.sizeToFit()
        
        /* Ajout de boutons OK et FERMER dans la barre d'outils */
        let doneButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(AddConsoViewController.doneDateClick(picker: )))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "FERMER", style: .plain, target: self, action: #selector(AddConsoViewController.cancelDateClick))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneDateClick(picker: UIDatePicker) {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        /*TextFieldDateRavitaillement?.text = dateFormatter1.string(from: picker)*/
        TextFieldDateRavitaillement.resignFirstResponder()
    }
    
    @objc func cancelDateClick() {
        /*PickerViewDateRavitaillement.isHidden = true
        self.toolBarDateRavitaillement.isHidden = true*/
        TextFieldDateRavitaillement.resignFirstResponder()
    }
    
    
    /*
     *  pickUpStationService : Permet la sélection du type de carburant
     */
    
    func pickUpCarburant(_ textField : UITextField){
        
        // UIPickerView
        self.PickerViewTypesCarburants = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.PickerViewTypesCarburants.delegate = self
        self.PickerViewTypesCarburants.dataSource = self
        self.PickerViewTypesCarburants.backgroundColor = UIColor.white
        TextFieldTypeCarburant.inputView = self.PickerViewTypesCarburants
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 102/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Valider", style: .plain, target: self, action: #selector(AddConsoViewController.doneCarburantClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Fermer", style: .plain, target: self, action: #selector(AddConsoViewController.cancelCarburantClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        TextFieldTypeCarburant.inputAccessoryView = toolBar
    }
    
    @objc func doneCarburantClick() {
        TextFieldTypeCarburant.resignFirstResponder()
    }
    @objc func cancelCarburantClick() {
        TextFieldTypeCarburant.resignFirstResponder()
    }
    
    func calculerConso(){
        
        /* Popup d'erreur de calcul conso */
        
        let ConsoAlert = UIAlertController(title: "Donnée manquante", message: "L'un des champs 'volume carburant' ou 'kilomètres parcouru' est vide. La conso ne peut être calculée.", preferredStyle: UIAlertControllerStyle.alert)
        
        ConsoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler:
            { (action: UIAlertAction!) in
                print("L'utilisateur a décidé de supprimer une ligne de conso")
        })
        )
        
        if((!(TextFieldDistanceParcourue.text?.isEmpty)!)&&(!(TextFieldVolumeCarburant.text?.isEmpty)!)){
            
            let flVolume: Float? = Float(self.TextFieldVolumeCarburant.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
            let flkm: Float? = Float(self.TextFieldDistanceParcourue.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
            let consobrut = 100.00 * ( flVolume! / flkm! )
            
            let conso = (consobrut * 100).rounded() / 100
            
            print("conso = "+conso.description)
            TextFieldConsoCalculee?.text = conso.description
            
        }else if((TextFieldDistanceParcourue.text?.isEmpty)!){
            self.present(ConsoAlert, animated: true, completion: nil)
        }else if((TextFieldVolumeCarburant.text?.isEmpty)!){
            self.present(ConsoAlert, animated: true, completion: nil)
        }
        
    }
    
    func calculerCoutLitre(){
        
        /* Popup d'erreur de calcul du cout au litre */
        
        let CouLAlert = UIAlertController(title: "Donnée manquante", message: "L'un des champs 'prix carburant' ou 'volume' est vide. Le cout au litre ne peut être calculé.", preferredStyle: UIAlertControllerStyle.alert)
        
        CouLAlert.addAction(UIAlertAction(title: "OK", style: .default, handler:
            { (action: UIAlertAction!) in
        })
        )
        
        if((!(TextFieldPrixConso.text?.isEmpty)!)&&(!(TextFieldVolumeCarburant.text?.isEmpty)!)){

            let flVolume: Float? = Float(self.TextFieldVolumeCarburant.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
            let flprix: Float? = Float(self.TextFieldPrixConso.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
            let coutLBrut = ( flprix! / flVolume! )
            let roundCoutL = (coutLBrut * 100).rounded()/100
            print("coutL = "+roundCoutL.description)
            TextFieldCoutLitre?.text = roundCoutL.description
            
        }else if((TextFieldPrixConso.text?.isEmpty)!){
            self.present(CouLAlert, animated: true, completion: nil)
        }else if((TextFieldVolumeCarburant.text?.isEmpty)!){
            self.present(CouLAlert, animated: true, completion: nil)
        }
        
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        if(self.langue == "fr"){
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }else{
            dateFormatter.dateFormat = "MM/dd/yy"
        }
        
        TextFieldDateRavitaillement.text = dateFormatter.string(from: sender.date)
    }

    /* Fonction qui valide les informations avant d'enregistrer */
    
    func Validate() -> Bool{
        var valid:Bool = true
        
        let warnSelectCar = NSLocalizedString("Veuillez sélectionner une voiture", comment: "warnSelectCar")
        let warnSelectFuelStation = NSLocalizedString("Veuillez sélectionner une station service", comment: "warnSelectFuelStation")
        let warnPromptKM = NSLocalizedString("Veuillez saisir le kilometrage vehicule", comment: "warnPromptKM")
        let errorCoveredDistance = NSLocalizedString("Distance parcourue erronée", comment: "errorCoveredDistance")
        let warnIncorrectCarburant = NSLocalizedString("Veuillez saisir un volume de carburant correct", comment: "warnIncorrectCarburant")
        let warnPrixIncorrect = NSLocalizedString("Veuillez saisir un montant valide", comment: "warnPrixIncorrect")
        
        if TextFieldCarPseudo.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldCarPseudo if
            TextFieldCarPseudo.attributedPlaceholder = NSAttributedString(string: warnSelectCar, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldCarPseudo)
        }
        if TextFieldStationService.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldStationService if
            TextFieldStationService.attributedPlaceholder = NSAttributedString(string: warnSelectFuelStation, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldStationService)
        }
        if TextFieldKilometrage.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldKilometrage if
            TextFieldKilometrage.attributedPlaceholder = NSAttributedString(string: warnPromptKM, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldKilometrage)
        }
        if TextFieldDistanceParcourue.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
            TextFieldDistanceParcourue.attributedPlaceholder = NSAttributedString(string: errorCoveredDistance, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldDistanceParcourue)
        }
        if TextFieldVolumeCarburant.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
            TextFieldVolumeCarburant.attributedPlaceholder = NSAttributedString(string: warnIncorrectCarburant, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldVolumeCarburant)
        }
        if TextFieldPrixConso.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldPrixConso if
            TextFieldPrixConso.attributedPlaceholder = NSAttributedString(string: warnPrixIncorrect, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldPrixConso)
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
    
    private func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var valid :Bool = true
        if textField == TextFieldKilometrage {
            let newlength = textField.text!.utf16.count + string.utf16.count - range.length
            valid = newlength < 7
        }
        else if textField == TextFieldDistanceParcourue{
            let newlength = textField.text!.utf16.count + string.utf16.count - range.length
            valid = newlength < 5 // Permet de valider le nombre de caracteres du champ
        }
        return valid
    }
    
    /* Fonction qui crée l'id de la conso */
    @objc func createConsoId() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "ddMMYYYYHHmmss"
        self.idConso = "Conso-" + dateFormatter.string(from: Date())
    }
    
    /* Fonction qui crée l'id de la conso */
    @objc func createStationId() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "ddMMYYYYHHmmss"
        self.idStation = "Station-" + dateFormatter.string(from: Date())
    }
}
