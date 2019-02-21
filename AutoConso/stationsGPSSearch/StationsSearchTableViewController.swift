//
//  StationsSearchTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 19/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation
import RealmSwift

class StationsSearchTableViewController: UITableViewController {

    @IBOutlet var tableViewStations: UITableView!
    var matchingItems:[MKMapItem] = []
    var sv:UIView?
    var addConsoVC:AddConsoViewController?
    var locations = [LocationObject]()
    var coordGPS:CLLocation?
    var stationName:String?
    var stationAdresse:String?
    var stationVille:String?
    var searchString:String?
    let locationManager = CLLocationManager()
    var car:Car?
    var station:Station?
    var oConso:Conso?
    var realm:Realm?
    var coord:CLLocationCoordinate2D?
    var senderVC:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sv = UITableViewController.displaySpinner(onView: self.view)
        
        /*let adresse = self.stationVille! + ", FRANCE"   //self.stationAdresse! + " " + self.stationVille!
        //let address = "8787 Snouffer School Rd, Montgomery Village, MD 20879"
        */
        
        
        
        /*geocoder.geocodeAddressString(adresse, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error ?? "")
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                print("Lat: \(coordinates.latitude) -- Long: \(coordinates.longitude)")
            }
        })*/
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        performSearchRequest()
        animateTable()
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getLocation(forPlaceCalled name: String,
                     completion: @escaping(CLLocation?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            guard let location = placemark.location else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(location)
        }
    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matchingItems.count
    }*/

    
    /*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StationsSearchTableViewCell", for: indexPath) as! StationsSearchTableViewCell

        //performSearchRequest()
        let location = locations[indexPath.row]
        
        // Configure the cell...
        cell.configureLocationCell(locationName: location.locationName, location: location.location)
        return cell
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
        if self.senderVC == "AddConsoVC"
        {
            let indexPath:IndexPath = self.tableViewStations.indexPathForSelectedRow!
            /* On créer l'id de la station à sélectionner */
            let vc = segue.destination as? AddConsoViewController
            
            /* Envoi de la recherche */
            //vc!.station =
            vc!.car = self.car
            let station = Station()
            let selectedLocation = locations[indexPath.row]
            station.nomStation = selectedLocation.locationName
            station.adresse = selectedLocation.location
            station.codePostal = selectedLocation.codePostal
            station.ville = selectedLocation.ville
            station.coordGPS = selectedLocation.coordGPS
            
            self.station = station
        }
        
        
        if segue.destination is AddConsoViewController
        {
            let indexPath:IndexPath = self.tableViewStations.indexPathForSelectedRow!
            /* On créer l'id de la station à sélectionner */
            let vc = segue.destination as? AddConsoViewController
            
            /* Envoi de la recherche */
            //vc!.station =
            vc!.car = self.car
            let station = Station()
            let selectedLocation = locations[indexPath.row]
            station.nomStation = selectedLocation.locationName
            station.adresse = selectedLocation.location
            station.codePostal = selectedLocation.codePostal
            station.ville = selectedLocation.ville
            station.coordGPS = selectedLocation.coordGPS
            
            self.station = station
            //vc!.station = sender.
            //vc.addConsoVC = self // Je lie les 2 viewControllers pour que quand je sélectionne une donnée de vc, je puisse appeler une fonction de addConso
        }
        
        if segue.destination is editConsoTableViewController
        {
            let indexPath:IndexPath = self.tableViewStations.indexPathForSelectedRow!
            /* On créer l'id de la station à sélectionner */
            let vc = segue.destination as? editConsoTableViewController
            
            /* Envoi de la recherche */
            //vc!.station =
            vc!.carItem = self.car
            let station = Station()
            let consoItem = self.oConso
            
            let selectedLocation = locations[indexPath.row]
            station.nomStation = selectedLocation.locationName
            station.adresse = selectedLocation.location
            station.codePostal = selectedLocation.codePostal
            station.ville = selectedLocation.ville
            station.coordGPS = selectedLocation.coordGPS
            
            self.station = station
            let realm = try! Realm()
            try! realm.write {
                consoItem!.adresseStation = selectedLocation.locationName
                consoItem!.CPStation = selectedLocation.codePostal
                consoItem!.villeStation = selectedLocation.ville
                realm.add(consoItem!)
            }
            vc!.station = self.station
            vc!.consoItem = consoItem
            vc!.source = "StationsVC"
            //self.navigationController?.popToViewController(self, animated: true)
            //vc.addConsoVC = self // Je lie les 2 viewControllers pour que quand je sélectionne une donnée de vc, je puisse appeler une fonction de addConso
        }
    }
    
    func animateTable() {
        self.tableViewStations.reloadData()
        
        let cells = tableViewStations.visibleCells
        let tableHeight: CGFloat = tableViewStations.bounds.size.height
        
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
    
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                //self.coordinates = location?.coordinate
                
                if let subAdminArea = placemark?.subAdministrativeArea {
                    //self.address.county = subAdminArea
                }
            }
        })
        /*CLGeocoder().geocodeAddressString(address) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
        }*/
    }
    
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }

    func performSearchRequest() {
        let request = MKLocalSearch.Request()
        let locationManager = CLLocationManager()
        //let lieu = self.stationName! + " " + self.stationAdresse! + " " + self.stationVille!
        getLocation(forPlaceCalled: /*self.stationVille!*/ "Total Neuilly-sur-marne") { location in
            guard let location = location else { return }
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            print("Coordinates",location.coordinate)
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 3200, 3200)
            request.naturalLanguageQuery = self.stationName             //self.searchString
            request.region = region
        
        //guard let coordinate = locationManager.location?.coordinate else { return }
        //print(self.searchString)
        //request.naturalLanguageQuery = self.stationName! //"\(myTextField.text)"
        //request.region = MKCoordinateRegionMakeWithDistance(coordinate, 3200, 3200)
        // about a couple miles around you
        
            MKLocalSearch(request: request).start { (response, error) in
                guard error == nil else { return }
                guard let response = response else { return }
                guard response.mapItems.count > 0 else { return }
                
                let randomIndex = Int(arc4random_uniform(UInt32(response.mapItems.count)))
                _ = response.mapItems[randomIndex]
                
                for locationItem in response.mapItems {
                    
                    let loc = CLLocation(latitude: locationItem.placemark.coordinate.latitude, longitude: locationItem.placemark.coordinate.longitude)
                    
                    let distanceBrute = (locationManager.location?.distance(from: loc))!/1000
                    let distance = String(format: "%.2f", distanceBrute)
                    let nom = locationItem.name
                    var adresse = ""
                    var codePostal = ""
                    var Ville = ""
                    
                    if(locationItem.placemark.subThoroughfare) != nil{
                        adresse = locationItem.placemark.subThoroughfare!
                    }
                    if(locationItem.placemark.thoroughfare) != nil {
                        adresse = adresse + " " + locationItem.placemark.thoroughfare!
                    }
                    if(locationItem.placemark.postalCode) != nil {
                        codePostal = locationItem.placemark.postalCode!
                        print("codePostal : %@",codePostal)
                    }
                    if(locationItem.placemark.locality) != nil {
                        Ville =  locationItem.placemark.locality!
                        print("Ville : %@",Ville)
                    }
                    
                    let strDistance = distance.description
                    print("strDistance ",strDistance)
                    let loklak = loc.coordinate.latitude.description + ", " + loc.coordinate.longitude.description
                    let location = LocationObject(locationName: nom!, location: adresse, codePostal: codePostal, ville: Ville, Distance: strDistance + " km", coordGPS: loklak)
                    
                    self.locations.append(location)
                    self.matchingItems = response.mapItems
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension StationsSearchTableViewController: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            print("Localisation OK : ",location.coordinate.latitude.description + ", " + location.coordinate.longitude.description)
            //mapView.setRegion(region, animated: true)
            /*self.coordGPS = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)*/
        }
    }
    
}

extension StationsSearchTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("LocationSearchTable : numberOfRowsInSection",matchingItems.count)
        UITableViewController.removeSpinner(spinner: self.sv!)
        return matchingItems.count
    }
    
    /*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationSearchTableViewCell") as! stationSearchTableViewCell
        let selectedItem = matchingItems[indexPath.row].placemark
        
        let coordinates = selectedItem.coordinate
        //let loc1 = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        //let loc2 = stationsSearchViewController()
        
        //let distance = loc1.distance(from: coordGPS!)
        
        cell.labelObjectName?.text = selectedItem.name
        cell.labelObjectAddress?.text = parseAddress(selectedItem: selectedItem)
        cell.labelObjectDistance?.text = ""
        return cell
    }*/
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationSearchTableViewCell") as! stationsSearchTableViewCell
        
        if(locations.count == 0){
            cell.configureLocationCell(locationName: "Aucun résultat à afficher", location: "Toucher pour revenir à l'écran précédent", codePostal: "", ville: "", distance: "")
        }else{
            //performSearchRequest() 
            let location = locations[indexPath.row]
            // Configure the cell...
            cell.configureLocationCell(locationName: location.locationName, location: location.location, codePostal: location.codePostal, ville: location.ville, distance: location.distance)
        }
        
        return cell
    }
}

extension StationsSearchTableViewController {
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let station = Station()
        
        if (locations.count == 0){  // Aucun résultat
            
            station.nomStation = ""
            station.adresse = ""
            station.codePostal = ""
            station.ville = ""
            station.coordGPS = ""
            
        }else{
            
            let selectedLocation = locations[indexPath.row]
            station.nomStation = selectedLocation.locationName
            station.adresse = selectedLocation.location
            station.codePostal = selectedLocation.codePostal
            station.ville = selectedLocation.ville
            station.coordGPS = selectedLocation.coordGPS
    
            /*self.addConsoVC?.onStationServiceSelected(station: station)
            self.navigationController?.popToRootViewController(animated: true)*/
            
        }
        
        // Create an instance of PlayerTableViewController and pass the variable
        /*let addConsoVC = AddConsoViewController()
        addConsoVC.station = station
        addConsoVC.car = self.car*/
        
        // Let's assume that the segue name is called playerSegue
        // This will perform the segue and pre-load the variable for you to use
        //addConsoVC.performSegue(withIdentifier: "unwindStationsVCtoAddConsoVC", sender: self)
        //self.dismiss(animated: true, completion: nil)
        /*let addConsoVC = storyboard?.instantiateViewController(withIdentifier: "consoDetail") as! AddConsoViewController
        addConsoVC.station = station
        addConsoVC.car = self.car
        self.navigationController?.dismiss(animated: true, completion: nil)*/
    }*/
}

extension UITableViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
