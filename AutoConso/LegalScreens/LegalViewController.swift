//
//  LegalViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 07/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import WebKit

class LegalViewController: UIViewController, WKUIDelegate {

    
    
    @IBOutlet weak var myWeb: WKWebView!
    @IBAction func btnRefuser(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    @IBAction func btnAccepter(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        myWeb = WKWebView(frame: .zero, configuration: webConfiguration)
        myWeb.uiDelegate = self
        myWeb.sizeToFit();
        myWeb.contentMode = UIViewContentMode.scaleToFill;
        view = myWeb
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadHtmlFile()
        
        /*let requestObj = NSURLRequest(url: url! as URL);
        myWeb.load(requestObj as URLRequest);*/
        // Do any additional setup after loading the view.
    }
    
    func loadHtmlFile() {
        let url = Bundle.main.url(forResource: "autoconso_cgu_fr", withExtension:"html")
        let request = NSURLRequest(url: url!)
        
        //UIViewContentModeScaleAspectFit;
        myWeb.load(request as URLRequest)
    }
    // Do any additional setup after loading the view, typically from a nib.
    /*let localfilePath = Bundle.mainBundle().URLForResource("home", withExtension: "html");
    let myRequest = NSURLRequest(URL: localfilePath!);
    mywe.loadRequest(myRequest);*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
