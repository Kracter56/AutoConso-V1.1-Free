//
//  TDBTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 21/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import os.log
import GoogleMobileAds


class TDBTableViewController: UITableViewController {
    
    var cars:Results<Car>!
    var carObjects:[Car] = []
    var consos:Results<Conso>!
    var consoObjects:[Conso] = []
    var cguAccept:Bool = false
    var realm:Realm?
    
    @IBOutlet weak var tableViewTDB: UITableView!
    @IBOutlet var tdbTableView: UITableView!
    @IBOutlet weak var btnAddCar: UIBarButtonItem!
    
    func listAllObjects(){
        print("TDBTableViewController:realmInit")
        let realm = try! Realm()
        
        self.cars = realm.objects(Car.self)
        self.carObjects = Array(self.cars)
        self.consos = realm.objects(Conso.self)
        self.consoObjects = Array(self.consos)
        self.tdbTableView.setEditing(false, animated: true)
        self.tdbTableView.reloadData()
        print("listCars count ",self.carObjects.count)
    }
    
    @IBAction func btnDetailCar(_ sender: UIButton) {
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "carDetail") as? EditCarViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    @IBAction func btnAddCar(_ sender: UIBarButtonItem) {
        if(self.carObjects.count > 0){
            alertOneCar()
        }else{
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addNewCar") as? AddCarViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        listAllObjects()
        print("TDBTableViewController -> viewDidLoad")
        
        let settings = UserDefaults.standard
        
        self.cguAccept = settings.bool(forKey: "cguAccept")
        
        if(self.cguAccept == false){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "cgu_screen") as! CGUViewController
        
            self.present(destinationViewController, animated: true, completion: nil)
        }
        // In this case, we instantiate the banner with desired ad size.
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        /*
        self.imageCar.backgroundColor = UIColor.redColor()
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true*/
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        
        
        if(self.carObjects.count > 1){
            self.btnAddCar.isEnabled = false
        }
        
        if(UserDefaults.standard.bool(forKey: "cguAccept") == false){
            print("viewWillAppear presenting CGU -> cguAccept = false")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "cgu_screen") as! CGUViewController
            
            self.present(destinationViewController, animated: true, completion: nil)
        }
        
        print("tdbVC : viewWillAppear")
        listAllObjects()
        animateTable()
    }
    
    func gotoAddCarVC(){
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addNewCar") as? AddCarViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("nbCars",self.carObjects.count)
        
        let noCarMessage = NSLocalizedString("Vous n'avez pas encore ajouté de véhicule. Touchez le bouton + pour en ajouter un.", comment: "noCarMessage")
        if self.carObjects.count == 0 {
            self.tableViewTDB.setEmptyMessage(noCarMessage)
            //alertAddCar()
            //gotoAddCarVC()
        } else {
            self.tableViewTDB.restore()
        }
        return self.carObjects.count
    }

    func alertAddCar(){
        
        /* Textes a traduire */
        let titleAddCar = NSLocalizedString("Saisir une véhicule", comment: "AddCarAlertTitle")
        let messageAddCar = NSLocalizedString("Vous n'avez pas encore de véhicule. Voulez-vous en saisir un ?", comment: "AddCarAlertMessage")
        let yesText = NSLocalizedString("Oui", comment: "AddCarAlertYesAnswer")
        let noText = NSLocalizedString("Non", comment: "AddCarAlertNoAnswer")
        
        let addCarAlert = UIAlertController(title: titleAddCar, message: messageAddCar, preferredStyle: UIAlertControllerStyle.alert)
        
        addCarAlert.addAction(UIAlertAction(title: yesText, style: .default, handler:
            { (action: UIAlertAction!) in
                print("L'utilisateur a décidé d'ajouter une voiture")
                
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addNewCar") as? AddCarViewController {
                    if let navigator = self.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
        })
        )
        
        addCarAlert.addAction(UIAlertAction(title: noText, style: .cancel, handler:
            { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
        }
        ))
        
        self.present(addCarAlert, animated: true, completion: nil)
    }
    
    func alertOneCar(){
        
        /* Textes a traduire */
        let titleAddOneCar = NSLocalizedString("En cours de développement", comment: "titleAddOneCar")
        let messageAddOneCar = NSLocalizedString("Oops, petit problème...Dans cette version, vous ne pourrez gérer qu'un seul véhicule", comment: "messageAddOneCar")
        let yesOneText = NSLocalizedString("OK", comment: "AddCarAlertYesAnswer")
        
        let addOneCarAlert = UIAlertController(title: titleAddOneCar, message: messageAddOneCar, preferredStyle: UIAlertControllerStyle.alert)
        
        addOneCarAlert.addAction(UIAlertAction(title: yesOneText, style: .default, handler:
            { (action: UIAlertAction!) in
                print("L'utilisateur a décidé d'ajouter une voiture")
                self.btnAddCar.isEnabled = false
        })
        )
        
        self.present(addOneCarAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tdbCarCell", for: indexPath) as! tdbCarsTableViewCell
        print("tableView -> cellForRowAt")
        // Configure the cell...
        let settings = UserDefaults.standard
        
        let marque = self.carObjects[indexPath.row].marque
        let modele = self.carObjects[indexPath.row].modele
        let pseudo = self.carObjects[indexPath.row].pseudo
        let type = self.carObjects[indexPath.row].type
        
        cell.labelCarModele?.text = marque + " " + modele
        cell.labelCarPseudo?.text = pseudo
        
        if(type == "CAR"||type == "VOITURE"){
            cell.imageCar.image = UIImage(named: "3Dcar")
        }
        if(type == "SCOOTER"){
            cell.imageCar.image = UIImage(named: "icon_scooter")
        }
        if(type == "BIKE"||type == "MOTO"){
            cell.imageCar.image = UIImage(named: "icon_moto")
        }
        
        if self.consos.count > 0 {
            
            let km = self.carObjects[indexPath.row].kilometrage
            
            // renvoie la valeur de km la plus élevée
            let lastCarKM: Int = Int((realm.objects(Conso.self).sorted(byKeyPath: "carKilometrage", ascending: false).first?.carKilometrage)!)
            
            let lastDate: Date = (realm.objects(Conso.self).sorted(byKeyPath: "dateConso", ascending: false).first?.dateConso)!
            
            let initCarKM: Int = Int(self.carObjects[indexPath.row].kilometrage)
            
            let KMparcourus = lastCarKM - initCarKM
            
            let sommeCarburant: Float = realm.objects(Conso.self).sum(ofProperty: "prix")
            let roundSommeCarburant = (sommeCarburant * 100).rounded() / 100    // Frais carburant arrondi à 2 dixiemes
            
            let ConsoMoyenne: Float = realm.objects(Conso.self).average(ofProperty: "conso")!
            let roundConsoMoyenne = (ConsoMoyenne * 1000).rounded() / 1000    // Conso moyenne arrondi à 2 dixiemes
            
            let coutKm: Float = sommeCarburant/Float(KMparcourus)
            let roundcoutKm = (coutKm * 1000).rounded() / 1000
            
            let nbJours = getDaysSinceStart(startDate: self.carObjects[indexPath.row].dateAchat, endDate: lastDate)
            
            let coutJournalier = 1000 * (roundSommeCarburant / Float(nbJours)).rounded() / 1000
            
            var devise:String = "€"
            var distance: String = "km"
            var volume: String = "L"
            
            if(settingsDataAlreadyExist(Key: "devise")){
                devise = settings.object(forKey: "devise") as! String
            }
            if(settingsDataAlreadyExist(Key: "distance")){
                distance = settings.object(forKey: "distance") as! String
            }
            if(settingsDataAlreadyExist(Key: "volume")){
                volume = settings.object(forKey: "volume") as! String
            }
            
            // remplit le champ km depuis achat
            cell.labelkmParcourusDepuisAchat?.text = KMparcourus.description + " " + distance
            cell.labelFraisCarburantDepuisAchat?.text = roundSommeCarburant.description + " " + devise
            cell.labelCarPseudo?.text = pseudo
            cell.labelCarModele?.text = modele
            cell.labelConsoMoyenne?.text = roundConsoMoyenne.description + " " + volume + "/100" + distance
            cell.labelCoutAuKm?.text = roundcoutKm.description + " " + devise + "/" + distance
            cell.labelNbJoursDepuisAchat?.text = nbJours.description
            cell.labelCoutJournalier?.text = coutJournalier.description + " " + devise
        }
        return cell
    }
    
    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
    
    func getLastCarKm() -> String {
        //var lastKM = self.carObjects.max(by: "Kilometrage") as Int?
        return ""
    }
    
    func getDaysSinceStart(startDate: Date, endDate: Date) -> Int{

        /*let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let previousDateFormated : Date? = dateFormatter.date(from: endDate)
        let difference = currentDate.timeIntervalSince(endDate)*/
        
        let differenceInDays = (endDate.timeIntervalSince(startDate)) / (60 * 60 * 24)
        print("getDaysSinceStart",differenceInDays)
        return Int(differenceInDays)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteBtn = NSLocalizedString("Supprimer", comment: "deleteBtn")
        let editBtn = NSLocalizedString("Editer", comment: "editBtn")
        let deleteCarAlertTitle = NSLocalizedString("Suppression voiture et données associées", comment: "deleteCarAlertTitle")
        let deleteCarAlertMessage = NSLocalizedString("Attention ! Si vous supprimez cette voiture, vous supprimerez tous les ravitaillements associés. Etes-vous sûr de vouloir continuer ?", comment: "deleteCarAlertMessage")
        let deleteCarAlertYes = NSLocalizedString("Oui, j'efface tout", comment: "deleteCarAlertYes")
        let deleteCarAlertNo = NSLocalizedString("Oups, Non je laisse tout.", comment: "deleteCarAlertNo")
        let confirmCarDeleteToastMessage = NSLocalizedString("La voiture et ses données associées ont bien été supprimés de la base", comment: "confirmCarDeleteToastMessage")
        
        let deleteAction = UITableViewRowAction(style: .default, title: deleteBtn) { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let carToBeDeleted = self.carObjects[0]
            
            let deleteCarAlert = UIAlertController(title: deleteCarAlertTitle, message: deleteCarAlertMessage, preferredStyle: UIAlertControllerStyle.alert)
            
            deleteCarAlert.addAction(UIAlertAction(title: deleteCarAlertYes, style: .default, handler: { (action: UIAlertAction!) in
                print("L'utilisateur a décidé de supprimer un véhicule")
                try! self.realm.write{
                    self.realm.delete(carToBeDeleted)
                    self.realm.delete(self.consoObjects)
                    self.toastMessage(confirmCarDeleteToastMessage)
                    self.listAllObjects()
                }
            }))
            
            deleteCarAlert.addAction(UIAlertAction(title: deleteCarAlertNo, style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            self.present(deleteCarAlert, animated: true, completion: nil)
            
            
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: editBtn) { (editAction, indexPath) -> Void in
            
            // Editing will go here
            let listToBeUpdated = self.carObjects[indexPath.row]
            //self.displayAlertToAddTaskList(listToBeUpdated)
            
        }
        
        return [deleteAction]
    }
    
    func animateTable() {
        self.tableViewTDB.reloadData()
        
        let cells = tableViewTDB.visibleCells
        let tableHeight: CGFloat = tableViewTDB.bounds.size.height
        
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

    @IBDesignable
    class DesignableView: UIView {
    }
    
    @IBDesignable
    class DesignableButton: UIButton {
    }
    
    @IBDesignable
    class DesignableLabel: UILabel {
    }

}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
