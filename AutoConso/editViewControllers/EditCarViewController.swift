//
//  EditCarViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 24/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation

class EditCarViewController: UITableViewController  {
    
    //var carItem: Car!
    let realm = try! Realm()
    var data:Results<Car>!
    var car:[Car] = []

    @IBOutlet weak var imageViewVehicule: UIImageView!
    @IBOutlet weak var editFieldCarMarque: UITextField!
    @IBOutlet weak var editFieldCarModele: UITextField!
    @IBOutlet weak var editFieldCarPseudo: UITextField!
    @IBOutlet weak var editFieldDateAchat: UITextField!
    @IBOutlet weak var editFieldKilometrage: UITextField!
    @IBOutlet weak var editFieldSerialNumber: UITextField!
    @IBOutlet weak var editFieldNotes: UITextField!
    
    @IBAction func btnModifyCarInfos(_ sender: UIBarButtonItem) {
        print("EditCarViewController:realmInit")
        
        let carItem = self.car[0]
        
        let dateFormatter = DateFormatter()
        let dateFormat = "dd/MM/yyyy"
        dateFormatter.dateFormat = dateFormat
        let dateAchat = dateFormatter.date(from: (editFieldDateAchat?.text!)!)
        
        try! realm.write {
            
            let imageVehicule = UIImagePNGRepresentation(imageViewVehicule.image!) as NSData?
            /*let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/YYYY"
            cell.textFieldDateRavitaillement?.text = formatter.string(from: self.result[indexPath.row].dateConso)*/
            
            carItem.dateAchat = dateAchat!
            carItem.kilometrage = Int((editFieldKilometrage?.text)!)!
            carItem.marque = (editFieldCarMarque?.text)!
            carItem.modele = (editFieldCarModele?.text)!
            carItem.pseudo = (editFieldCarPseudo?.text)!
            carItem.numeroSerie = (editFieldSerialNumber?.text)!
            carItem.commentaire = (editFieldNotes?.text)!
            carItem.data = imageVehicule
            
            /* Ajouter la voiture dans la base de données */
            
            realm.add(car)
        }
        
        self.toastMessage("La voiture "+(carItem.modele)+" a bien été modifiée")
        
        /* Rafraichir la liste des voitures avant affichage */
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnCloseCar(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChangerImage(_ sender: Any) {
            
        PhotoChooser.shared.showAttachmentActionSheet(vc: self)
        PhotoChooser.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.imageViewVehicule.image = image
        }
    }
    /*@IBOutlet weak var editFieldDateImmat: UITextField!
    @IBOutlet weak var editFieldNumeroImmat: UITextField!
    @IBOutlet weak var editFieldPressionPneus: UITextField!
    @IBOutlet weak var editFieldReservoir: UITextField!
    @IBOutlet weak var editFieldCommentaire: UITextField!
    @IBOutlet weak var editFieldCarInfo: UITextField!*/
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        self.data = realm.objects(Car.self)
        self.car = Array(self.data)
        
        let carItem = self.car[0]
        
        print("EditCarViewController -> reception",carItem.pseudo)
        
        let carImage = UIImage(data: carItem.data! as Data)
        
        imageViewVehicule.image = carImage
        editFieldCarMarque.text? = carItem.marque
        editFieldCarModele.text? = carItem.modele
        editFieldCarPseudo.text? = carItem.pseudo
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        editFieldDateAchat.text? = formatter.string(from: carItem.dateAchat)
        editFieldKilometrage.text? = carItem.kilometrage.description
        editFieldSerialNumber.text? = carItem.numeroSerie
        
        /*editFieldDateImmat.text? = carItem.dateImmat
        editFieldNumeroImmat.text? = carItem.immatriculation
        editFieldPressionPneus.text? = carItem.pressionPneu
        editFieldReservoir.text? = carItem.reservoir.description
        editFieldCommentaire.text? = carItem.commentaire
        editFieldCarInfo.text? = carItem.motorisation*/
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
