//
//  ReglagesTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 28/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView
import CWProgressHUD
import LCUIComponents
import GoogleMobileAds
import PersonalizedAdConsent
import FileBrowser

class ReglagesTableViewController: UITableViewController, GADBannerViewDelegate {

	var listOfFiles:[URL] = []
	var backUpFiles:[(key:Int, value:String)] = []
	var selectedBackUpFile:String?
	var backUpFileName:String?
	var consentState:Int = 0
    
    var bannerView: GADBannerView!
	
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var VolumeLabel: UILabel!
    @IBOutlet weak var labelFraisKM: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

		searchForBackups()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        /* Implémentation de la bannière publicitaire */
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8249099547869316~4988744906")
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.load(GADRequest())
        
        bannerView.adUnitID = "ca-app-pub-8249099547869316/5778124533"
        bannerView.rootViewController = self
        
        bannerView.delegate = self
        
        let get = UserDefaults.standard

		if(UserDefaults.standard.object(forKey: "consentStatus") != nil){
			self.consentState = UserDefaults.standard.integer(forKey: "consentStatus")
		}
		print("consentStutus = @%",self.consentState)
		displayAdChoice()
    }
	@IBAction func buttonRestaurerDonnees(_ sender: UIButton) {
		searchForBackups()
		if(self.listOfFiles.count > 0){
			
			setupBackUpsPopover(for: sender, completion: {
				(test) in
				if(test == 1){
					print("restaurer")
					CWProgressHUD.show(withMessage: "Restauration")
					self.restoreDb()
					CWProgressHUD.dismiss()
				}
			})
		}else{
			
			let appearance = SCLAlertView.SCLAppearance(
				showCloseButton: false
			)
			let popup = SCLAlertView(appearance: appearance)
			popup.addButton(textStrings.strOK,backgroundColor: UIColor.green, textColor: UIColor.white){}
			popup.showInfo(textStrings.titleBackupNotExist, subTitle: textStrings.messageBackupNotExist)
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch indexPath.section {
			case 0:
				switch indexPath.row {
					case 0:
						print("carnet d'entretien")
						let VC = EntretiensConfiguration()
						self.navigationController?.pushViewController(VC, animated: true)
						break
					case 1:
						print("1-1")
						break
					default:
						break
				}
			case 1:
				switch indexPath.row {
					case 0:
						print("sauvegarder")
						CWProgressHUD.show(withMessage: "Sauvegarde")
						//clearAllFilesFromAppDirectory()	// Clear realm files from AutoConso directory
						saveDB()						// Save the realm DB
						CWProgressHUD.dismiss()
						break
					case 1:
						
						
						break
					case 2:
						CWProgressHUD.show(withMessage: "Réinitialisation")
						print("effacer")
						eraseDB()
						CWProgressHUD.dismiss()
						break
					case 3:
						CWProgressHUD.show(withMessage: "Suppression")
						clearAllFilesFromAppDirectory()
						CWProgressHUD.dismiss()
						break
					default:
						break
				}
			case 2:
				switch indexPath.row {
					case 0:
						let settings = UserDefaults.standard
						
						//1. Create the alert controller.
						let alert = UIAlertController(title: textStrings.lblDeviseAlertTitle, message: textStrings.alertDeviseMessage, preferredStyle: .alert)
						
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
						alert.addAction(UIAlertAction(title: textStrings.strOK, style: .default, handler: { [weak alert] (_) in
							let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
							print("Text field: \(textField.text)")
							settings.set(textField.text, forKey: "devise")
							self.currencyLabel.text = textField.text
						}))
						
						// 4. Present the alert.
						self.present(alert, animated: true, completion: nil)

						break
					case 1:
						let settings = UserDefaults.standard
						
						//1. Create the alert controller.
						let alert = UIAlertController(title: textStrings.lblDistanceAlertTitle, message: textStrings.alertDistanceMessage, preferredStyle: .alert)
						
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
						alert.addAction(UIAlertAction(title: textStrings.strOK, style: .default, handler: { [weak alert] (_) in
							let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
							print("Text field: \(textField.text)")
							settings.set(textField.text, forKey: "distance")
							self.DistanceLabel.text = textField.text
						}))
						
						// 4. Present the alert.
						self.present(alert, animated: true, completion: nil)

						
						break
					case 2:
						
						let settings = UserDefaults.standard
						
						//1. Create the alert controller.
						let alert = UIAlertController(title: textStrings.lblVolAlertTitle, message: textStrings.alertVolMessage, preferredStyle: .alert)
						
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
						alert.addAction(UIAlertAction(title: textStrings.strOK, style: .default, handler: { [weak alert] (_) in
							let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
							print("Text field: \(textField.text)")
							settings.set(textField.text, forKey: "volume")
							self.VolumeLabel.text = textField.text
						}))
						
						// 4. Present the alert.
						self.present(alert, animated: true, completion: nil)

						
						break
					default:
						break
				}
			case 3:
				switch indexPath.row {
					case 0:
						let storyboard = UIStoryboard(name: "Main", bundle: nil)
						let destinationViewController = storyboard.instantiateViewController(withIdentifier: "cgu_screen") as! CGUViewController
						self.present(destinationViewController, animated: true, completion: nil)
						break
					case 1:
						self.consentState = 0
						displayAdChoice()
						break
					default:
						break
				}
			case 4:
				switch indexPath.row{
					case 0:
						let settings = UserDefaults.standard
						
						//1. Create the alert controller.
						let alert = UIAlertController(title: textStrings.lblFraisKMAlertTitle, message: textStrings.lblFraisKMMessage, preferredStyle: .alert)
						
						//2. Add the text field. You can configure it however you need.
						alert.addTextField { (textField) in
							if(self.settingsDataAlreadyExist(Key: "fraisKM"))
							{
								textField.text = settings.object(forKey: "fraisKM") as! String
							}else{
								textField.text = "0.30"
							}
						}
						
						// 3. Grab the value from the text field, and print it when the user clicks OK.
						alert.addAction(UIAlertAction(title: textStrings.strOK, style: .default, handler: { [weak alert] (_) in
							let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
							print("Text field: \(textField.text)")
							settings.set(textField.text, forKey: "fraisKM")
							self.labelFraisKM.text = textField.text
						}))
						
						// 4. Present the alert.
						self.present(alert, animated: true, completion: nil)

						break
					default:
						break
				}
			default:
			break
		}
	}
	
	func saveDB() -> Bool {
		
		/* Popup implementation */
		
		let appearance = SCLAlertView.SCLAppearance(
			showCloseButton: false
		)
		let popup = SCLAlertView(appearance: appearance)
		
		
		if let DocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
			alertBackUpFileName(completion: {
				(test) in
				if(test == 1){
					
					let backupStoreFilename = self.backUpFileName
					let storeBackupDirectoryURL = DocumentDirectory.appendingPathComponent("AutoConso")
					let backupURL = storeBackupDirectoryURL.appendingPathComponent(backupStoreFilename!)
					let realm = try! Realm()
					// Optionally wrap in a write transaction to
					// prevent other changes happening
					realm.beginWrite()
					do {
						try realm.writeCopy(toFile: backupURL)
						popup.addButton(textStrings.strOK, backgroundColor: UIColor.green, textColor: UIColor.white){}
						popup.showSuccess(textStrings.titleSaveDBSuccess, subTitle: textStrings.messageSaveDBSuccess)
					} catch let e as NSError {
						print("Error backing up data:\n \(e)")
						popup.addButton(textStrings.strOK, backgroundColor: UIColor.red, textColor: UIColor.white){}
						popup.showError(textStrings.titleSaveDBError, subTitle: textStrings.messageSaveDBError)
						//return false
					}
					realm.cancelWrite()
				}
			})
		}
		return true
	}
	
	func saveData() -> Bool {
		
		/* Popup implementation */
		let iniPath = FileManager.default.urls(for: .userDirectory, in: .userDomainMask).first
		
		let fileBrowser = FileBrowser(initialPath: iniPath, allowEditing: true)
		fileBrowser.excludesFileExtensions = ["Realm"]
		present(fileBrowser, animated: true, completion: {
			fileBrowser.didSelectFile = { (file: FBFile) -> Void in
				var pathComponents = file.filePath.pathComponents
				let dirPath = (file.filePath.path as NSString).deletingLastPathComponent
				let dirURL = NSURL(string: dirPath)
//				print(fileArray)
				
				let appearance = SCLAlertView.SCLAppearance(
					showCloseButton: false
				)
				let popup = SCLAlertView(appearance: appearance)


	////			if let DocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
				self.alertBackUpFileName(completion: {
						(test) in
						if(test == 1){

							let backupStoreFilename = self.backUpFileName
							let backupURL = dirURL?.appendingPathComponent(file.displayName)//storeBackupDirectoryURL!.appendingPathComponent(file.displayName)
							let realm = try! Realm()
							// Optionally wrap in a write transaction to
							// prevent other changes happening
							realm.beginWrite()
							do {
								try realm.writeCopy(toFile: backupURL!)
								popup.addButton(textStrings.strOK, backgroundColor: UIColor.green, textColor: UIColor.white){}
								popup.showSuccess(textStrings.titleSaveDBSuccess, subTitle: textStrings.messageSaveDBSuccess)
							} catch let e as NSError {
								print("Error backing up data:\n \(e)")
								popup.addButton(textStrings.strOK, backgroundColor: UIColor.red, textColor: UIColor.white){}
								popup.showError(textStrings.titleSaveDBError, subTitle: textStrings.messageSaveDBError)
								//return false
							}
							realm.cancelWrite()
						}
					})
	////			}
			}
		})
		return true
	}
	
//	public func fileExplorerViewController(_ controller: FileExplorerViewController, didChooseURLs urls: [URL]) {
//		//Your code here
//		let backupStoreFilename = self.backUpFileName
//		let storeBackupDirectoryURL = DocumentDirectory.appendingPathComponent("AutoConso")
//		let backupURL = storeBackupDirectoryURL.appendingPathComponent(backupStoreFilename!)
//		let realm = try! Realm()
//		// Optionally wrap in a write transaction to
//		// prevent other changes happening
//		realm.beginWrite()
//		do {
//			try realm.writeCopy(toFile: backupURL)
//			popup.addButton(textStrings.strOK, backgroundColor: UIColor.green, textColor: UIColor.white){}
//			popup.showSuccess(textStrings.titleSaveDBSuccess, subTitle: textStrings.messageSaveDBSuccess)
//		} catch let e as NSError {
//			print("Error backing up data:\n \(e)")
//			popup.addButton(textStrings.strOK, backgroundColor: UIColor.red, textColor: UIColor.white){}
//			popup.showError(textStrings.titleSaveDBError, subTitle: textStrings.messageSaveDBError)
//			//return false
//		}
//		realm.cancelWrite()
//	}
	
	func restoreDb() -> Bool {
		
		/* Popup implementation */
		/**/
		
		let appearance = SCLAlertView.SCLAppearance(
			showCloseButton: false
		)
		let popup = SCLAlertView(appearance: appearance)
		let popupOKRestauration = SCLAlertView()
		let popupNOKRestauration = SCLAlertView()
		let popupBackUpNoExist = SCLAlertView()
		
		popup.addButton(textStrings.strOui, backgroundColor: UIColor.green, textColor: UIColor.white){
			if let DocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
				let backupStoreFilename = self.selectedBackUpFile
				let storeBackupDirectoryURL = DocumentDirectory.appendingPathComponent("AutoConso")
				let backupURL = storeBackupDirectoryURL.appendingPathComponent(backupStoreFilename!)
				let destPath = Realm.Configuration.defaultConfiguration.fileURL!
				let realm = try! Realm()
				// Optionally wrap in a write transaction to
				// prevent other changes happening
				
				self.removeRealmFile()
				
				do
				{
					if FileManager.default.fileExists(atPath: backupURL.path) {
						try FileManager.default.copyItem(atPath: backupURL.path, toPath: destPath.path)
						popupOKRestauration.showSuccess(textStrings.titleRestoreDBSuccess, subTitle: textStrings.messageRestoreDBSuccess)
					}else{
						popupBackUpNoExist.showWarning(textStrings.titleBackupNotExist, subTitle: textStrings.messageBackupNotExist)
					}
				}
				catch let error as NSError {
					// Catch fires here, with an NSError being thrown
					print("error occurred, here are the details:\n \(error)")
					popupNOKRestauration.showError(textStrings.titleRestoreDBError, subTitle: textStrings.messageRestoreDBError)
				}
				
			}
		}
		popup.addButton(textStrings.strNon, backgroundColor: UIColor.red, textColor: UIColor.white){}
		popup.showWarning(textStrings.titleConfirmRestore, subTitle: textStrings.messageConfirmRestore)
		
		return true
	}
	
	func removeRealmFile() -> Bool {
		autoreleasepool {
			// all Realm usage here
		}
		let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
		let realmURLs = [
			realmURL,
			realmURL.appendingPathExtension("lock"),
			realmURL.appendingPathExtension("note"),
			realmURL.appendingPathExtension("management")
		]
		for URL in realmURLs {
			do {
				try FileManager.default.removeItem(at: URL)
			} catch let e as NSError{
				// handle error
				print(e)
				return false
			}
		}
		return true
	}
	
	func clearAllFilesFromAppDirectory(){
		
		/* Popup implementation */
		
		
		let appearance = SCLAlertView.SCLAppearance(
			showCloseButton: false
		)
		let popup = SCLAlertView(appearance: appearance)
		let popupConfirmClearBackUps = SCLAlertView()
		let popupErrorClearBackUps = SCLAlertView()
		
		popup.addButton(textStrings.strOui, backgroundColor: UIColor.green, textColor: UIColor.white){
			var error: NSErrorPointer = nil
		
			let documentsUrl =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("AutoConso"))!
			
			do {
				let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
																		   includingPropertiesForKeys: nil,
																		   options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
				for fileURL in fileURLs {
					try FileManager.default.removeItem(at: fileURL)
					
				}
				popupConfirmClearBackUps.addButton(textStrings.strOK, backgroundColor: UIColor.darkGray, textColor: UIColor.white){}
				popupConfirmClearBackUps.showSuccess(textStrings.titleConfirmClearBackUps, subTitle: textStrings.messageConfirmClearBackUps)
			} catch  { print(error)
				popupConfirmClearBackUps.addButton(textStrings.strOui, backgroundColor: UIColor.red, textColor: UIColor.white){}
				popupConfirmClearBackUps.showError(textStrings.titleErrorClearBackUps, subTitle: textStrings.messageErrorClearBackUps)
			}
		}
		popup.addButton(textStrings.strNon, backgroundColor: UIColor.red, textColor: UIColor.white){}
		popup.showWarning(textStrings.titleClearBackUps, subTitle: textStrings.messageClearBackUps)
	}
	
	func eraseDB(){
		
		let appearance = SCLAlertView.SCLAppearance(
			showCloseButton: false
		)
		let popup = SCLAlertView(appearance: appearance)
		let popupOKErase = SCLAlertView()
		
		popup.addButton(textStrings.strOK, backgroundColor: UIColor.green, textColor: UIColor.white){
			self.removeRealmFile()
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000)) {
				popupOKErase.addButton(textStrings.strOK, backgroundColor: UIColor.green, textColor: UIColor.white){
					CWProgressHUD.dismiss()
					self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
				}
				popupOKErase.showSuccess(textStrings.titleOKErase, subTitle: textStrings.messageOKErase)
			}
		}
		
		popup.addButton(textStrings.strNon, backgroundColor: UIColor.red, textColor: UIColor.white){
			CWProgressHUD.dismiss()
		}
		popup.showWarning(textStrings.titleConfirmErase, subTitle: textStrings.messageConfirmErase)
	}
	
	func searchForBackups(){
		self.listOfFiles = []
		let documentsUrl =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("AutoConso"))!
		
		let fileManager = FileManager.default
		do {
			self.listOfFiles = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
			// process files
		} catch {
			print("Error while enumerating files \(documentsUrl.path): \(error.localizedDescription)")
		}
		
		//var myFileNames = fileURLs.map{$0.lastPathComponent!}
	}
	
	func generateBackUpFileName() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "ddMMyyyyHHmmss"
		let now = Date()
		return "AutoConso-" + dateFormatter.string(from: now)
	}
	
	func setupBackUpsPopover(for sender: UIView, completion: @escaping (Int)->Void){
		// Init a popover with a callback closure after selecting data
		self.listOfFiles = []
		self.searchForBackups()
		completion(0)
		let popover = LCPopover<Int>(for: sender, title: textStrings.strChargerSauvegarde) {
			tuple in
			// Use of the selected tuple
			guard let value = tuple?.value else {return}
			print(value)
			self.selectedBackUpFile = value
			completion(1)
			/*if(value = "Fermer la fenetre"){
				self.selectedBackUpFile = value
				completion(2)
			}else{
				self.selectedBackUpFile = value
				completion(1)
			}*/
		}
		var compteur:Int = 0
		for backUpFile in self.listOfFiles {
			compteur = compteur + 1
			let filePath = backUpFile
			let FileName = (filePath.description as NSString).lastPathComponent
			self.backUpFiles.append((compteur,FileName))
			print(FileName) //prints and empty string
		}
		
		// Assign data to the dataList
		popover.dataList = self.backUpFiles as! [(key: Int, value: String)]
		
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
	
	func alertBackUpFileName(completion: @escaping (Int) -> Void) {
		//1. Create the alert controller.
		completion(0)
		let alert = UIAlertController(title: textStrings.strNommerSauvegarde, message: textStrings.strMessageNommerSauvegarde, preferredStyle: .alert)
		
		//2. Add the text field. You can configure it however you need.
		alert.addTextField { (textField) in
			self.backUpFileName = self.generateBackUpFileName()
			textField.text = self.backUpFileName
		}
		
		// 3. Grab the value from the text field, and print it when the user clicks OK.
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
			[weak alert] (_) in
			let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
			print("Text field: \(textField!.text)")
			self.backUpFileName = textField!.text! + ".Realm"
			completion(1)
		}))
		
		// 4. Present the alert.
		self.present(alert, animated: true, completion: nil)
	}
    
    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
    
    func displayAdChoice(){
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8249099547869316~4988744906")
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
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
                //if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.unknown {
				if(self.consentState == 0){
					print("Consent status unknown")
					/* Google-rendered consent form */
					/* PACConsentForm with all three form options */
					// TODO: Replace with your app's privacy policy url.
					// Collect consent
                
					var url = ""
					if(UserDefaults.standard.string(forKey: "phoneLanguage") == "fr"){
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
								}
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
            //}
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


    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
