//
//  DataLogger.swift
//  Legende
//
//  Created by Christophe on 11/09/2015.
//  Copyright © 2015 Christophe. All rights reserved.
//
import 	CoreGraphics
import Foundation

struct serveur {
    var service : String
    var port : Int
    var address : String
}


class DataLogger {

    let dateFormatter = NSDateFormatter()
    let myDateFormat = "yyyy-MM-dd HH:mm:ss"

    var values: [CGFloat]=[]
    var stopDate : NSDate = NSDate ()
    var startDate : NSDate = NSDate (timeIntervalSinceNow: 3600)
    
    var jsonObject: [String: AnyObject]!
    
    var myServeur = serveur(service: "/main/system/webdev/project/resource_name", port: 8088, address: "localhost")
    
    func sinus(){
        for i in 0...100{
            values[i] = (CGFloat)(50.0 + 30.0 * sin((Double)(i) / 20.0 *  M_PI) )
        }
        
    }
    func expo(){
        for i in 0...100{
            values[i] = 100.0 - (CGFloat)(20.0 + 60.0 * 1.0 / exp((Double)(i) / 20.0 ) )
        }
        
    }
    
    func mixte(){
        for i in 0...100{
            values[i] = 100.0 - (CGFloat)(20.0 + 60.0 * 1.0 / exp((Double)(i) / 20.0 ) ) + (CGFloat)(50.0 * sin((Double)(i) / 5.0 *  M_PI)  / exp((Double)(i) / 10.0  ))
        }
        
    }
 
    func randValues(){
        let r1 = Double(arc4random_uniform(60)) + 1
        let r2 = Double(arc4random_uniform(20)) + 1
        let r3 = Double(arc4random_uniform(10)) + 1
        let r4 = Double(arc4random_uniform(20)) + 5
        for i in 0...100{
            values[i] = 100.0 - ((CGFloat)(20.0 + r1 * 1.0 / exp((Double)(i) / r2 ) ) + (CGFloat)(50.0 * sin((Double)(i) / r3 *  M_PI)  / exp((Double)(i) / r4  )))
        }
        
    }
    
    init(){
        for _ in 0...100 {
            values.append(0)
        }
        
        
        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.setLocalizedDateFormatFromTemplate(myDateFormat)

        let defaults = NSUserDefaults.standardUserDefaults()

        if let t =  defaults.stringForKey("address"){
            myServeur.address  = t
        }
        
        myServeur.port = defaults.integerForKey("port")
        
        if myServeur.port == 0{
            myServeur.port = 8088
        }
        
        if let s = defaults.stringForKey("service"){
             myServeur.service =  s
        }
        
        print("Valeurs récupérées :\(myServeur)")
        
    }
    
    func setNewServeurValue(address: String!, port: Int, service: String!){
        myServeur.address = address
        myServeur.port = port
        myServeur.service = service
        let defaults = NSUserDefaults.standardUserDefaults()
        
        print("Nouvelle valeurs :\(myServeur)")
        
        defaults.setObject(myServeur.address, forKey: "address")
        defaults.setInteger(myServeur.port, forKey: "port")
        defaults.setObject(myServeur.service, forKey: "service")
        
        
    }
    
    func handler (data: NSData?, response: NSURLResponse?, error: NSError?) {
        //handle what you need
        if error != nil{
            print("Response: \(response)")
            
            if let data = data {
                do
                {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    let success = json["success"] as? Int
                    print("Succes: \(success)")
                    
                } catch let error as NSError {
                        print(error.localizedDescription)
                        let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                } catch {
                    let error: NSError = NSError(domain: "<Your domain>", code: 1, userInfo: nil)
                    print(error.localizedDescription)
                    

                }
            }
        } else{
            print("Response: \(response)")
        }
    }

    func setJsonData(){
        
        var savedData = [String: AnyObject]()
        var PointData = [String: AnyObject]()
        
        for i in 0...100{
            PointData["Date"] = dateFormatter.stringFromDate(NSDate())
            
            PointData["Value"] = String(values[i])
            savedData["Data " + String(i)] = PointData
            PointData.removeAll()
        }
        
        
        
        jsonObject = [
            "Type": "DataLog",
            "Date": [
                "Send" : dateFormatter.stringFromDate(NSDate()),
                "DataStart": dateFormatter.stringFromDate(startDate),
                "DataStop": dateFormatter.stringFromDate(stopDate)
            ],
            "Data": savedData
        ]
        
    }

    func submitAction(){//parameters: Dictionary<String, String>) {
        
        //declare parameter as a dictionary which contains string as key and value combination.
 //       let parameters = ["name": "Christophe", "password": "Password"] as Dictionary<String, String>
        
        setJsonData()
        
        
        
        let valid = NSJSONSerialization.isValidJSONObject(jsonObject) // true
        print(valid)
        
        
        //create the url with NSURL
        let sURL = "http://" + myServeur.address + ":" + String(myServeur.port) + myServeur.service
        NSLog(sURL)
        
        let url = NSURL(string: sURL) //change the url
        
        let session = NSURLSession.sharedSession()
        
        //now create the NSMutableRequest object using the url object
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST" //set http method as POST
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: []) // pass dictionary to nsdata object and set it as request body
        } catch let error as NSError {
            print(error.localizedDescription)
            print("Error could not Serialyse JSON: '\(jsonObject)'")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTaskWithRequest(request, completionHandler: handler)
        
        
        task.resume()
    }
}
