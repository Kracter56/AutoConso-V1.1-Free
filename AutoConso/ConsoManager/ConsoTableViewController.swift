//
//  ConsoTableViewController.swift
//  AutoConso-v0
//
//  Created by Edgar PETRUS on 19/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import Foundation

class ConsoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    var realm:Realm?
    var bannerView: GADBannerView!
    var pseudo = ""
    var consosData:Results<Conso>!
    var carsData:Results<Car>!
    var consos:[Conso] = []
    var cars:[Car] = []
    var car:Car?
    var idCar:String?
    
    @IBOutlet weak var tableViewConso: UITableView!
    @IBOutlet weak var btnAddConso: UIBarButtonItem!
	var langue = ""
    
    /*func listConsoOld(){
        let realm = try! Realm()
        self.data = realm.objects(Conso.self).sorted(byKeyPath: "dateConso", ascending: false)
        self.consos = Array(self.data)
        self.carsData = realm.objects(Car.self)
        self.cars = Array(self.carsData)
        self.tableViewConso.setEditing(false, animated: true)
        self.tableViewConso.reloadData()
        print("listConsoOld")
    }*/
    func listConso(){
        let realm = try! Realm()
        self.car = realm.objects(Car.self).filter("idCar = %@",self.idCar).first
        self.consosData = realm.objects(Conso.self).filter("idCar = %@",self.idCar).sorted(byKeyPath: "dateConso", ascending: false)
        //self.consosData = realm.objects(Car.self).filter("idCar = %@",self.idCar).first?.consos.sorted(byKeyPath: "dateConso", ascending: false)
        self.consos = Array((self.consosData)!)
        self.carsData = realm.objects(Car.self)
        self.cars = Array(self.carsData)
        
        self.tableViewConso.setEditing(false, animated: true)
        self.tableViewConso.reloadData()
        print("listConsop")
    }
    @IBAction func btnAddConso(_ sender: Any) {
        //listConso()
        let VC = storyboard?.instantiateViewController(withIdentifier: "addConso") as! AddConsoViewController
        VC.car = self.car
        navigationController?.pushViewController(VC, animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ConsoTableViewController:realmInit")
        let realm = try! Realm()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8249099547869316~4988744906")
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
		
        /*self.trajetUrbain.isHidden = true
		self.trajetMixte.isHidden = true
		self.trajetRoutier.isHidden = true*/
		
        bannerView.adUnitID = "ca-app-pub-8249099547869316/5778124533"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        bannerView.delegate = self
        
        print("Realm DB : \(Realm.Configuration.defaultConfiguration.fileURL!)")
        listConso()
        
        self.langue = UserDefaults.standard.string(forKey: "phoneLanguage")!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // In this case, we instantiate the banner with desired ad size.
        
        
        if self.consos.count == 0 {
            let noConsoMessage = NSLocalizedString("Vous n'avez pas encore saisi de ticket", comment: "noConsoMessage")
            self.tableViewConso.setEmptyMessage(noConsoMessage)
        } else {
            self.tableViewConso.restore()
        }
        
        print("cars = ",self.cars.count)
        if self.cars.count == 0 {
            self.btnAddConso.isEnabled = false
            //alertAddCar()
            
        } else {
            self.btnAddConso.isEnabled = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadView), name: NSNotification.Name(rawValue: "loadList"), object: nil)
    }
    
    /* Création d'une bannière de pub dans l'app */
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func animateTable() {
        self.tableViewConso.reloadData()
        
        let cells = tableViewConso.visibleCells
        let tableHeight: CGFloat = tableViewConso.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
	
	/*static func makeMoveUpWithFade(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
		return { cell, indexPath, _ in
			cell.transform = CGAffineTransform(translationX: 0, y: rowHeight / 2)
			cell.alpha = 0
			
			UIView.animate(
				withDuration: duration,
				delay: delayFactor * Double(indexPath.row),
				options: [.curveEaseInOut],
				animations: {
					cell.transform = CGAffineTransform(translationX: 0, y: 0)
					cell.alpha = 1
			})
		}
	}*/
    
    /* Fonction qui donne le mois et l'année à partir d'une date */
    fileprivate func firstDayOfMonth(date : Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    func loadList(notification: NSNotification){
        //load data here
        print("loadList")
        //listConso()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1 //self.cars.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        self.pseudo = self.cars[section].pseudo
        
        print("conso = ",self.consos.count)
        
        
        if self.consos.count == 0 {
            let noConsoMessage = NSLocalizedString("Vous n'avez pas encore saisi de ravitaillement", comment: "noConsoMessage")
            
            self.tableViewConso.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.tableViewConso.setEmptyMessage(noConsoMessage)
                self.tableViewConso.fadeIn()
            })
            
            
        } else {
            self.tableViewConso.restore()
        }
        
        print("cars = ",self.cars.count)
        if self.cars.count == 0 {
            self.btnAddConso.isEnabled = false
            alertAddCar()
            
        } else {
            self.btnAddConso.isEnabled = true
        }
        
        return self.consos.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConsoCell", for: indexPath) as! ConsoTableViewCell

        var currencyUnit = "€"
        var distanceUnit = "km"
        var volumeUnit = "L"
        
        let userSettings = UserDefaults.standard
        // Configure the cell...
        if(settingsDataAlreadyExist(Key: "devise")){
            currencyUnit = userSettings.object(forKey: "devise") as! String
        }
        if(settingsDataAlreadyExist(Key: "distance")){
            distanceUnit = userSettings.object(forKey: "distance") as! String
        }
        if(settingsDataAlreadyExist(Key: "volume")){
            volumeUnit = userSettings.object(forKey: "volume") as! String
        }
        
            
        cell.textFieldStationService?.text = self.consos[indexPath.row].nomStation
        cell.textFieldNbLitres?.text = self.consos[indexPath.row].volConso.description + " " + volumeUnit
        cell.textFieldL100?.text = self.consos[indexPath.row].conso.description + " " + volumeUnit + "/100" + distanceUnit
        //L/100km"
        cell.textFieldPrixTotalRavitaillement?.text = self.consos[indexPath.row].prix.description + " " + currencyUnit
		
		/* Gestion de l'affichage des types de trajet */
		let typeTrajet = self.consos[indexPath.row].typeParcours
		if(typeTrajet == "Urbain"){
			cell.trajetUrbain.isHidden = false
			cell.trajetMixte.isHidden = true
			cell.trajetRoutier.isHidden = true
		}
		if(typeTrajet == "Mixte"){
			cell.trajetUrbain.isHidden = true
			cell.trajetMixte.isHidden = false
			cell.trajetRoutier.isHidden = true
		}
		if(typeTrajet == "Route"){
			cell.trajetUrbain.isHidden = true
			cell.trajetMixte.isHidden = true
			cell.trajetRoutier.isHidden = false
		}
		
        let formatter = DateFormatter()
        if(self.langue == "fr"){
            formatter.dateFormat = "dd/MM/yyyy"
        }else{
            formatter.dateFormat = "MM/dd/yy"
        }
        
        cell.textFieldDateRavitaillement?.text = formatter.string(from: self.consos[indexPath.row].dateConso)
        let stationImage = UIImage(data: self.consos[indexPath.row].stationImage! as Data)
        cell.ImageViewConso?.image = stationImage
        
        return cell
    }
    
    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteBtn = NSLocalizedString("Supprimer", comment: "deleteBtn")
        let editBtn = NSLocalizedString("Editer", comment: "editBtn")
		let shareBtn = NSLocalizedString("Partager", comment: "shareBtn")
		//let shareTxt = NSLocalizedString("Partager les informations du ticket", comment: "shareTxt")
		
        let deleteConsoAlertTitle = NSLocalizedString("Suppression conso", comment: "deleteConsoAlertTitle")
        let deleteConsoAlertMessage = NSLocalizedString("Etes-vous sûr de vouloir supprimer la ligne sélectionnée ?", comment: "deleteConsoAlertMessage")
        let deleteConsoAlertYes = NSLocalizedString("Oui", comment: "deleteConsoAlertYes")
        let deleteConsoAlertNo = NSLocalizedString("Non", comment: "deleteConsoAlertNo")
        let confirmConsoDelete = NSLocalizedString("La ligne a bien été supprimée de la base", comment: "confirmConsoDeleteConso")
		
        let deleteAction = UITableViewRowAction(style: .destructive, title: deleteBtn) { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let listToBeDeleted = self.consos[indexPath.row]
            SweetAlert().showAlert(deleteConsoAlertTitle, subTitle: deleteConsoAlertMessage, style: AlertStyle.warning, buttonTitle:deleteConsoAlertNo, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0) , otherButtonTitle:  deleteConsoAlertYes, otherButtonColor: self.UIColorFromRGB(rgbValue: 0xDD6B55)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    
                    print("Cancel Button Pressed")
                    
                }
                else {
                    print("L'utilisateur a décidé de supprimer une ligne de conso")
                    self.realm = try! Realm()
                    try! self.realm!.write{
                        self.realm!.delete(listToBeDeleted)
                        self.toastMessage(confirmConsoDelete)
                        self.listConso()
                    }
                    SweetAlert().showAlert("Supprimé!", subTitle: confirmConsoDelete, style: AlertStyle.success)
                }
            }
        }
		let shareAction = UITableViewRowAction(style: .normal, title: shareBtn) { (shareAction, indexPath) -> Void in
			let listToBeShared = self.consos[indexPath.row]
			
			let date = listToBeShared.dateConso
			/* Conversion de date */
			let formatter = DateFormatter()
			formatter.dateFormat = "dd/MM/yyyy"
			formatter.dateStyle = .short
			formatter.timeStyle = .none
			
			let dateConso = "Date: " + formatter.string(from: date)
			let carKm = "\nKm véhicule: " + listToBeShared.carKilometrage.description + " km"
			let km = "\nKm parcourus: " + listToBeShared.carKmParcourus.description + " km"
			let litres = "\nVol. Carburant: " + listToBeShared.volConso.description + " L"
			let conso = "\nConsommation: " + listToBeShared.conso.description + " L/100km"
			let prix = "\nPrix: " + listToBeShared.prix.description + " €"

			let vc = UIActivityViewController(activityItems: [dateConso, carKm, km, litres, conso, prix], applicationActivities: [])
			self.present(vc, animated: true, completion: nil)
		}
		
		
        return [deleteAction, shareAction]
    }
    
    func alertAddCar(){
        let titleAddCar = NSLocalizedString("Saisir un véhicule", comment: "titleAddCar")
		let messageAddCar = NSLocalizedString("Vous n'avez pas encore de voiture. Voulez-vous en saisir une ?", comment: "messageAddCar")
		let textYes = NSLocalizedString("Oui", comment: "textYes")
		let textNo = NSLocalizedString("Non", comment: "textNo")
		
		SweetAlert().showAlert(titleAddCar, subTitle: messageAddCar, style: AlertStyle.none, buttonTitle:textNo, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0) , otherButtonTitle:  textYes, otherButtonColor: self.UIColorFromRGB(rgbValue: 0xDD6B55)) { (isOtherButton) -> Void in
			if isOtherButton == true {
				
				print("Cancel Button Pressed")
				
			}
			else {
				if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addNewCar") as? AddCarViewController {
					if let navigator = self.navigationController {
						navigator.pushViewController(viewController, animated: true)
					}
				}
			}
		}
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        print("ConsoVC : viewWillAppear")
        listConso()
        //self.listMenuTable.reloadData()
        //self.navigationController?.isNavigationBarHidden = true
        animateTable()
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "editConso"){
            print("segue.destination:editConso")
            let indexPath = self.tableViewConso.indexPathForSelectedRow
            let editConsoVC = segue.destination as! editConsoTableViewController
            editConsoVC.consoItem = self.consos[indexPath!.row]
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
	
	/*final class Animator {
		private var hasAnimatedAllCells = false
		private let animation: Animation
		
		init(animation: @escaping Animation) {
			self.animation = animation
		}
		
		func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
			guard !hasAnimatedAllCells else {
				return
			}
			
			animation(cell, indexPath, tableView)
			
			hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
		}
	}*/
}
