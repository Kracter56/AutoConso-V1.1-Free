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
import CoreLocation
import SCLAlertView
import LCUIComponents
import AMPopTip
import Firebase
import MapKit
import CWProgressHUD
import GeoQueries

class AddConsoViewController: UITableViewController , UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    //var docRef : DocumentReference!
    var locationFixAchieved:Bool?
    var realm:Realm?
    var data:Results<Car>!
    var listOfCars:[Car] = []
    var listConso:[Conso] = []
    var listStations:[Station] = []
	var listStationsFavorites:[Station] = []
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
    var idCar:String?
    var searchString = ""
    var source = ""
	var stPlein:Bool?
    var station:Station?
    var oConso:Conso?
    var settings:UserDefaults?
    let locationManager = CLLocationManager()
    var stationsList:[(key:Int, value:String)] = []
	var localisationOK:Bool?
	var coordGPS = CLLocation()
	var bLocalize = false
	var sAddress:String?
	var listOfTypesCarburants:[typeCarburant] = []
	@IBOutlet weak var typeParcours: UISegmentedControl!
	var connected:Bool?
	//var GPSCoordinates:location?
    
    var stationsSearchVC:StationsSearchTableViewController?
    let listOfStationServices:[String] = ["AGIP", "ANTAR", "AUCHAN", "AVIA", "BP", "CARREFOUR", "DYNEFF", "E.LECLERC", "ELF", "ESSO EXPRESS", "ESSO", "EXXON", "FINA", "IRVING", "SHELL", "TOTAL ACCESS", "TOTAL", "U"]
	//var listOfTypesCarburants:[String] = ["Super", "Sans Plomb 98", "Sans Plomb 95", "Sans Plomb 95 E10", "Diesel", "Diesel Premier", "Diesel Excellium", "BP Ulitmate", "GPL"]
    let listOfTypesCarburantsEN:[String] = ["ESSENCE PLUS (Haut de gamme)", "SUPER", "SANS PLOMB 98", "SANS PLOMB 95", "SANS PLOMB 95 E10", "DIESEL PLUS (Haut de gamme)", "GAZOLE", "ETHANOL", "FlexFuel", "GPL"]
    
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
    @IBOutlet weak var imgChercherStation: UIImageView!
    @IBOutlet weak var imgLocaliser: UIImageView!
	@IBOutlet weak var latitudeValue: UILabel!
	@IBOutlet weak var longitudeValue: UILabel!
	@IBOutlet weak var btnStationName: UIButton!
	
	
	@IBAction func btnChercherStation(_ sender: UIButton) {
		self.bLocalize = false
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "stationsSearchList") as! stationsTableViewController
		
		/* On créer l'id de la station à sélectionner */
		createStationId()
		let carName = self.TextFieldCarPseudo.text
		//let station = Station.self
		
		let searchedStation = self.btnStationName.title(for: .normal)
		let searchedAddress = self.TextFieldStationServiceAdresse.text!
		let searchedVille = self.TextFieldStationServiceCPVille.text!
		let searchedCP = self.TextFieldCodePostal.text!
		
		print("searchedStation",searchedStation)
		print("searchedAddress",searchedAddress)
		print("searchedCP",searchedCP)
		print("searchedVille",searchedVille)
		
		self.oConso = Conso()
		self.oConso?.carName = (self.TextFieldCarPseudo?.text)!
		
		/* Envoi de la recherche */
		vc.senderVC = "AddConsoVC"
		vc.stationName = searchedStation
		vc.searchedAddress = searchedAddress
		vc.searchedVille = searchedVille
		vc.searchedCP = searchedCP.trimmingCharacters(in: .whitespacesAndNewlines)
		vc.currentCoordGPS = self.coordGPS
		vc.carName = carName
		vc.oConso = self.oConso
		vc.addConsoVC = self
		vc.latitudeDistance = 2000
		vc.longitudeDistance = 2000
		vc.currentAddress = self.sAddress
		// Je lie les 2 viewControllers pour que quand je sélectionne une donnée de vc, je puisse appeler une fonction de addConso
		
		// On affiche le VC Stations
		navigationController?.pushViewController(vc, animated: true)
	}
	@IBAction func switchPlein(_ sender: UISwitch) {
		if sender.isOn {
			self.stPlein = true
			print("stPlein = true")
		}else{
			self.stPlein = false
			print("stPlein = false")
		}
	}
	@IBAction func typeParcours(_ sender: UISegmentedControl) {
	}
	
    @IBAction func btnLocaliser(_ sender: Any) {
		CWProgressHUD.show()
		self.bLocalize = true
		Utility.getCurrentCoordinates(completion: {
			(statut) in
			if (statut == 1){
				self.coordGPS = Utility.currentCoordinates
				
				/* Once coordinates are obtained, display on the form */
				self.latitudeValue.text = self.coordGPS.coordinate.latitude.description
				self.longitudeValue.text = self.coordGPS.coordinate.longitude.description
				
				/* Convert coordinates to address using Utility class */
				Utility.getAdressFromLocation(loc: self.coordGPS, completion: {
					(numero, adresse, codePostal, ville) in
					
					self.station?.adresse = numero + ", " + adresse
					self.station?.codePostal = Int(codePostal)!
					self.station?.ville = ville
					
					self.TextFieldStationServiceAdresse.text = self.station?.adresse
					self.TextFieldStationServiceCPVille.text = self.station?.ville
					self.TextFieldCodePostal.text = self.station?.codePostal.description
					CWProgressHUD.dismiss()
				})
			}
		})
		
		/*let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "stationsSearchList") as! stationsTableViewController
		
		/* On créer l'id de la station à sésfflectionner */
		createStationId()
		let carName = self.TextFieldCarPseudo.text
		
		let searchedStation = self.TextFieldStationService.text!
		let searchedAddress = self.TextFieldStationServiceAdresse.text!
		let searchedVille = self.TextFieldStationServiceCPVille.text!
		let searchedCP = self.TextFieldCodePostal.text!
		
		//let searchString = self.TextFieldStationService.text!
		
		print("searchedStation",searchedStation)
		print("searchedAddress",searchedAddress)
		print("searchedCP",searchedCP)
		print("searchedVille",searchedVille)
		
		self.oConso = Conso()
		self.oConso?.carName = (self.TextFieldCarPseudo?.text)!
		
		/* Envoi de la recherche */
		vc.senderVC = "locateMyStation"
		vc.stationName = searchedStation
		vc.searchedAddress = searchedAddress
		vc.searchedVille = searchedVille
		vc.searchedCP = searchedCP.trimmingCharacters(in: .whitespacesAndNewlines)
		vc.currentCoordGPS = self.coordGPS
		vc.carName = carName
		vc.oConso = self.oConso
		vc.addConsoVC = self
		vc.latitudeDistance = 200
		vc.longitudeDistance = 200
		// Je lie les 2 viewControllers pour que quand je sélectionne une donnée de vc, je puisse appeler une fonction de addConso
		
		// On affiche le VC Stations
		navigationController?.pushViewController(vc, animated: true)*/
		
    }
    
    @IBAction func btnInfoKMParcourus(_ sender: UIButton) {
        let popTip = PopTip()
        popTip.show(text: "Nombre de kilométres parcourus depuis le dernier plein", direction: .up, maxWidth: 200, in: view, from: UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).frame)
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
    @IBAction func btnHistory(_ sender: UIButton) {
        setupBasicStationsPopover(for: sender)
    }
    
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
		datePickerView.datePickerMode = UIDatePicker.Mode.date
        if(self.langue == "fr"){
            datePickerView.locale = Locale(identifier: "fr_FR")
        }else{
            datePickerView.locale = Locale(identifier: "en_US")
        }
        sender.inputView = datePickerView
		datePickerView.addTarget(self, action: #selector(AddConsoViewController.datePickerValueChanged), for: UIControl.Event.valueChanged)
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
        
			self.oConso!.idConso = self.idConso
            
            if let textStationService = self.btnStationName.title(for: .normal){
				self.oConso!.station?.marque = textStationService
            }
            
            if let textAdresseStationService = self.TextFieldStationServiceAdresse.text{
				self.oConso!.adresseStation = textAdresseStationService
				self.oConso!.station?.adresse = textAdresseStationService
                self.station!.adresse = textAdresseStationService
            }
            
            if let textCPStationService = self.TextFieldCodePostal.text{
				self.oConso!.CPStation = textCPStationService
				self.oConso!.station?.codePostal = Int(textCPStationService)!
				self.station!.codePostal = Int(textCPStationService)!
            }
            
            if let textVilleStationService = self.TextFieldStationServiceCPVille.text{
				self.oConso!.villeStation = textVilleStationService
				self.oConso!.station?.ville = textVilleStationService
				self.oConso!.nomStation = self.btnStationName.title(for: .normal)! + " " + textVilleStationService
                self.station!.ville = textVilleStationService
            }
            
            if let textDistanceParcourue = self.TextFieldDistanceParcourue.text{
                let strDist = textDistanceParcourue.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
				self.oConso!.carKmParcourus = Float(strDist)!
            }
            
            if let textTypeCarburant = self.TextFieldTypeCarburant.text{
				self.oConso!.typeCarburant = textTypeCarburant
                self.station!.carburant = textTypeCarburant
            }
            
            if let textVolCarb = self.TextFieldVolumeCarburant.text{
                let strVolCarb = textVolCarb.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
				self.oConso!.volConso = Float(strVolCarb)!
            }
			
			var type:String?
			
			switch self.typeParcours.selectedSegmentIndex
			{
			case 0:
				type = "Urbain"
			case 1:
				type = "Mixte"
			case 2:
				type = "Route"
			default:
				type = "Mixte"
				break
			}
			
			self.oConso?.typeParcours = type!
			
            if let textPrix = self.TextFieldPrixConso.text{
                let strPrixCarb = textPrix.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
				self.oConso!.prix = Float(strPrixCarb)!
            }
            
            if let textKM = self.TextFieldKilometrage.text{
				do{
					self.oConso!.carKilometrage = try Int(textKM)!
				}catch let error{
					let err = SCLAlertView()
					err.showError("Mauvais kilometrage", subTitle: "Veuillez saisir un kilométrage valide, entier!")
				}
            }
            if(self.TextFieldCoutLitre.text == ""){
                calculerCoutLitre()
            }
			self.oConso!.coutLitre = Float(self.TextFieldCoutLitre.text!)!
			
            if(self.TextFieldConsoCalculee.text == ""){
                calculerConso()
            }
			self.oConso!.conso = Float(self.TextFieldConsoCalculee.text!)!
			
            if let textCommentaire = self.TextFieldNotesConso.text{
				self.oConso!.commentaire = textCommentaire
            }
            
            if let textDateConso = self.TextFieldDateRavitaillement.text {
                let dateFormatter = DateFormatter()
                if(self.langue == "fr"){
                    let dateFormat = "dd/MM/yyyy"
                    dateFormatter.dateFormat = dateFormat
                }else{
                    let dateFormat = "MM/dd/yy"
                    dateFormatter.dateFormat = dateFormat
                }
                
                guard let dated = dateFormatter.date(from: textDateConso) else {
                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                }
				self.oConso!.dateConso = dated
            }
			self.oConso!.statusPlein = self.stPlein!
			self.oConso!.carName = (TextFieldCarPseudo?.text)!
			self.oConso!.idCar = (self.car?.idCar)!
			self.oConso!.car = self.car
			if(imageJustificatif.image !== nil){
				let imageJustif = self.imageJustificatif.image!.jpegData(compressionQuality: 0.9)
				self.oConso!.data = imageJustif as NSData?
			}
			let stationImage = NSData(data: self.imageViewStationService.image!.pngData()!)
            //station!.data = stationImage
			self.oConso!.stationImage = stationImage
            //let carObj = self.car
			
			/* Mise à jour de l'objet Station */
			self.station?.carburant = self.oConso!.typeCarburant
			//self.station?.marque = self.oConso!.nomStation
			self.station?.favori = false
			CWProgressHUD.show(withMessage: "Veuillez patienter...")
			if(self.station?.idStation == ""){
				
				let adresse = self.station?.adresse
				let codePostal = self.station?.codePostal.description
				let ville = self.station!.ville
				let address = adresse! + ", " + codePostal! + " " + ville
				self.getCoordinatesFromAddress(address: address, completion: {
					(statut) in
					if(statut == 1){
						print("coordonnées GPS OK")
						self.Validate() == true
					}else{
						let titreAdresseInvalide = NSLocalizedString("Adresse invalide", comment: "titreAdresseInvalide")
						let messageAdresseInvalide = NSLocalizedString("Vous avez saisi une adresse invalide. Veuillez vérifier et réessayez. N'hésitez pas à utiliser la fonction Recherche de station.", comment: "messageAdresseInvalide")
						SCLAlertView().showError(titreAdresseInvalide, subTitle: messageAdresseInvalide)
						self.Validate() == false
					}
				})
				
				searchStationId(marque: self.station!.marque, codePostal: self.station!.codePostal, ville: self.station!.ville, searchedLatitude: self.station!.latitude, searchedLongitude: self.station!.longitude, completion:{
						(status) in
						if(status == 2){
							self.insertData()
							self.updatePrice(
								completion: {
									(status) in
									if(status == 1){
										print("price updated")
									}
								}
							)
							return
						}
					}
				)
			}else{
				// idStation is known as well as address and city
				self.insertData()
				self.updatePrice(
					completion: {
						(status) in
						if(status == 1){
							print("price updated")
						}
				}
				)
			}
		}
    }
	
	func insertData(){
		let realm = try! Realm()
		self.station?.consos.append(self.oConso!)
		self.oConso!.idStation = self.station!.idStation
		let stationExistCount = realm.objects(Station.self).filter("idStation = %@",self.station!.idStation).count
		
		if( stationExistCount == 0){
			try! realm.write {
				realm.add(self.oConso!)
				realm.add(self.station!, update: .modified)
			}
		}else{
			try! realm.write {
				realm.add(self.oConso!)
			}
		}
		/*updatePrice(
			completion: {
				(status) in
				if(status == 1){
					print("price updated")
				}
		})*/
		
		CWProgressHUD.dismiss()
		/* Rafraichir la liste des voitures avant affichage */
		self.navigationController?.popViewController(animated: true)
		// A utiliser si le VC a été lancé par code en utilisant un navigation controller
		
		/* Notifier le rechargement de la liste après insertion dans bdd */
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
		return
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Récupération des prefs utilisateur */
        let settings = UserDefaults.standard
        self.settings = settings
        //self.localisationOK = false
		self.connected = false
        /* Initialisation de Realm */
        let realm = try! Realm()
        print("AddConsoViewController:realmInit")
        let idCar = settings.object(forKey: "idCar")
		let car = realm.objects(Car.self).filter("idCar = %@",idCar as Any).first
        self.car = car
		let energie = car?.energy
		self.listOfTypesCarburants = Array(realm.objects(typeCarburant.self).filter("Energie = %@",energie))
        self.listStations = Array(realm.objects(Station.self))
		self.listStationsFavorites = Array(realm.objects(Station.self).filter("favori = true"))
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
        self.TextFieldCodePostal?.text = station!.codePostal.description
		self.latitudeValue.text = station?.latitude.description
		self.longitudeValue.text = station?.longitude.description
        self.stPlein = true
        
        let carData = self.car!.data
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
        
        /*TextFieldStationService.delegate = self
        TextFieldStationService.tag = 4
        TextFieldStationService.returnKeyType = .next*/
        
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
	
	func searchStationId(marque: String, codePostal: Int, ville: String, searchedLatitude: Double, searchedLongitude: Double, completion: @escaping (Int)-> Void){
		let id = ""
		var statut = 0
		
		let coord = CLLocationCoordinate2D(latitude: searchedLatitude, longitude: searchedLongitude)
		
		/*Utility.checkInternetConnection(){
			(connected) in
			self.connected = connected
			if connected == true {*/
				let stationsRef = Database.database().reference().child("Stations").child("Fr").child(codePostal.description)
				stationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
					print(snapshot)
					
					if(snapshot.value is NSNull){
						// NO DATA
						print("– – – Data was not found – – –")
						completion(1)
						/*self.listeStations.removeAll()*/
						SCLAlertView().showError("Recherche invalide", subTitle: "Votre recherche n'a donné aucun résultat")
						CWProgressHUD.dismiss();statut = 1
					}else{
						for stationItem in snapshot.children {
							// DATA FOUND
							
							let station_snap = stationItem as! DataSnapshot
							let idStat = station_snap.key as! String
							let dict = station_snap.value as! NSDictionary
							
							let sLatitude = dict["latitude"] as! String
							let sLongitude = dict["longitude"] as! String
							let scodePostal = dict["codePostal"] as! String
							let sVille = dict["ville"] as! String
							let sAdresse = dict["adresse"] as! String
							
							/* On remplace les , par des . pour avoir une valeur type Float */
							let latitude = sLatitude.replacingOccurrences(of: ",", with: ".")
							let longitude = sLongitude.replacingOccurrences(of: ",", with: ".")
							
							
							let dSearchedLatitude = Double(self.station!.latitude)
							let dSearchedLongitude = Double(self.station!.longitude)
							
							/* Distance calculation */
							let locationSearchedStation = CLLocation(latitude: dSearchedLatitude, longitude: dSearchedLongitude)
							let locationCurrentStation = CLLocation(latitude: (latitude as NSString).doubleValue, longitude:(longitude as NSString).doubleValue)
							
							/* Distance from the center calculation */
							let rawDistance = (locationSearchedStation.distance(from: locationCurrentStation))/1000
							let distance = String(format: "%.2f", rawDistance)
							let FlDistance = Float(distance)
							let tolerance = Float(0.05)	// Tolerance de 50m
							print("distance = %@",distance)
							/*print("coord. station cherchée : %@",)
							print("coord. station de comparaison : %@",)*/
							if((FlDistance?.isLessThanOrEqualTo(tolerance))!) {
								print("station trouvée dans Firebase id = @%",idStat)
								self.station?.idStation = idStat
								completion(2)
								statut = 2
								CWProgressHUD.dismiss()
								return
							}else{
								print("station NOK")
								completion(3)
								statut = 3
							}
						}
						if(statut == 3){
							print("station non trouvée dans Firebase")
							statut = 4
							completion(4)
							self.createStation(station: self.station!, completion: {
								(statutInsertion) in
								
								if(statutInsertion == 1){
									print("station insertion OK")
								}
								if(statutInsertion == 0){
									print("erreur lors de l'insertion de la station")
								}
							})
							self.updatePrice(
								completion: {
									(status) in
									if(status == 1){
										print("price updated")
									}
							}
							)
							self.insertData()
							CWProgressHUD.dismiss()
						}
					}
				})
			/*}else{
				// Internet Connection NOK
			}
		}*/
	}
	func searchStationIdOld(marque: String, codePostal: Int, ville: String, searchedLatitude: Double, searchedLongitude: Double, completion: @escaping (Int)-> Void){
		let id = ""
		var statut = 0
		
		let coord = CLLocationCoordinate2D(latitude: searchedLatitude, longitude: searchedLongitude)
		let results = try! Realm()
			.objects(stationsBDD.self)
			.filterGeoRadius(center: coord, radius: 500, sortAscending: nil)
		
		
		let stationsRef = Database.database().reference().child("Stations").child("Fr").child(codePostal.description)
		stationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
			print(snapshot)
			
			if(snapshot.value is NSNull){
				// NO DATA
				print("– – – Data was not found – – –")
				completion(1)
				/*self.listeStations.removeAll()*/
				SCLAlertView().showError("Recherche invalide", subTitle: "Votre recherche n'a donné aucun résultat")
				CWProgressHUD.dismiss();statut = 1
			}else{
				for stationItem in snapshot.children {
					// DATA FOUND
					
					let station_snap = stationItem as! DataSnapshot
					let idStat = station_snap.key as! String
					let dict = station_snap.value as! NSDictionary
					
					let sLatitude = dict["latitude"] as! String
					let sLongitude = dict["longitude"] as! String
					let scodePostal = dict["codePostal"] as! String
					let sVille = dict["ville"] as! String
					let sAdresse = dict["adresse"] as! String
					
					/* On remplace les , par des . pour avoir une valeur type Float */
					let latitude = sLatitude.replacingOccurrences(of: ",", with: ".")
					let longitude = sLongitude.replacingOccurrences(of: ",", with: ".")
					
					
					let dSearchedLatitude = Double(self.station!.latitude)
					let dSearchedLongitude = Double(self.station!.longitude)
					
					/* Distance calculation */
					let locationSearchedStation = CLLocation(latitude: dSearchedLatitude, longitude: dSearchedLongitude)
					let locationCurrentStation = CLLocation(latitude: (latitude as NSString).doubleValue, longitude:(longitude as NSString).doubleValue)
					
					/* Distance from the center calculation */
					let rawDistance = (locationSearchedStation.distance(from: locationCurrentStation))/1000
					let distance = String(format: "%.2f", rawDistance)
					let FlDistance = Float(distance)
					let tolerance = Float(0.10)	// Tolerance de 100m
					print("distance = %@",distance)
					/*print("coord. station cherchée : %@",)
					print("coord. station de comparaison : %@",)*/
					if((FlDistance?.isLessThanOrEqualTo(tolerance))!) {
						print("station trouvée dans Firebase id = @%",idStat)
						self.station?.idStation = idStat
						
						self.updatePrice(
							completion: {
								(status) in
								if(status == 1){
									print("price updated")
								}
						})
						
						completion(2)
						statut = 2
						CWProgressHUD.dismiss()
						return
					}else{
						print("station NOK")
						completion(3)
						statut = 3
					}
				}
				if(statut == 3){
					print("station non trouvée dans Firebase")
					statut = 4
					completion(4)
					self.createStation(station: self.station!, completion: {
						(statutInsertion) in
						
						if(statutInsertion == 1){
							print("station insertion OK")
						}
						if(statutInsertion == 0){
							print("erreur lors de l'insertion de la station")
						}
					})
					self.updatePrice(
						completion: {
							(status) in
							if(status == 1){
								print("price updated")
							}
					}
					)
					CWProgressHUD.dismiss()
				}
			}
			/*if(statut == 0){
			completion(0)
			}else{
			print("station inexistante")
			self.createStation(station: self.station!)
			self.updatePrice(
			completion: {
			(status) in
			if(status == 1){
			print("price updated")
			}
			})
			completion(2)
			CWProgressHUD.dismiss()
			}*/
		})
	}
	func createStation(station: Station, completion: @escaping (Int)-> Void){
		print("Entrée dans createStation")
		let userID = UserDefaults.standard.string(forKey: "usrPseudo")
		createStationId()
		let tableStation = Database.database().reference().child("Stations").child("Fr").child((self.station!.codePostal).description)
		let stationsDisctionary : NSDictionary =
			[
				"id" : self.station!.idStation,
				"idStation" : self.station!.idStation,
				"nomStation" : self.station!.nomStation,
				"marque" : self.station!.marque,
				"latitude" : self.station!.latitude.description,
				"longitude" : self.station!.longitude.description,
				"adresse" : self.station!.adresse,
				"ville" : self.station!.ville,
				"codePostal" : self.station!.codePostal.description,
				"pays" : self.station!.pays,
				"commentaire" : self.station!.commentaire,
				"services" : self.station!.services,
				"modifiedAt" : getTimestamp(),
				"createdAt" : getTimestamp(),
				"verif" : 0,
				"DieselPlus_maj" : Utility.getUTCTimestamp(),
				"DieselPlus_prix" : 0.00,
				"DieselPlus_user" : userID,
				"DieselPlus_rupture" : "Non",
				"EssencePlus_maj" : Utility.getUTCTimestamp(),
				"EssencePlus_prix" : 0.00,
				"EssencePlus_user" : userID,
				"EssencePlus_rupture" : "Non",
				"E85_maj" : Utility.getUTCTimestamp(),
				"E85_prix" : 0.00,
				"E85_user" : userID,
				"E85_rupture" : "Non",
				"GNC_maj" : Utility.getUTCTimestamp(),
				"GNC_prix" : 0.00,
				"GNC_user" : userID,
				"GNC_rupture" : "Non",
				"GNL_maj" : Utility.getUTCTimestamp(),
				"GNL_prix" : 0.00,
				"GNL_user" : userID,
				"GNL_rupture" : "Non",
				"E10_maj" : Utility.getUTCTimestamp(),
				"E10_prix" : 0.00,
				"E10_user" : userID,
				"E10_rupture" : "Non",
				"SP95_maj" : Utility.getUTCTimestamp(),
				"SP95_prix" : 0.00,
				"SP95_user" : userID,
				"SP95_rupture" : "Non",
				"Gazole_maj" : Utility.getUTCTimestamp(),
				"Gazole_prix" : 0.00,
				"Gazole_user" : userID,
				"Gazole_rupture" : "Non",
				"SP98_maj" : Utility.getUTCTimestamp(),
				"SP98_prix" : 0.00,
				"SP98_user" : userID,
				"SP98_rupture" : "Non",
				"GPLc_maj" : Utility.getUTCTimestamp(),
				"GPLc_prix" : 0.00,
				"GPLc_user" : userID,
				"GPLc_rupture" : "Non"
		]
		
		tableStation.child(self.station!.idStation).setValue(stationsDisctionary) {
			(error, ref) in
			if error != nil {
				print(error!)
				completion(0)
			}
			else {
				print("Station insérée!")
				print("stationId = %@",ref.key)
				completion(1)
				self.updatePrice(
					completion: {
						(status) in
						if(status == 1){
							print("price updated")
						}
				})
			}
		}
	}
	
	func getLastMajDate(carburant: String, completion: @escaping (String)->Void){
		let dateMaj = ""
		let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal.description)!).child(self.station!.idStation)
		
		ref.observeSingleEvent(of: .value, with: { (snapshot) in
			print(snapshot)
			
			if(snapshot.value is NSNull){
				// NO DATA
				print("– – – Data was not found – – –")
				completion("")
				/*self.listeStations.removeAll()
				SCLAlertView().showError("Recherche invalide", subTitle: "Votre recherche n'a donné aucun résultat")
				CWProgressHUD.dismiss()*/
			}else{
				let snap = snapshot as! DataSnapshot
				let key = snap.key as! String
				let dict = snap.value as! NSDictionary
				let dateMaj = dict[carburant] as! String
				print("getLastMajDate = %@",dateMaj)
			}
		})
	}
	
	func updatePrice(completion: @escaping (Int)->Void){
		print("Entrée dans updatePrice")
		
		let status = 0
		
		let typeCarburant = self.station?.carburant
		let userID = UserDefaults.standard.string(forKey: "usrPseudo")
		
		calculerCoutLitre()
		let coutL = TextFieldCoutLitre?.text //Calcul du prix au litre
		
		var prixTypeCarb = ""
		var majTypeCarb = ""
		var userTypeCarb = ""
		
		switch typeCarburant {
		case "Supreme+ Sans Plomb 98":
			prixTypeCarb = "EssencePlus_prix"
			majTypeCarb = "EssencePlus_maj"
			userTypeCarb = "EssencePlus_user"
		case "Essence BP Ultimate SP98":
			prixTypeCarb = "EssencePlus_prix"
			majTypeCarb = "EssencePlus_maj"
			userTypeCarb = "EssencePlus_user"
		case "Essence Sans Plomb 98":
			prixTypeCarb = "SP98_prix"
			majTypeCarb = "SP98_maj"
			userTypeCarb = "SP98_user"
		case "Essence Sans Plomb 95":
			prixTypeCarb = "SP95_prix"
			majTypeCarb = "SP95_maj"
			userTypeCarb = "SP95_user"
		case "Essence Sans Plomb 95 E10":
			prixTypeCarb = "E10_prix"
			majTypeCarb = "E10_maj"
			userTypeCarb = "E10_user"
		case "Diesel Excellium":
			prixTypeCarb = "DieselPlus_prix"
			majTypeCarb = "DieselPlus_maj"
			userTypeCarb = "DieselPlus_user"
		case "Supreme+ Gazole":
			prixTypeCarb = "DieselPlus_prix"
			majTypeCarb = "DieselPlus_maj"
			userTypeCarb = "DieselPlus_user"
		case "Diesel":
			prixTypeCarb = "Gazole_prix"
			majTypeCarb = "Gazole_maj"
			userTypeCarb = "Gazole_user"
		case "Diesel Premier":
			prixTypeCarb = "Gazole_prix"
			majTypeCarb = "Gazole_maj"
			userTypeCarb = "Gazole_user"
		case "Superethanol E85":
			prixTypeCarb = "Ethanol_prix"
			majTypeCarb = "Ethanol_maj"
			userTypeCarb = "Ethanol_user"
		case "FlexFuel":
			prixTypeCarb = "FlexFuel_prix"
			majTypeCarb = "FlexFuel_maj"
			userTypeCarb = "FlexFuel_user"
		case "GPL-c":
			prixTypeCarb = "GPLc_prix"
			majTypeCarb = "GPLc_maj"
			userTypeCarb = "GPLc_user"
		case "GPL-c":
			prixTypeCarb = "GNC_prix"
			majTypeCarb = "GNC_maj"
			userTypeCarb = "GNC_user"
		case "GPL-c":
			prixTypeCarb = "GNL_prix"
			majTypeCarb = "GNL_maj"
			userTypeCarb = "GNL_user"
		default:
			prixTypeCarb = "EssencePlus_prix"
			majTypeCarb = "EssencePlus_maj"
			userTypeCarb = "EssencePlus_user"
		}
		
		var formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		
		let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description)
		ref.child(self.station!.idStation).updateChildValues([prixTypeCarb: coutL])
		ref.child(self.station!.idStation).updateChildValues([majTypeCarb: Utility.getUTCTimestamp()])
		ref.child(self.station!.idStation).updateChildValues([userTypeCarb: userID])
		completion(1)
		
		/*getLastMajDate(carburant: majTypeCarb, completion: {
			(lastDate) in
			if(lastDate != ""){
				
				var formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
				
				let lastMajDate = formatter.date(from: lastDate) as! Date
				let strConsoDate = formatter.string(from: self.oConso!.dateConso)
				let consoDate = formatter.date(from: strConsoDate) as! Date
				
				print(lastDate)
				
				if(consoDate > lastMajDate){
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description)
					ref.child(self.station!.idStation).updateChildValues([prixTypeCarb: coutL])
					ref.child(self.station!.idStation).updateChildValues([majTypeCarb: self.getUTCTimestamp()])
					ref.child(self.station!.idStation).updateChildValues([userTypeCarb: userID])
					completion(1)
				}
			}else{
				print("lastDate not found")
			}
		})*/
		
	}
    func setupBasicStationsPopover(for sender: UIView) {
        // Init a popover with a callback closure after selecting data
        let popover = LCPopover<Int>(for: sender, title: "Stations favorites") {
			tuple in
            // Use of the selected tuple
            guard let value = tuple?.value else { return }
			if self.btnStationName.title(for: .normal) != nil {
                // Update the list of pokemons based on the input
                let stationArray = value.components(separatedBy: " - ")
                self.btnStationName.setTitle(stationArray[0], for: .normal)
                self.TextFieldStationServiceAdresse.text = stationArray[1]
                self.TextFieldCodePostal.text = stationArray[2]
                self.TextFieldStationServiceCPVille.text = stationArray[3]
            }
            print(value)
        }
        var compteur:Int = 0
        for station in self.listStationsFavorites {
            compteur = compteur + 1
            let id = station.idStation
            let name = station.nomStation + " - " + station.adresse + " - " + station.codePostal.description + " - " + station.ville
            self.stationsList.append((compteur,name))
            print(name) //prints and empty string
        }
		
        // Assign data to the dataList
        popover.dataList = self.stationsList as! [(key: Int, value: String)]
		
        /* Personnalisation du popover */
        // Set popover properties
        popover.size = CGSize(width: 300, height: 219)
        popover.arrowDirection = .down
        popover.backgroundColor = .orange
        popover.borderColor = .lightGray
        popover.borderWidth = 2
        popover.barHeight = 40
        popover.titleFont = UIFont.boldSystemFont(ofSize: 17)
        popover.titleColor = .red
        popover.textFont = UIFont(name: "HelveticaNeue-SmallItalic", size: 13) ?? UIFont.systemFont(ofSize: 13)
        popover.textColor = .black
        // Present the popover
        present(popover, animated: true, completion: nil)
    }
	func stationSelected(data: stationObject)
	{
		print("Station received: \(String(describing: data.nom))")
		
		self.btnStationName.setTitle(data.marque, for: .normal)
		self.TextFieldStationServiceCPVille.text = data.ville
		self.TextFieldCodePostal.text = data.codePostal
		self.TextFieldStationServiceAdresse.text = data.adresse
		self.longitudeValue.text = data.longitude.description
		self.latitudeValue.text = data.latitude.description
		let nomImage = data.marque.uppercased()
		
		print("Recherche de " + nomImage)
		if (UIImage(named: nomImage) != nil) {
			print("Image station existing")
			self.imageViewStationService.image = UIImage(named: nomImage)
		}
		else {
			print("Image station is not existing")
			self.imageViewStationService.image = UIImage(named: "icon_fuels")
		}
		
		self.station?.idStation = data.idStation
		self.station?.nomStation = data.nom
		self.station?.marque = data.marque
		self.station?.adresse = data.adresse
		self.station?.latitude = data.latitude
		self.station?.longitude = data.longitude
	}
	
	func getCoordinatesFromAddress(address:String, completion: @escaping (Int)->Void){
		/**/
		print("getCoordinatesFromAddress: Address = %@",address)
		let geoCoder = CLGeocoder()
		geoCoder.geocodeAddressString(address) { (placemarks, error) in
			guard
				let placemarks = placemarks,
				let location = placemarks.first?.location
				else {
					// handle no location found
					completion(0)
					return
			}
			let latitude = location.coordinate.latitude
			let longitude = location.coordinate.longitude
			print("latitude = %@",latitude)
			print("longitude = %@",longitude)
			self.station?.latitude = latitude
			self.station?.longitude = longitude
			
			completion(1)
			// Use your location
		}
	}
    
    func saveImageToAppFolder(image: UIImage){
        
        let fileStr = "AutoConso/" + idConso + ".jpeg"
        
        
        print("saveImageToAppFolder", fileStr)
		if let data = image.jpegData(compressionQuality: 1.0),
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
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        let chemin = self.appDirPath + "/" + self.idConso + ".jpeg"
        let fd = open(chemin, O_WRONLY|O_CREAT, 0o666)
        
        let titreDossierAutoConsoInexistant = NSLocalizedString("Oups !", comment: "titreDossierAutoConsoInexistant")
        let messageDossierAutoConsoInexistant = NSLocalizedString("La fonction aperçu est indisponible pour le moment.", comment: "messageDossierAutoConsoInexistant")
        
        if fd < 0 {
            perror("could not open " + chemin)
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let previewPhotoUnavailable = SCLAlertView(appearance: appearance)
            
            previewPhotoUnavailable.addButton("OK"){
                    //self.dismiss(animated: true)
            }
            previewPhotoUnavailable.showInfo(titreDossierAutoConsoInexistant, subTitle: messageDossierAutoConsoInexistant)
        
        } else {
            print("fichier ouvert!")
        }
        // Your action
    }
	
	func getCurrentCoordinates(completion: @escaping (Int)-> Void){
		var currentLocation: CLLocation!
		var locManager = CLLocationManager()
		
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		
		if(self.locationManager.location != nil){
			currentLocation = self.locationManager.location
			self.locationManager.stopUpdatingLocation()
			self.coordGPS = currentLocation
		}
		
	}
	
	func getTimestamp() -> String {
		let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
		return timestamp
	}
	func getDate() -> String {
		let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: .none)
		return timestamp
	}
	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
	{
		manager.stopUpdatingLocation()
		//--- CLGeocode to get address of current location ---//
		CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
			
			if (error != nil)
			{
				print("Reverse geocoder failed with error" + error!.localizedDescription)
				return
			}
			
			if placemarks!.count > 0
			{
				let pm = placemarks![0] as CLPlacemark
				print(pm)
			}
			else
			{
				print("Problem with the data received from geocoder")
			}
		})
		
	}
	
	func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
	{
		print("Error while updating location " + error.localizedDescription)
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
                selectedCarburant = listOfTypesCarburants[row].NomCarburant
                print("carburant = "+listOfTypesCarburants[row].NomCarburant)
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
                print("selected carburant is "+listOfTypesCarburants[row].NomCarburant)
                TextFieldTypeCarburant?.text = listOfTypesCarburants[row].NomCarburant
				let carbData = self.listOfTypesCarburants[row].imageOperation
				let carbImage = UIImage(data: carbData! as Data)
				imageViewTypeCarburant.image = carbImage
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
            let carName = self.TextFieldCarPseudo.text
            let station = Station.self
            let vc = segue.destination as? StationsSearchTableViewController
			
            var searchedStation = self.btnStationName.title(for: .normal)
            var searchedAddress = self.TextFieldStationServiceAdresse.text!
			var searchedVille = self.TextFieldStationServiceCPVille.text!
			var searchedCP = self.TextFieldCodePostal.text!
			
			searchString = searchedStation!
				
            print("searchString",searchString)
            self.oConso = Conso()
            self.oConso?.carName = (self.TextFieldCarPseudo?.text)!
            
            /* Envoi de la recherche */
            vc!.senderVC = "AddConsoVC"
            vc!.stationName = searchedStation
			vc!.searchedAddress = searchedAddress
            vc!.searchedVille = searchedVille
			vc!.searchedCP = searchedCP
            vc!.searchString = searchString
            vc!.carName = carName
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
            if(TextFieldKilometrage?.text != nil){
                if(self.listConso.count > 0){
					let realm = try! Realm()
                    if let lastKM = realm.objects(Conso.self).sorted(byKeyPath: "dateConso").last?.carKilometrage {
                        var KMcalc:Int = Int((TextFieldKilometrage?.text)!)!  - lastKM
                        TextFieldDistanceParcourue?.text = KMcalc.description
                    }else{
                        var KMcalc:Int = 0
                        TextFieldDistanceParcourue?.text = ""
                    }
                }
            }
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
        self.TextFieldCodePostal?.text = station.codePostal.description
        
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
	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
	{
		var label:UILabel
		if let v = view as? UILabel{
			label = v
		}
		else{
			label = UILabel()
		}
		label.textColor = UIColor.red
		label.textAlignment = .left
		label.font = UIFont(name: "Helvetica-Neue", size: 18)
		label.text = self.listOfTypesCarburants[row].NomCarburant
		return label
	}
    
    @objc func doneCarburantClick() {
        TextFieldTypeCarburant.resignFirstResponder()
    }
    @objc func cancelCarburantClick() {
        TextFieldTypeCarburant.resignFirstResponder()
    }
    
    func calculerConso(){
        
        /* Popup d'erreur de calcul conso */
        
        let titreDonneeManquante = NSLocalizedString("Donnée manquante", comment: "titreDonneeManquante")
        let messageDonneeManquante = NSLocalizedString("L'un des champs 'volume carburant' ou 'kilomètres parcouru' est vide. La conso ne peut être calculée.", comment: "messageDonneeManquante")
        let buttonOK = NSLocalizedString("OK", comment: "buttonOK")
        
        
        
        if((!(TextFieldDistanceParcourue.text?.isEmpty)!)&&(!(TextFieldVolumeCarburant.text?.isEmpty)!)){
            
            let flVolume: Float? = Float(self.TextFieldVolumeCarburant.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
            let flkm: Float? = Float(self.TextFieldDistanceParcourue.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
            let consobrut = 100.00 * ( flVolume! / flkm! )
            
            let conso = (consobrut * 100).rounded() / 100
            
            print("conso = "+conso.description)
            TextFieldConsoCalculee?.text = conso.description
			self.oConso?.conso = conso
            
        }else if((TextFieldDistanceParcourue.text?.isEmpty)!){
            SweetAlert().showAlert(titreDonneeManquante, subTitle: messageDonneeManquante, style: AlertStyle.error, buttonTitle:buttonOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    
                    print("Cancel Button  Pressed")
                    
                }else {
                    print("L'utilisateur a décidé de supprimer une ligne de conso")
                }
            }
        }else if((TextFieldVolumeCarburant.text?.isEmpty)!){
            SweetAlert().showAlert(titreDonneeManquante, subTitle: messageDonneeManquante, style: AlertStyle.error, buttonTitle:buttonOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    
                    print("Cancel Button  Pressed")
                    
                }else {
                    print("L'utilisateur a décidé de supprimer une ligne de conso")
                }
            }
        }
        
        
        
    }
    
    func calculerCoutLitre(){
        
		/* Popup d'erreur de calcul du cout au litre */
		let titreDonneeManquante = NSLocalizedString("Donnée manquante", comment: "titreDonneeManquante")
		let messageDonneeManquante = NSLocalizedString("L'un des champs 'volume carburant' ou 'kilomètres parcouru' est vide. La conso ne peut être calculée.", comment: "messageDonneeManquante")
		let buttonOK = NSLocalizedString("OK", comment: "buttonOK")
		
        
        if((!(TextFieldPrixConso.text?.isEmpty)!)&&(!(TextFieldVolumeCarburant.text?.isEmpty)!)){

            let flVolume: Float? = Float(self.TextFieldVolumeCarburant.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
            let flprix: Float? = Float(self.TextFieldPrixConso.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
            let coutLBrut = ( flprix! / flVolume! )
            let roundCoutL = (coutLBrut * 100).rounded()/100
            print("coutL = "+roundCoutL.description)
            TextFieldCoutLitre?.text = roundCoutL.description
			//self.oConso?.coutLitre = roundCoutL
            
        }else if((TextFieldPrixConso.text?.isEmpty)!){
			
			
			SweetAlert().showAlert(titreDonneeManquante, subTitle: messageDonneeManquante, style: AlertStyle.error, buttonTitle:buttonOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0)) { (isOtherButton) -> Void in
				if isOtherButton == true {
					
					print("Cancel Button  Pressed")
					
				}else {
					print("L'utilisateur a décidé de supprimer une ligne de conso")
				}
			}
        }else if((TextFieldVolumeCarburant.text?.isEmpty)!){
			SweetAlert().showAlert(titreDonneeManquante, subTitle: messageDonneeManquante, style: AlertStyle.error, buttonTitle:buttonOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0)) { (isOtherButton) -> Void in
				if isOtherButton == true {
					
					print("Cancel Button  Pressed")
					
				}else {
					print("L'utilisateur a décidé de supprimer une ligne de conso")
				}
			}
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
		let warnDateVide = NSLocalizedString("Veuillez sélectionner une date", comment: "warnDateVide")
        
        if TextFieldCarPseudo.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldCarPseudo if
			TextFieldCarPseudo.attributedPlaceholder = NSAttributedString(string: warnSelectCar, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldCarPseudo)
        }
        /*if TextFieldStationService.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldStationService if
			TextFieldStationService.attributedPlaceholder = NSAttributedString(string: warnSelectFuelStation, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{*/
            //self.AnimationShakeTextField(textField: TextFieldStationService)
        //}
        if TextFieldKilometrage.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldKilometrage if
			TextFieldKilometrage.attributedPlaceholder = NSAttributedString(string: warnPromptKM, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldKilometrage)
        }
        if TextFieldDistanceParcourue.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
			TextFieldDistanceParcourue.attributedPlaceholder = NSAttributedString(string: errorCoveredDistance, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldDistanceParcourue)
        }
        if TextFieldVolumeCarburant.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldDistanceParcourue if
			TextFieldVolumeCarburant.attributedPlaceholder = NSAttributedString(string: warnIncorrectCarburant, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldVolumeCarburant)
        }
        if TextFieldPrixConso.text!.isEmpty {
            //Change the placeholder color to red for textfield TextFieldPrixConso if
			TextFieldPrixConso.attributedPlaceholder = NSAttributedString(string: warnPrixIncorrect, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            self.AnimationShakeTextField(textField: TextFieldPrixConso)
        }
		if TextFieldDateRavitaillement.text!.isEmpty{
			TextFieldDateRavitaillement.attributedPlaceholder = NSAttributedString(string: warnDateVide, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
			valid = false
		}else{
			self.AnimationShakeTextField(textField: TextFieldDateRavitaillement)
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
		self.station!.idStation = "Station-" + dateFormatter.string(from: Date())
    }
	
	
	/* Firebase */
	
	func firebaseUpdate(){
		let tableStation = Database.database().reference().child("Stations")
		
		let stationsDisctionary : NSDictionary =
		[
			"id" : self.station?.idStation,
			"nomStation" : self.station?.nomStation,
			"marque" : self.station?.marque,
			"coordGPS" : self.station?.coordGPS,
			"typeRoute" : self.station?.typeRoute,
			"adresse" : self.station?.adresse,
			"ville" : self.station?.ville,
			"codePostal" : self.station?.codePostal,
			"pays" : self.station?.pays,
			"heureDebut" : self.station!.heureDebut,
			"heureFin" : self.station!.heureFin,
			"commentaire" : self.station!.commentaire,
			"SP95" : 0.00,
			"SP95 E10" : 0.00,
			"SP98" : 0.00,
			"SP98 +" : 0.00,
			"SUPER" : 0.00,
			"GAZOLE" : 0.00,
			"DIESEL +" : 0.00,
			"GPL" : 0.00,
			"saufJour" : self.station!.saufJour,
			"services" : self.station!.services,
			"modifiedAt" : getTimestamp(),
			"createdAt" : self.TextFieldDateRavitaillement.text
		]
		
		tableStation.childByAutoId().setValue(stationsDisctionary) {
			(error, ref) in
			if error != nil {
				print(error!)
			}
			else {
				print("Station saved successfully!")
				print("stationId = %@",ref.key)
			}
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
	
	// Vérification des autorisations GPS
	func checkUsersLocationServicesAuthorization(){
		/// Check if user has authorized Total Plus to use Location Services
		//if CLLocationManager.locationServicesEnabled() {
		let titleEnableGPS = NSLocalizedString("Autorisation GPS", comment: "titleEnableGPS")
		let messageEnableGPS = NSLocalizedString("L'app AutoConso a besoin d'accéder à votre localisation. Activer les permissions de localisation dans le menu Réglages de votre iPhone", comment: "messageEnableGPS")
		let settingsButton = NSLocalizedString("Réglages", comment: "settingsButton")
		
		switch CLLocationManager.authorizationStatus() {
				
			case .notDetermined:
				// Request when-in-use authorization initially
				// This is the first and the ONLY time you will be able to ask the user for permission
				self.locationManager.delegate = self
				locationManager.requestWhenInUseAuthorization()
				self.localisationOK = false
				break
				
			case .restricted, .denied:
				// Disable location features
				//switchAutoTaxDetection.isOn = false
				
				SweetAlert().showAlert(titleEnableGPS, subTitle: messageEnableGPS, style: AlertStyle.customImage(imageFile: "icon_location"), buttonTitle:settingsButton, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0))
			{ action in
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
					return
				}
				if UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
						print("Settings opened: \(success)")
					})
				}
					
			}
				
			break
				
		case .authorizedWhenInUse, .authorizedAlways:
			// Enable features that require aaaation services here.
			print("Full Access")
			self.localisationOK = true
			ProgressBarNotification.removeProgressBar()
			break
		}
	}
	func getLastRecordDateInStation(){
		let stationsRef = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal.description)!).child((self.station?.idStation.description)!)
		stationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
			print(snapshot)
		})
	}
	
	
}
