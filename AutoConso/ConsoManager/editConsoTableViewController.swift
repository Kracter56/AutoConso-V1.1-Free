//
//  editConsoTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 01/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView

class editConsoTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var consoItem: Conso!
    var carItem: Car!
    var realm:Realm?
    var station:Station?
    var source:String?
    var PickerViewCar : UIPickerView!
    var selectedCar:Car?
    var listOfCars:[Car] = []
    var data:Results<Car>!
	var langue = ""
	var appDirPath = ""
    
    @IBOutlet weak var carImmat: UILabel!
    @IBOutlet weak var labelMarqueModele: UILabel!
    @IBOutlet weak var labelPseudo: UILabel!
    @IBOutlet weak var imageVehicle: UIImageView!
    
    @IBOutlet weak var editFieldNomStation: UITextField!
    @IBOutlet weak var editFieldStationAdresse: UITextField!
    @IBOutlet weak var editFieldCP: UITextField!
    @IBOutlet weak var editFieldStationVille: UITextField!
    @IBOutlet weak var imageStation: UIImageView!
    
    @IBOutlet weak var editFieldDateConso: UITextField!
    @IBOutlet weak var editFieldCarburant: UITextField!
    @IBOutlet weak var editFieldVolumeCarburant: UITextField!
    
    @IBOutlet weak var editFieldKilometrage: UITextField!
    @IBOutlet weak var editFieldKmParcourus: UITextField!
    
    @IBOutlet weak var editFieldNotes: UITextField!
	@IBOutlet weak var btnSearch: UIButton!
	
    
    @IBOutlet weak var imageJustificatif: UIImageView!
    @IBAction func ButtonChooseImage(_ sender: Any) {
        PhotoChooser.shared.showAttachmentActionSheet(vc: self)
        PhotoChooser.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.imageJustificatif.image = image
            self.saveImageToAppFolder(image: image)
            
        }
    }
	@IBAction func btnSearchStation(_ sender: UIButton) {
	}
	
    func saveImageToAppFolder(image: UIImage){
        
        let fileStr = "AutoConso/" + self.consoItem.idConso + ".jpeg"
        
        
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

    @IBAction func btnFermer(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var pickerViewCarSelection: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("editConsoTableViewController:realmInit")
        
        if(self.source == "StationsVC"){
            /* Si la source de ce ViewController est StationsVC, supprimer ce VC de la mémoire */
            //let VCCount = self.navigationController!.viewControllers.count
            self.navigationController?.viewControllers.remove(at: self.navigationController!.viewControllers.count - 2)
        }
        
        let realm = try! Realm()
        
        /* Definition des sources du PickerView */
        self.pickerViewCarSelection.dataSource = self
        self.pickerViewCarSelection.delegate = self
        
        /* Constitution de la liste de voitures pour alimenter le PickerView  */
        self.data = realm.objects(Car.self)
        self.listOfCars = Array(self.data)
        
        let carItem = realm.objects(Car.self).filter("pseudo LIKE %@",consoItem.carName).first
        
        print("Reception de " + consoItem.idConso)
        let vehicle = carItem?.type
        
        if(vehicle == "SCOOTER"){
            imageVehicle?.image = UIImage(named: "icon_scooter")
        }
        if(vehicle == "MOTO"){
            imageVehicle?.image = UIImage(named: "icon_moto")
        }
        if(vehicle == "VOITURE"){
            imageVehicle?.image = UIImage(named: "3Dcar")
        }
        
        labelPseudo?.text = consoItem.carName
        labelMarqueModele?.text = (carItem?.marque)! + " " + (carItem?.modele)!
		
		self.btnSearch.isHidden = true
		
		getStationById()
		
        if(self.station == nil){
            editFieldNomStation?.text = consoItem.station?.marque
            editFieldStationAdresse?.text = consoItem.adresseStation
            editFieldCP?.text = consoItem.CPStation.description
            editFieldStationVille?.text = consoItem.villeStation
        }else{
            editFieldNomStation?.text = self.station?.marque
            editFieldStationAdresse?.text = self.station?.adresse
            editFieldCP?.text = self.station?.codePostal.description
            editFieldStationVille?.text = self.station?.ville
        }
		
		self.editFieldNomStation.isEnabled = false
		
        
        let nomStation = self.station?.marque
		let upperNomStation = nomStation?.uppercased()
		if (UIImage(named: upperNomStation!) != nil) {
            print("Image station existing")
			imageStation.image = UIImage(named: upperNomStation!)
        }else{
            print("Image station is not existing")
            imageStation.image = UIImage(named: "icon_fuel_3D")
        }
		
		if consoItem.data !== nil {
			let consoJustif = UIImage(data: consoItem.data! as Data)
			imageJustificatif.image = consoJustif
		}
        
        editFieldCarburant?.text = consoItem.typeCarburant
        editFieldVolumeCarburant?.text = consoItem.volConso.description
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        editFieldDateConso?.text = formatter.string(from: consoItem.dateConso)
        //labelMarqueModele?.text = (consoItem.car?.marque)! + " " + (consoItem.car?.modele)!
        editFieldKilometrage?.text = consoItem.carKilometrage.description
        editFieldKmParcourus?.text = consoItem.carKmParcourus.description
        editFieldNotes?.text = consoItem.commentaire
		
		/* récupération de la langue de l'iphone */
		self.langue = UserDefaults.standard.string(forKey: "phoneLanguage")!
		self.appDirPath = UserDefaults.standard.string(forKey: "appFolder")!
		
		/* On assigne un évenement tap au justificatif */
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
		imageJustificatif.isUserInteractionEnabled = true
		imageJustificatif.addGestureRecognizer(tapGestureRecognizer)
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func btnEnregistrer(_ sender: UIBarButtonItem) {
        let realm = try! Realm()
        let dateFormatter = DateFormatter()
        let dateFormat = "dd/MM/yyyy"
        dateFormatter.dateFormat = dateFormat
        let dateConso = dateFormatter.date(from: (editFieldDateConso?.text)!)
        
        let idConso = consoItem.idConso
        
        let conso = realm.objects(Conso.self).filter("idConso LIKE %@",idConso).first
            
        try! realm.write {
            conso?.nomStation = (editFieldNomStation?.text)!
            conso?.adresseStation = (editFieldStationAdresse?.text)!
            conso?.CPStation = (editFieldCP?.text)!
            conso?.villeStation = ((editFieldStationVille?.text)!)
            
            conso?.typeCarburant = (editFieldCarburant?.text)!
            //conso?.volConso = Float(editFieldVolumeCarburant?.text)!
            
            conso!.dateConso = dateConso!
            conso?.carKilometrage = Int((editFieldKilometrage?.text)!)!
            //conso?.carKmParcourus = Float(editFieldKmParcourus?.text)!
            
            conso?.commentaire = (editFieldNotes?.text)!
            conso?.car = selectedCar
			
			if(imageJustificatif.image != nil){
				let imageData = imageJustificatif.image!.jpegData(compressionQuality: 0.9)
				conso?.data = imageData as NSData?
			}
			
            
            /* Ajouter le justificatif dans la base de données */
			realm.add(conso!, update: .modified)
        }
        
        //self.toastMessage("La voiture "+(carItem.modele)+" a bien été modifiée")
        /* Si la source de ce ViewController est StationsVC, supprimer ce VC de la mémoire */
        let VCCount = self.navigationController!.viewControllers.count
        print("VCCount",VCCount)
        self.navigationController?.viewControllers.remove(at: VCCount - 1)
        
        /* Rafraichir la liste des voitures avant affichage */
        self.navigationController?.popViewController(animated: true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is StationsSearchTableViewController
        {
            /* On créer l'id de la station à sélectionner */
            //createStationId()
            let station = Station.self
            
            var searchString = self.editFieldNomStation.text!
            
            if(self.editFieldCP.text != nil){
                searchString = searchString + ", " + self.editFieldCP.text!
            }else{
                if(self.editFieldStationVille.text != nil){
                    searchString = searchString + ", " + self.editFieldStationVille.text!
                }
            }
            
            let vc = segue.destination as? StationsSearchTableViewController
            print("searchString",searchString)
            /* Envoi de la recherche */
            vc!.stationName = self.editFieldNomStation.text!
            vc!.stationVille = self.editFieldStationVille.text!
            vc!.searchString = searchString
            vc!.car = self.carItem
            vc!.oConso = self.consoItem
            //vc?.addConsoVC = self // Je lie les 2 viewControllers pour que quand je sélectionne une donnée de vc, je puisse appeler une fonction de addConso
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.listOfCars.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("pseudo = "+self.listOfCars[row].pseudo)
        return self.listOfCars[row].pseudo
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("selected Car is "+self.listOfCars[row].pseudo)
        let selectedCarName = self.listOfCars[row].pseudo
        let realm = try! Realm()
        let car = realm.objects(Car.self).filter("pseudo LIKE %@",selectedCarName).first
        print("idCar = ",car?.idCar)
        print("marque = ",car?.marque)
        print("modele = ",car!.modele)
        print("immat = ",car!.immatriculation)
        print("kilometrage = ",car!.kilometrage)
        
        let carMarque = realm.objects(Car.self).filter("pseudo LIKE %@",selectedCarName).first?.marque
        let carModele = realm.objects(Car.self).filter("pseudo LIKE %@",selectedCarName).first?.modele
        let immatriculation = realm.objects(Car.self).filter("pseudo LIKE %@",selectedCarName).first?.immatriculation
        let carMarqueModele = car!.marque + " " + car!.modele
        let carImage = UIImage(data: car!.data! as Data)
        
        print("carMarqueModele", carMarqueModele)
        labelMarqueModele?.text = carMarqueModele
        carImmat?.text = car?.immatriculation
        imageVehicle.image = carImage
        self.selectedCar = car
    }
    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }*/

    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	func getStationById()
	{
		let realm = try! Realm()
		self.station = realm.objects(Station.self).filter("idStation LIKE %@",self.consoItem.idStation).first
	}
	
	/* Fonction appelée quand l'utilisateur clique sur la photo */
	@objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
	{
		let imageView = self.imageJustificatif
		let newImageView = UIImageView(image: imageView!.image)
		newImageView.frame = UIScreen.main.bounds
		newImageView.backgroundColor = .black
		newImageView.contentMode = .scaleAspectFit
		newImageView.isUserInteractionEnabled = true
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
		newImageView.addGestureRecognizer(tap)
		self.view.addSubview(newImageView)
		self.navigationController?.isNavigationBarHidden = true
		self.tabBarController?.tabBar.isHidden = true
		// Your action
		
	}
	
	@objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
		self.navigationController?.isNavigationBarHidden = false
		self.tabBarController?.tabBar.isHidden = false
		sender.view?.removeFromSuperview()
	}
}
