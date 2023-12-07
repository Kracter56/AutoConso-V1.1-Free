//
//  InformationsTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 03/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds
import PersonalizedAdConsent

class InformationsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate{

    var bannerView: GADBannerView!
	var langue:String?
	var consentState:Int = 0
    
    var lblDeviseAlertTitle = NSLocalizedString("Saisie de la devise", comment: "lblDeviseAlertTitle")
    var alertDeviseMessage = NSLocalizedString("Saisir une devise", comment: "alertDeviseMessage")
    var textFieldHint = NSLocalizedString("Devise", comment: "textFieldHint")
    
    var lblDistanceAlertTitle = NSLocalizedString("Saisie de l'unité de distance", comment: "lblDistanceAlertTitle")
    var alertDistanceMessage = NSLocalizedString("Saisir une unité de distance", comment: "alertDistanceMessage")
    var textFieldDistanceHint = NSLocalizedString("Distance", comment: "textFieldDistanceHint")
    
    var lblVolAlertTitle = NSLocalizedString("Saisie de l'unité de volume", comment: "lblVolAlertTitle")
    var alertVolMessage = NSLocalizedString("Saisir une unité de volume", comment: "alertVolMessage")
    var textFieldVolHint = NSLocalizedString("Unité de Volume", comment: "textFieldVolHint")
    
	@IBOutlet weak var labelPseudo: UILabel!
	@IBOutlet weak var labelDateInscription: UILabel!
	@IBOutlet weak var labelMail: UILabel!
	@IBOutlet weak var labelDerniereConnexion: UILabel!
	@IBOutlet weak var labelSWVersion: UILabel!
	@IBOutlet weak var labelDatePublication: UILabel!
	
	@IBOutlet var tbl: UITableView!
    @IBOutlet weak var editFieldCurrency: UIButton!
    @IBOutlet weak var labelAnnonces: UIButton!
    @IBAction func BtnAnnonces(_ sender: UIButton) {
        loadAds()
    }
    @IBOutlet weak var editFieldDistance: UIButton!
    @IBOutlet weak var editFieldVol: UIButton!
    @IBAction func btnCGU(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "cgu_screen") as! CGUViewController
        self.present(destinationViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnDeviseSelection(_ sender: UIButton) {
        
        let settings = UserDefaults.standard
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: lblDeviseAlertTitle, message: alertDeviseMessage, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            if(self.settingsDataAlreadyExist(Key: "devise"))
            {
                textField.text = settings.object(forKey: "devise") as! String
            }else{
                textField.text = "€"
            }
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            settings.set(textField.text, forKey: "devise")
            self.editFieldCurrency.setTitle(textField.text, for: .normal)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func animateTable() {
        
		self.view.fadeIn(completion: {
			(finished: Bool) -> Void in
		})
		
        /*let cells = tbl.visibleCells
        let tableHeight: CGFloat = tbl.bounds.size.height
        
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
        }*/
    }
	
	@IBAction func onRefresh(_ sender: UIBarButtonItem) {
		// Refresh table view here
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
		// Add animations here
		cell.alpha = 0
		
		UIView.animate(
			withDuration: 0.5,
			delay: 0.05 * Double(indexPath.row),
			animations: {
				cell.alpha = 1
		})
		
		/*let animation = AnimationFactory.makeSlideIn(duration: 0.5, delayFactor: 0.05)
		let animator = Animator(animation: animation)
		animator.animate(cell: cell, at: indexPath, in: tableView)*/
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
				print("consentStatus = ", PACConsentInformation.sharedInstance.consentStatus.rawValue)
				
				if(UserDefaults.standard.object(forKey: "consentStatus") != nil){
					self.consentState = UserDefaults.standard.integer(forKey: "consentStatus")
				}
				print("consentStutus = @%",self.consentState)
				
                //if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.unknown {
				if self.consentState == 0 {
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
									print("user prefers adFree")
                                }else{
                                    print("user don't prefer adFree")
                                    // Check the user's consent choice.
									let status = PACConsentInformation.sharedInstance.consentStatus
									if status == PACConsentStatus.nonPersonalized {
										UserDefaults.standard.set(1, forKey: "consentStatus")
										self.consentState = 1
									}
									if status == PACConsentStatus.personalized {
										UserDefaults.standard.set(2, forKey: "consentStatus")
										self.consentState = 2
									}
									if status == PACConsentStatus.unknown {
										UserDefaults.standard.set(0, forKey: "consentStatus")
										self.consentState = 0
									}
									
									//UserDefaults.standard.set(PACConsentInformation.sharedInstance.consentStatus, forKey: "consentStatus")
									print(status.rawValue)
								}
                            }
                        }
                    }
                }
				
                //if (PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized || PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.personalized){
				if(self.consentState == 1 || self.consentState == 2){
                    print("The user has granted consent for personalized ads.")
                    
                    self.bannerView.isHidden = false
                    self.bannerView.adUnitID = "ca-app-pub-8249099547869316/5778124533"
                    self.bannerView.rootViewController = self
                    let request = GADRequest()
                    
                    //if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized {
					if(self.consentState == 1){
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
    
    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
    
    @IBAction func btnDistanceSelection(_ sender: UIButton) {
        
        let settings = UserDefaults.standard
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: lblDistanceAlertTitle, message: alertDistanceMessage, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            if(self.settingsDataAlreadyExist(Key: "distance"))
            {
                textField.text = settings.object(forKey: "distance") as! String
            }else{
                textField.text = "km"
            }
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            settings.set(textField.text, forKey: "distance")
            self.editFieldDistance.setTitle(textField.text, for: .normal)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func btnVolumeSelection(_ sender: UIButton) {
        
        let settings = UserDefaults.standard
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: lblVolAlertTitle, message: alertVolMessage, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            if(self.settingsDataAlreadyExist(Key: "volume"))
            {
                textField.text = settings.object(forKey: "volume") as! String
            }else{
                textField.text = "L"
            }
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            settings.set(textField.text, forKey: "volume")
            self.editFieldVol.setTitle(textField.text, for: .normal)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnSendRemarques(_ sender: UIButton) {
        sendEmail()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

		
        animateTable()
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8249099547869316~4988744906")
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.load(GADRequest())
        
        bannerView.adUnitID = "ca-app-pub-8249099547869316/5778124533"
        bannerView.rootViewController = self
        
        bannerView.delegate = self
        
        let get = UserDefaults.standard
        
        editFieldCurrency?.setTitle("€", for: .normal)
        editFieldDistance?.setTitle("km", for: .normal)
        editFieldVol?.setTitle("L", for: .normal)
        
        if(settingsDataAlreadyExist(Key: "devise")){
            editFieldCurrency?.setTitle(get.object(forKey: "devise") as? String, for: .normal)
        }
        if(settingsDataAlreadyExist(Key: "distance")){
            editFieldDistance?.setTitle(get.object(forKey: "distance") as? String, for: .normal)
        }
        if(settingsDataAlreadyExist(Key: "volume")){
			
            editFieldVol?.setTitle(get.object(forKey: "volume") as? String, for: .normal)
        }
		
		/* Remplaissage du profil utilisateur */
		self.labelMail.text = UserDefaults.standard.string(forKey: "usrEmail")
		self.labelPseudo.text = UserDefaults.standard.string(forKey: "usrPseudo")
//		self.labelNbPoints.text = UserDefaults.standard.string(forKey: "usrPoints")
		self.labelDateInscription.text = UserDefaults.standard.string(forKey: "usrLastConnection") //usrDateInscription
		self.labelDerniereConnexion.text = UserDefaults.standard.string(forKey: "usrLastConnection")
		self.labelSWVersion.text = "1.2"
		self.labelDatePublication.text = "13/09/2019"
		
		if(UserDefaults.standard.object(forKey: "consentStatus") != nil){
			self.consentState = UserDefaults.standard.integer(forKey: "consentStatus")
		}
		print("consentStutus = @%",self.consentState)
		loadAds()
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
		
    }
    
    
    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("AutoConso : Bug / Suggestion")
            mail.setToRecipients(["aufra.technologie@gmail.com"])
            mail.setMessageBody("<p>Bonjour Monsieur,</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    /*func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        // Dismiss the mail compose view controller.
        controller.dismissViewControllerAnimated(true, completion: nil)
    }*/
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

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

}

/*extension UIView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
		UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
		UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}*/
