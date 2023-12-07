//
//  AddConsoViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 20/07/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift

class AddConsoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    

    /* Initialisation de Realm */
    let realm = try! Realm()
    
    var data:Results<Car>!
    var listOfCars:[Car] = []
    
    
    @IBOutlet weak var pickerViewListeCars: UIPickerView!
    @IBOutlet weak var dateTimePickerConso: UIDatePicker!
    @IBOutlet weak var textKMVoiture: UITextField!
    @IBOutlet weak var textDistanceVoiture: UITextField!
    @IBOutlet weak var textVolCarbConso: UITextField!
    @IBOutlet weak var textConsoCalculee: UITextField!
    @IBOutlet weak var textStationService: UITextField!
    @IBOutlet weak var textCoutLitreConso: UITextField!
    @IBOutlet weak var textPrixConso: UITextField!
    
    @IBAction func btnSaveConso(_ sender: UIBarButtonItem) {
        /* Récupération des informations saisies dans les champs texte */
        let dateConso = dateTimePickerConso.date.description
        let KMVoiture = textKMVoiture?.text
        let distanceParcourue = textDistanceVoiture?.text
        let volumeCarburant = textVolCarbConso?.text
        let consoCalculee = textConsoCalculee?.text
        let nomStation = textStationService?.text
        let coutLitre = textCoutLitreConso?.text
        let prixTotal = textPrixConso?.text
        
        print("saveConsoPressed")
        /* Teste si les champs importants sont vides. Si oui surligne la bordure en rouge. */
        if(textKMVoiture.text == ""){
            textKMVoiture.layer.borderColor = UIColor.red.cgColor
            return
        }
        if(textDistanceVoiture.text == ""){
            textDistanceVoiture.layer.borderColor = UIColor.red.cgColor
            return
        }
        if(textVolCarbConso.text == ""){
            textVolCarbConso.layer.borderColor = UIColor.red.cgColor
            return
        }
        if(textStationService.text == ""){
            textStationService.layer.borderColor = UIColor.red.cgColor
            return
        }
        if(textPrixConso.text == ""){
            textPrixConso.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        /* Calcul de la conso */
        /*let flNbLitres = (textVolCarbConso.text! as NSString).floatValue
        let flDistance = (textDistanceVoiture.text! as NSString).floatValue
        
        let consoCalc = String(describing: (100 * flNbLitres / flDistance))
        let prixLitres = String(describing: (((textPrixConso.text! as NSString).floatValue)/flNbLitres))
        
        print("consoCalculee : "+consoCalc+" PrixLitres : "+prixLitres)*/
        
        /*let consoItem = Conso(idCar: 1, carKilometrage: KMVoiture, carKmParcourus: distanceParcourue, dateConso: dateConso, station: nomStation, conso: consoCalculee, volConso: volumeCarburant, prix: prixTotal, coutLitre: coutLitre)*/
        
        let consoItem = Conso(idCar: 1, carKilometrage: "152034", carKmParcourus: "1032", dateConso: dateConso, station: "TOTO", conso: "5,98", volConso: "56,65", prix: "100,23", coutLitre: "1,57")
        
        print(consoItem)
        self.dismiss(animated: true)
    }
    @IBAction func btnCancelConso(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //manipulateKeyboard();
        // Do any additional setup after loading the view.
        /* Definition des sources du PickerView */
        self.pickerViewListeCars.dataSource = self
        self.pickerViewListeCars.delegate = self
        
        /* Constitution de la liste des voitures pour alimenter le PickerView  */
        self.data = realm.objects(Car.self)
        self.listOfCars = Array(self.data)
        
        /* Initialiser les textFields pour gerer le contenu des champs et faire disparaitre le clavier */
        textKMVoiture.delegate = self
        textKMVoiture.tag = 0
        textKMVoiture.returnKeyType = .next
        
        textDistanceVoiture.delegate = self
        textDistanceVoiture.tag = 1
        textDistanceVoiture.returnKeyType = .next
        
        textVolCarbConso.delegate = self
        textVolCarbConso.tag = 2
        textVolCarbConso.returnKeyType = .next
        
        textPrixConso.delegate = self
        textPrixConso.tag = 3
        textPrixConso.returnKeyType = .next
        
        textCoutLitreConso.delegate = self
        textCoutLitreConso.tag = 4
        textCoutLitreConso.returnKeyType = .next
        
        textConsoCalculee.delegate = self
        textConsoCalculee.tag = 5
        textConsoCalculee.returnKeyType = .next
        
        textStationService.delegate = self
        textStationService.tag = 6
        textStationService.returnKeyType = .go
        
        
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
        /*textField.resignFirstResponder()
        return true;*/
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listOfCars.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("car = "+listOfCars[row].modele)
        return listOfCars[row].modele
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("selected Car is "+listOfCars[row].modele)
    }
    
    var dateFormatter: DateFormatter = {
        let _formatter = DateFormatter()
        _formatter.dateFormat = "DD/MM/YYYY'T'HH:mm:ss.SSSX"
        _formatter.locale = Locale(identifier: "fr_FR")
        _formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return _formatter
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func manipulateKeyboard() {
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", barButtonSystemItem: .done, target: self, action: Selector("doneButtonAction"))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        self.textKmParcouru.inputAccessoryView = toolbar
        self.textNbLitres.inputAccessoryView = toolbar
    }
    func doneButtonAction() {
        self.view.endEditing(true)
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func builtAlert(){
        let alert = UIAlertController(title: "Click event", message: "Vous avez cliqué sur enregistrer", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
