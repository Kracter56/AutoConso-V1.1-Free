//
//  carsPanelVC.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 17/11/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift

class carsPanelVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

	var data:Results<Car>!
    var carObjects:[Car] = []
	
	let tableView = UITableView()
	var safeArea: UILayoutGuide!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		view.backgroundColor = .darkGray
		safeArea = view.layoutMarginsGuide
		
		listCars()
		setupTableView()
        // Do any additional setup after loading the view.
    }
    
	func setupTableView() {
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
		tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
			
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.reloadData()
	}
		
	func listCars(){
		print("CarsViewController:realmInit")
		let realm = try! Realm()
		self.data = realm.objects(Car.self)
		self.carObjects = Array(self.data)
	//		self.tableView.setEditing(false, animated: true)
	//        self.tableView.reloadData()
		print("listCars")
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.carObjects.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarTableViewCell
        
        // Configure the cell...
        let carName = self.carObjects[indexPath.row].marque + " " + self.carObjects[indexPath.row].modele
        cell.CarMarque?.text = carName
        cell.CarPseudo?.text = self.carObjects[indexPath.row].pseudo
        cell.CarImmatriculation?.text = self.carObjects[indexPath.row].immatriculation
        let carImage = UIImage(data: self.carObjects[indexPath.row].data! as Data)
        cell.CarImage?.image = carImage
        //cell.CarImage?.image = self.carObjects[indexPath.row].image
        
        return cell
    }
	
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//		cell.textLabel?.text = self.carObjects[indexPath.row].pseudo
//		cell.detailTextLabel?.text = self.carObjects[indexPath.row].pseudo
//		return cell
//	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension carsPanelVC: UITableViewDataSource {
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return self.carObjects.count
//	}
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//	  let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//		cell.textLabel?.text = self.carObjects[indexPath.row].pseudo
//	  return cell
//	}
//}
