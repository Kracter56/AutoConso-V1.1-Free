//
//  fileReader.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 16/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit


class fileReader {
    
    //MARK: Outlets and properties
    /*var  data:[[String:String]] = []
    var  columnTitles:[String] = []
    
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func reportData(sender: UIButton) {
        printData()
    }
    @IBAction func resetData(sender: UIButton) {
        textView.text = "Nope, no Pizza here"
    }
    @IBAction func readData(sender: UIButton) {
        textView.text = readDataFromFile(file: "data")
    }
    @IBAction func writeData(sender: UIButton) {
        if writeDataToFile(file: "data") {
            print("data written")
        } else {
            print("data not written")
        }
    }
    //MARK: - Instance methods
    
    //MARK: CSV Functions
    func cleanRows(file:String)->String{
        //use a uniform \n for end of lines.
        var cleanFile = file
        cleanFile = cleanFile.stringByReplacingOccurrencesOfString("\r", withString: "\n")
        cleanFile = cleanFile.stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
        return cleanFile
    }
    
    func getStringFieldsForRow(row:String, delimiter:String)-> [String]{
        return row.components(separatedBy: delimiter)
    }
    
    func convertCSV(file:String){
        let rows = cleanRows(file: file).components(separatedBy: "\n")
        if rows.count > 0 {
            data = []
            columnTitles = getStringFieldsForRow(row: rows.first!,delimiter:",")
            for row in rows{
                let fields = getStringFieldsForRow(row: row,delimiter: ",")
                if fields.count != columnTitles.count {continue}
                var dataRow = [String:String]()
                for (index,field) in fields.enumerated(){
                    dataRow[columnTitles[index]] = field
                }
                data += [dataRow]
            }
        } else {
            print("No data in file")
        }
    }
    
    func printData(){
        convertCSV(file: textView.text)
        var tableString = ""
        var rowString = ""
        print("data: \(data)")
        for row in data{
            rowString = ""
            for fieldName in columnTitles{
                guard let field = row[fieldName] else{
                    print("field not found: \(fieldName)")
                    continue
                }
                rowString += field + "\t"
            }
            tableString += rowString + "\n"
        }
        textView.text = tableString
    }
    
    //MARK: Data reading and writing functions
    func writeDataToFile(file:String)-> Bool{
        // check our data exists
        guard let data = textView.text else {return false}
        print(data)
        //get the file path for the file in the bundle
        // if it doesnt exist, make it in the bundle
        var fileName = file + ".txt"
        if let filePath = Bundle.main.path(forResource: file, ofType: "txt"){
            fileName = filePath
        } else {
            fileName = Bundle.main.bundlePath + fileName
        }
        
        //write the file, return true if it works, false otherwise.
        do{
            try data.write(toFile: fileName, atomically: true, encoding: String.Encoding.utf8 )
            return true
        } catch{
            return false
        }
    }
    
    func readDataFromFile(file:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: file, ofType: "txt")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath, usedEncoding: String.Encoding.utf8)
            return contents
        } catch {
            print ("File Read Error")
            return nil
        }
    }*/
    
}
