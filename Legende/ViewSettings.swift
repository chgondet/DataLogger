//
//  ViewSettings.swift
//  Legende
//
//  Created by Christophe on 11/09/2015.
//  Copyright © 2015 Christophe. All rights reserved.
//

import UIKit
import Foundation

class ViewSettings : UIViewController{
    
    var datalogger : DataLogger! = nil
    
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfPort: UITextField!
    @IBOutlet weak var tfService: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        datalogger = appDelegate.datalogger
        tfAddress.text = datalogger.myServeur.address
        tfPort.text = String (datalogger.myServeur.port)
        tfService.text = datalogger.myServeur.service
        
    }
    
    @IBAction func backPush(sender: AnyObject) {
        let p: Int =  Int(tfPort.text!)!
        
        datalogger.setNewServeurValue(tfAddress.text,port:p ,service: tfService.text)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("Coding Explorer", forKey: "userNameKey")
        
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("MainView")
        self.presentViewController(nextViewController, animated: true, completion: nil)
    }
    
    
}