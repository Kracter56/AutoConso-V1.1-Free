//
//  AppDelegate.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 18/07/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMobileAds
import RealmSwift
import GoogleSignIn
import CoreLocation

@available(iOS 10.0, *)
@available(iOS 10.0, *)
@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		// ...
		if let error = error {
			// ...
			return
		}
		
		guard let authentication = user.authentication else { return }
		let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
													   accessToken: authentication.accessToken)
		// ...
	}
	

    var window: UIWindow?
    var bannerView: GADBannerView!


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize the Google Mobile Ads SDK.
        // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
		
        FirebaseApp.configure()
		
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
		
        /* Vérification de la langue de l'iphone */
        let phoneLanguage = Locale.current.languageCode
        
        if(!settingsDataAlreadyExist(Key: "cguAccept")){
            // Si cguAccept n'existe pas (ie premier lancement) on initialise la valeur a false
            print("cguAccept n'existe pas",false)
            UserDefaults.standard.set(false, forKey: "cguAccept")
        }
        UserDefaults.standard.set(phoneLanguage, forKey: "phoneLanguage")
        
        /* Créer un dossier dans les Documents pour gérer les photos */
        createAppDirectory()
        initBDD()
        /* Copier la base de données si elle n'existe pas */
        /*let bundlePath = Bundle.main.path(forResource: "default", ofType: "realm")
        let destPath = Realm.Configuration.defaultConfiguration.fileURL?.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: destPath!) {
            //File exist, do nothing
            print(fileManager.fileExists(atPath: destPath!))
        } else {
            do {
                //Copy file from bundle to Realm default path
                try fileManager.copyItem(atPath: bundlePath!, toPath: destPath!)
            } catch {
                print("\n",error)
            }
        }*/
        
        
        // Inside your application(application:didFinishLaunchingWithOptions:)
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 36,
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 36) {
                    print("oldSchemaVersion", oldSchemaVersion)
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        print("AppDelegate:realmInit")
        //let realm = try! Realm()
        
        return true
    }
    
    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
    
    func createAppDirectory(){
        /* Création d'un dossier de sauvegarde dans l'iphone */
        let fileManager = FileManager.default
        if let DocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  DocumentDirectory.appendingPathComponent("AutoConso")
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
	//@available(iOS 9.0, *)
	func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
		-> Bool {
			return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
													 annotation: [:])
	}
	
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
    /* Edgar PETRUS - 07/10/2018 : Gestion de la rotation */
    /*func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController.responds(to: Selector(("canRotate")))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            }
        }
        
        // Only allow portrait (standard behaviour)
        return .portrait;
    }*/
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: UITabBarController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AutoConso")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
	
	func initBDD(){
		let bundlePath = Bundle.main.path(forResource: "/bdd.bundle/AutoConso-bdd-init-25082019", ofType: ".realm")
		let destPath = Realm.Configuration.defaultConfiguration.fileURL?.path
		let fileManager = FileManager.default
		print("initBDD()")
		if fileManager.fileExists(atPath: destPath!) {
			//File exist, do nothing
			print(destPath ?? "if loop")
		} else {
			do {
				//Copy file from bundle to Realm default path
				try fileManager.copyItem(atPath: bundlePath!, toPath: destPath!)
			} catch {
				print(error)
			}
		}
	}
}

