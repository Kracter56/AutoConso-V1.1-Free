//
//  CarsViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 19/07/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift

class CarsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var realm:Realm?
    @IBOutlet weak var tableViewCar: UITableView!
    @IBOutlet weak var labelNoCarData: UILabel!
    @IBOutlet weak var noItemsView: UIView!
    
    var data:Results<Car>!
    var carObjects:[Car] = []
    var isEditingMode = false
    
    func listCars(){
        print("CarsViewController:realmInit")
        let realm = try! Realm()
        self.data = realm.objects(Car.self)
        self.carObjects = Array(self.data)
        self.tableViewCar.setEditing(false, animated: true)
        self.tableViewCar.reloadData()
        print("listCars")
    }
    /*
 Notes pour les listes déroulantes :
 - Penser à lier l'objet UIPickerView au Controller via le storyboard !
 - Etendre le controller avec UIPickerViewDelegate, UIPickerViewDataSource
 - Lier le delegate et le datasource au self pickerView dans le viewDidLoad
 */
    var db: OpaquePointer? // Définition de la base de données
    var carItem = [Car]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CarsViewController -> viewDidLoad")
        print("Realm DB : \(Realm.Configuration.defaultConfiguration.fileURL!)")
        listCars()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadView), name: NSNotification.Name(rawValue: "loadList"), object: nil)
    }
    
    func loadList(notification: NSNotification){
        //load data here
        print("loadList")
        listCars()
    }
    
    @IBAction func didClickEditCar(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.tableViewCar.setEditing(isEditingMode, animated: true)
    }
    
    
    /* Suppression d'un élément par son id */
    func delete(id: Int) -> Void {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }   


    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Supprimer") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let listToBeDeleted = self.carObjects[indexPath.row]
            
            let deleteCarAlert = UIAlertController(title: "Suppression véhicule", message: "Etes-vous sûr de vouloir supprimer le véhicule sélectionné ?", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteCarAlert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (action: UIAlertAction!) in
                print("L'utilisateur a décidé de supprimer un véhicule")
                try! self.realm!.write{
                    self.realm!.delete(listToBeDeleted)
                    self.toastMessage("Le véhicule a bien été supprimée de la base")
                    self.listCars()
                }
            }))
            
            deleteCarAlert.addAction(UIAlertAction(title: "Non", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            self.present(deleteCarAlert, animated: true, completion: nil)
            
            
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
         
             // Editing will go here
             let listToBeUpdated = self.carObjects[indexPath.row]
             //self.displayAlertToAddTaskList(listToBeUpdated)
         
         }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("cars = ",self.carObjects.count)
        
        if self.carObjects.count == 0 {
            self.tableViewCar.setEmptyMessage("Vous n'avez saisi aucun véhicule pour le moment")
        } else {
            self.tableViewCar.restore()
        }
        
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

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data
            let id = indexPath.row
            delete(id: id)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        print("CarsVC : viewWillAppear")
        listCars()
    }
    
    /*func builtAlert(titre: String, message: String) -> Bool {
        let alert = UIAlertController(title: titre, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Non", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }*/
    

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
        super.prepare(for: segue, sender: sender)
        print("segueId",segue.identifier!)
        switch(segue.identifier ?? "") {
            case "AddCar":
                print("Adding a new car.")
            
            case "showCarDetail":
                
                guard let editCarViewController = segue.destination as? EditCarViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                guard let selectedCarCell = sender as? CarTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = tableViewCar.indexPath(for: selectedCarCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                let selectedCar = self.carObjects[indexPath.row]
                //editCarViewController.carItem = selectedCar
                print("CarsViewController -> SelectedCar",selectedCar.idCar)
                
                break
            
            case "modifyCarDetail":
            
                guard let editCarViewController = segue.destination as? UINavigationController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                guard let selectedCarCell = sender as? CarTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = tableViewCar.indexPath(for: selectedCarCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                let selectedCar = self.carObjects[indexPath.row]
                //(editCarViewController.viewControllers[0] as? EditCarViewController)!.carItem = selectedCar
                print("CarsViewController -> SelectedCar",selectedCar.idCar)
            
                break
            
        default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        break
        }
    }
}

/*extension CarsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.marque! + " " + car.modele!
        cell.detailTextLabel?.text = car.pseudo
        return cell
    }
}*/
extension UIViewController {
    func showToast(message: String) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.blue
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        self.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([a1, a2, a3, a4])
        
        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75)
        self.view.addConstraints([c1, c2, c3])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    
    func toastMessage(_ message: String){
        guard let window = UIApplication.shared.keyWindow else {return}
        let messageLbl = UILabel()
        messageLbl.text = message
        messageLbl.textAlignment = .center
        messageLbl.font = UIFont.systemFont(ofSize: 12)
        messageLbl.textColor = .white
        messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let textSize:CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)
        
        messageLbl.frame = CGRect(x: 20, y: window.frame.height - 90, width: labelWidth + 30, height: textSize.height + 20)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = messageLbl.frame.height/2
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            UIView.animate(withDuration: 1, animations: {
                messageLbl.alpha = 0
            }) { (_) in
                messageLbl.removeFromSuperview()
            }
        }
    }
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
    //MARK: - Navigation
    
}

