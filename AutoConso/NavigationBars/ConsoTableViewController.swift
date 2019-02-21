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
    var data:Results<Conso>!
    var carsData:Results<Car>!
    var consos:[Conso] = []
    var cars:[Car] = []
    @IBOutlet weak var tableViewConso: UITableView!
    @IBOutlet weak var btnAddConso: UIBarButtonItem!
    var langue = ""
    func listConso(){
        let realm = try! Realm()
        self.data = realm.objects(Conso.self).sorted(byKeyPath: "dateConso", ascending: false)
        self.consos = Array(self.data)
        self.carsData = realm.objects(Car.self)
        self.cars = Array(self.carsData)
        self.tableViewConso.setEditing(false, animated: true)
        self.tableViewConso.reloadData()
        print("listConso")
    }
    
    @IBAction func btnAddConso(_ sender: Any) {
        listConso()
        let VC = storyboard?.instantiateViewController(withIdentifier: "consoDetail") as! AddConsoViewController
        VC.car = self.cars.first
        navigationController?.pushViewController(VC, animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ConsoTableViewController:realmInit")
        let realm = try! Realm()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8249099547869316~4988744906")
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
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
            let noConsoMessage = NSLocalizedString("Vous n'avez pas encore saisi de ravitaillement", comment: "noConsoMessage")
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
    
    /* Fonction qui donne le mois et l'année à partir d'une date */
    fileprivate func firstDayOfMonth(date : Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    func loadList(notification: NSNotification){
        //load data here
        print("loadList")
        listConso()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.cars.count
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
        
            
        cell.textFieldStationService?.text = self.consos[indexPath.row].nomStation + " " + self.consos[indexPath.row].villeStation
        cell.textFieldNbLitres?.text = self.consos[indexPath.row].volConso.description + " " + volumeUnit
        cell.textFieldL100?.text = self.consos[indexPath.row].conso.description + " " + volumeUnit + "/100" + distanceUnit
        //L/100km"
        cell.textFieldPrixTotalRavitaillement?.text = self.consos[indexPath.row].prix.description + " " + currencyUnit
            
        let formatter = DateFormatter()
        if(self.langue == "fr"){
            formatter.dateFormat = "dd/MM/yyyy"
        }else{
            formatter.dateFormat = "MM/dd/yy"
        }
        
        cell.textFieldDateRavitaillement?.text = formatter.string(from: self.consos[indexPath.row].dateConso)
        let stationImage = UIImage(data: self.consos[indexPath.row].data! as Data)
        cell.ImageViewConso?.image = stationImage
        
        return cell
    }
    
    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteBtn = NSLocalizedString("Supprimer", comment: "deleteBtn")
        let editBtn = NSLocalizedString("Editer", comment: "editBtn")
        let deleteConsoAlertTitle = NSLocalizedString("Suppression conso", comment: "deleteConsoAlertTitle")
        let deleteConsoAlertMessage = NSLocalizedString("Etes-vous sûr de vouloir supprimer la ligne sélectionnée ?", comment: "deleteConsoAlertMessage")
        let deleteConsoAlertYes = NSLocalizedString("Oui je confirme", comment: "deleteConsoAlertYes")
        let deleteConsoAlertNo = NSLocalizedString("Non", comment: "deleteConsoAlertNo")
        let confirmConsoDelete = NSLocalizedString("La ligne a bien été supprimée de la base", comment: "confirmConsoDeleteConso")
        let deleteAction = UITableViewRowAction(style: .default, title: deleteBtn) { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let listToBeDeleted = self.consos[indexPath.row]
            
            let deleteConsoAlert = UIAlertController(title: deleteConsoAlertTitle, message: deleteConsoAlertMessage, preferredStyle: UIAlertControllerStyle.alert)
            
            deleteConsoAlert.addAction(UIAlertAction(title: deleteConsoAlertYes, style: .default, handler:
                { (action: UIAlertAction!) in
                print("L'utilisateur a décidé de supprimer une ligne de conso")
                    self.realm = try! Realm()
                    try! self.realm!.write{
                        self.realm!.delete(listToBeDeleted)
                        self.toastMessage(confirmConsoDelete)
                        self.listConso()
                    }
                })
            )
            
            deleteConsoAlert.addAction(UIAlertAction(title: deleteConsoAlertNo, style: .cancel, handler:
                { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
                }
            ))
            
            self.present(deleteConsoAlert, animated: true, completion: nil)
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: editBtn) { (editAction, indexPath) -> Void in
         
            // Editing will go here
            
            let editConsoVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "editConsoVC") as? editConsoTableViewController
            self.navigationController?.pushViewController(editConsoVC!, animated: true)
            editConsoVC!.consoItem = self.consos[indexPath.row]
         }
        return [editAction, deleteAction]
        //return [deleteAction]
    }
    
    func alertAddCar(){
        
        let addCarAlert = UIAlertController(title: "Saisir une voiture", message: "Vous n'avez pas encore de voiture. Voulez-vous en saisir une ?", preferredStyle: UIAlertControllerStyle.alert)
        
        addCarAlert.addAction(UIAlertAction(title: "Oui", style: .default, handler:
            { (action: UIAlertAction!) in
                print("L'utilisateur a décidé d'ajouter une voiture")
                
                /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "addNewCar") as UIViewController
                self.navigationController?.pushViewController(vc, animated: true)*/
                
                // Safe Push VC
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addNewCar") as? AddCarViewController {
                    if let navigator = self.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
                
                /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "NCaddNewCar") as! AddCarViewController
                //vc.newsObj = newsObj
                self.present(vc, animated: true, completion: nil)*/
        })
        )
        
        addCarAlert.addAction(UIAlertAction(title: "Non", style: .cancel, handler:
            { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
        }
        ))
        
        self.present(addCarAlert, animated: true, completion: nil)
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

/*extension UIView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}*/
