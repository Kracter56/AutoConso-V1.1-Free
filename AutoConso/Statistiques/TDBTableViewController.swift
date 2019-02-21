//
//  TDBTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 21/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import os.log
import GoogleMobileAds
import PersonalizedAdConsent
import SCLAlertView


class TDBTableViewController: UITableViewController, GADBannerViewDelegate {
    
    var cars:Results<Car>!
    var carObjects:[Car] = []
    var idCar =  ""
    var consos:Results<Conso>!
    var consoObjects:[Conso] = []
    var cguAccept:Bool = false
    var bannerView: GADBannerView!
    var langue = ""
    var realm:Realm?
    
    
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var edgeSwipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    
    //@IBOutlet weak var carImage: UIImageView!
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
        
        
        
        self.tdbTableView.delegate = self
        self.tdbTableView.dataSource = self
        
        createAppDirectory()
        
        edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        edgeSwipeGestureRecognizer!.edges = .left
        view.addGestureRecognizer(edgeSwipeGestureRecognizer!)
        
        listAllObjects()
        print("TDBTableViewController -> viewDidLoad")
        
        let settings = UserDefaults.standard
        
        
        
        self.cguAccept = settings.bool(forKey: "cguAccept")
        
        if(self.cguAccept == false){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "cgu_screen") as! CGUViewController
        
            self.present(destinationViewController, animated: true, completion: {
                self.loadAds()
            })
        }

        

        // In this case, we instantiate the banner with desired ad size.
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func showVehicleDetails(){
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "carDetail") as? EditCarViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        // 1
        let percent = gestureRecognizer.translation(in: gestureRecognizer.view!).x / gestureRecognizer.view!.bounds.size.width
        
        if gestureRecognizer.state == .began {
            // 2
            interactionController = UIPercentDrivenInteractiveTransition()
            //popViewController(animated: true)
        } else if gestureRecognizer.state == .changed {
            // 3
            interactionController?.update(percent)
        } else if gestureRecognizer.state == .ended {
            // 4
            if percent > 0.5 && gestureRecognizer.state != .cancelled {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        }
    }
    
    func createAppDirectory(){
        /* Création d'un dossier de sauvegarde dans l'iphone */
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent("AutoConso")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    NSLog("Couldn't create document directory")
                }
            }
            NSLog("Document directory is \(filePath)")
            UserDefaults.standard.set(filePath, forKey: "appFolder")
            //set(filePath,forkey: "appFolder")
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func fadeOut(){
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn, animations: {
        self.tdbTableView.alpha = 0
        }) { _ in
        self.tdbTableView.removeFromSuperview()
        }
    }
    
    func loadAds(){
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8249099547869316~4988744906")
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        self.langue = UserDefaults.standard.string(forKey: "phoneLanguage")!
        /*bannerView.adUnitID = "ca-app-pub-8249099547869316/5778124533"
         bannerView.rootViewController = self
         bannerView.load(GADRequest())*/
        
        bannerView.delegate = self
        
        //Update consent status
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(forPublisherIdentifiers: ["pub-8249099547869316"])
        {
            (_ error: Error?) -> Void in
            if let error = error {
                print("Consent info update failed.")
            } else {
                // Consent info update succeeded. The shared PACConsentInformation
                // instance has been updated.
                print("Consent info update succeeded")
                if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.unknown {
                    print("Consent status unknown")
                    /* Google-rendered consent form */
                    /* PACConsentForm with all three form options */
                    // TODO: Replace with your app's privacy policy url.
                    // Collect consent
                    
                    var url = ""
                    if(self.langue == "fr"){
                        url = "https://drive.google.com/open?id=1TTrsdtYb2yPHBm2ki4fdm1s1Z65rnz8Q"
                    }else{
                        url = "https://drive.google.com/open?id=1tF8Vb9mi5moFjJapUoQyy9snIcprvZeV"
                    }
                    
                    guard let privacyUrl = URL(string: url),
                        let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                            print("incorrect privacy URL.")
                            return
                    }
                    form.shouldOfferPersonalizedAds = true
                    form.shouldOfferNonPersonalizedAds = true
                    form.shouldOfferAdFree = false
                    
                    form.load {(_ error: Error?) -> Void in
                        print("Load complete.")
                        if let error = error {
                            // Handle error.
                            print("Error loading form: \(error.localizedDescription)")
                        } else {
                            // Load successful.
                            //guard let strongSelf = self else { return }
                            print("Consent form load success")
                            /* Afficher le formulaire de consentement (Show consent form) */
                            form.present(from: self) { (error, userPrefersAdFree) in
                                if let error = error {
                                    // Handle error.
                                } else if userPrefersAdFree {
                                    // User prefers to use a paid version of the app.
                                }else{
                                    
                                    // Check the user's consent choice.
                                    let status = PACConsentInformation.sharedInstance.consentStatus
                                    
                                    // TODO: show ads
                                }
                            }
                        }
                    }
                }
                if (PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized || PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.personalized){
                    
                    print("The user has granted consent for personalized ads.")
                    
                    self.bannerView.isHidden = false
                    self.bannerView.adUnitID = "ca-app-pub-8249099547869316/5778124533"
                    self.bannerView.rootViewController = self
                    let request = GADRequest()
                    
                    if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized {
                        print("The user has granted consent for non-personalized ads.")
                        // Forward consent to the Google Mobile Ads SDK
                        let extras = GADExtras()
                        extras.additionalParameters = ["npa": "1"]
                        request.register(extras)
                    }else {
                        // Check the user's consent choice.
                        let status = PACConsentInformation.sharedInstance.consentStatus
                    }
                    self.bannerView.load(request)
                }
            }
        }
        let adProviders = PACConsentInformation.sharedInstance.adProviders
        print("adProviders",adProviders)
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
        loadAds()
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillAppear(true)
        //fadeOut()
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
            
            self.tdbTableView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.tdbTableView.setEmptyMessage(noCarMessage)
                self.tdbTableView.fadeIn()
            })

            //alertAddCar()
            //gotoAddCarVC()
        } else {
            self.tdbTableView.restore()
        }
        return self.carObjects.count
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
        let Image = UIImage(data: self.carObjects[indexPath.row].data! as Data)

        cell.imageCar?.image = Image
        cell.labelCarModele?.text = marque + " " + modele
        cell.labelCarPseudo?.text = pseudo
        
        if self.consos.count > 0 {
            let realm = try! Realm()
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
            
            let coutJournalier = 100 * (roundSommeCarburant / Float(nbJours)).rounded() / 100
            
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Create a variable that you want to send based on the destination view controller
        // You can get a reference to the data by using indexPath shown below
        /*self.idCar = self.cars[indexPath.row].idCar
        print("didSelectRowAt : idCar",self.idCar)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "statsScreen") as! StatsAutoTableViewController
        vc.idCar = self.idCar
        
        self.present(vc, animated: true, completion: nil)*/
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteBtn = NSLocalizedString("Supprimer", comment: "deleteBtn")
        let editBtn = NSLocalizedString("Details", comment: "editBtn")
        let deleteCarAlertTitle = NSLocalizedString("Suppression voiture et données associées", comment: "deleteCarAlertTitle")
        let deleteCarAlertMessage = NSLocalizedString("Attention ! Si vous supprimez cette voiture, vous supprimerez tous les ravitaillements associés. Etes-vous sûr de vouloir continuer ?", comment: "deleteCarAlertMessage")
        let deleteCarAlertYes = NSLocalizedString("Oui, j'efface tout", comment: "deleteCarAlertYes")
        let deleteCarAlertNo = NSLocalizedString("Oups, Non je laisse tout.", comment: "deleteCarAlertNo")
        let confirmCarDeleteToastMessage = NSLocalizedString("La voiture et ses données associées ont bien été supprimés de la base", comment: "confirmCarDeleteToastMessage")
        
        let deleteAction = UITableViewRowAction(style: .default, title: deleteBtn) { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let carToBeDeleted = self.carObjects[0]
            
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let deleteCarAlert = SCLAlertView(appearance: appearance)
            
            deleteCarAlert.addButton(deleteCarAlertYes){
                print("L'utilisateur a décidé de supprimer un véhicule")
                self.realm = try! Realm()
                try! self.realm!.write{
                    self.realm!.delete(carToBeDeleted)
                    self.realm!.delete(self.consoObjects)
                    self.toastMessage(confirmCarDeleteToastMessage)
                    self.listAllObjects()
                //self.dismiss(animated: true)
                }
            }
            deleteCarAlert.addButton(deleteCarAlertNo) {
                print("On n'efface pas le vehicule")
            }
            
            deleteCarAlert.showWarning(deleteCarAlertTitle, subTitle: deleteCarAlertMessage)
            
        }
        let editAction = UITableViewRowAction(style: .normal, title: editBtn) { (editAction, indexPath) -> Void in
            
            // Editing will go here
            self.showVehicleDetails()
            
        }
        
        return [editAction, deleteAction]
    }
    
    func animateTable() {
        self.tdbTableView.reloadData()
        
        let cells = tdbTableView.visibleCells
        let tableHeight: CGFloat = tdbTableView.bounds.size.height
        
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
    
    
    
    /*func animateToTab(toIndex: Int) {
        let tabViewControllers = viewControllers!
        let fromView = selectedViewController!.view
        let toView = tabViewControllers[toIndex].view
        let fromIndex = tabViewControllers.indexOf(selectedViewController!)
        
        guard fromIndex != toIndex else {return}
        
        // Add the toView to the tab bar view
        fromView.superview!.addSubview(toView)
        
        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        let scrollRight = toIndex > fromIndex;
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        // Disable interaction during animation
        view.userInteractionEnabled = false
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            // Slide the views by -offset
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y);
            toView.center   = CGPoint(x: toView.center.x - offset, y: toView.center.y);
            
        }, completion: { finished in
            
            // Remove the old view from the tabbar view.
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.userInteractionEnabled = true
        })
    }*/

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "segueShowStats"){
            print("segue.destination")
            // indexPath is set to the path that was tapped
            let indexPath = self.tdbTableView.indexPathForSelectedRow
            
            // titleString is set to the title at the row in the objects array.
            let id = self.carObjects[indexPath!.row].idCar
            let vc = segue.destination as! StatsAutoTableViewController
            vc.idCar = id
            
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
    }
  

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

/*extension TDBTableViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 3
        if operation == .push {
            return FadeAnimationController(presenting: true)
        } else {
            return FadeAnimationController(presenting: false)
        }
    }
}*/

extension UIView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
