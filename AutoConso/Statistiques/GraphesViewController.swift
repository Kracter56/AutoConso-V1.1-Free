//
//  GraphesViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 28/08/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
//import Charts
import RealmSwift

class GraphesViewController: UIViewController {

	var idCar:String?
	var carItem:[Car] = []
	var consoItem:[Conso] = []
	var realm:Realm?
	var objToDisplay:String?
	@IBOutlet weak var barView: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let realm = try! Realm()
		//let carItem = realm.objects(Car.self).filter("idCar = %@",self.idCar).first
		//self.consoItem = realm.objects(Conso.self).filter("idCar = %@",self.idCar)
		
		//updateChartWithData()
        // Do any additional setup after loading the view.
    }
    

	/*func updateChartWithData() {
		var dataEntries: [BarChartDataEntry] = []
		for i in 0..<self.consoItem.count {
			let dataEntry = BarChartDataEntry(x: Double(i), y: Double(self.consoItem[i].carKilometrage))
			dataEntries.append(dataEntry)
		}
		let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Kilometrages")
		let chartData = BarChartData(dataSet: chartDataSet)
		self.barView = chartData
		//barView.data = chartData
	}*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
