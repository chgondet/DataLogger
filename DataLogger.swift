//
//  DataLogger.swift
//  Legende
//
//  Created by Christophe on 11/09/2015.
//  Copyright © 2015 Christophe. All rights reserved.
//
import 	CoreGraphics
import Foundation
import AVFoundation
import UIKit



struct serveur {
    var service : String
    var port : Int
    var address : String
    var tag : String
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        var retVal = ""
        if yearsFrom(date)   > 0 { retVal += "\(yearsFrom(date))a "   }
        if (monthsFrom(date) % 12)  > 0 { retVal += "\(monthsFrom(date) % 12)m "  }
        if (weeksFrom(date) % 4)  > 0 { retVal += "\(weeksFrom(date) % 4)sem "   }
        if (daysFrom(date) % 7) > 0 { retVal += "\(daysFrom(date) % 7)j "    }
        if (hoursFrom(date) % 24)   > 0 { retVal += "\(hoursFrom(date) % 24)h "   }
        if (minutesFrom(date) % 60 ) > 0 { retVal += "\(minutesFrom(date) % 60 )min " }
        if (secondsFrom(date) % 60 ) > 0 { retVal += "\(secondsFrom(date) % 60 )s" }
        return retVal
    }
}


class DataLogger {
    
    var myVC : ViewController?
    let  MaxPoints = 1000
    var ratio: Double = Double(1)

    
    let dateFormatter = NSDateFormatter()
    let myDateFormat = "yyyy-MM-dd HH:mm:ss"

    
    
    var values: [CGFloat]=[]
    var stopDate : NSDate = NSDate ()
    var startDate : NSDate = NSDate (timeIntervalSinceNow: -3601)
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var myServeur = serveur(service: "/main/system/webdev/TestHisto/getHisto", port: 8088, address: "localhost", tag:"Temp")
    
    
    var jsonObject: [String: AnyObject]!
    
    
    var audioRecorder : AVAudioRecorder!
    
    var url: NSURL?
    
    func record(){
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        do {
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "handleInterruption:",
                name: AVAudioSessionInterruptionNotification,
                object: nil)
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            
        }
        catch
        {
            print("impossible")
            
        }
        
        
        let documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
        let str =  documents.stringByAppendingPathComponent("recordTest.caf")
        url = NSURL.fileURLWithPath(str as String)
        
        let recordSettings : [String : AnyObject] = [AVFormatIDKey : NSNumber(unsignedInt:kAudioFormatLinearPCM),
            AVSampleRateKey:44100.0,
            AVNumberOfChannelsKey:2,AVEncoderBitRateKey:12800,
            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue
            
        ]
        
        print("url : \(url)")
        
        do {
            
        audioRecorder = try AVAudioRecorder(URL:url!, settings: recordSettings)
            audioRecorder.record()
        }
        catch let e as NSError{
            print(e.localizedDescription)

        }
        
            
        
    }
        
    func stopRecording(){
        audioRecorder.stop()
        //if let filePath = NSBundle(URL: url!){
            //var filePath = NSBundle.mainBundle().pathForResource("recordTest", ofType:"caf")
            if let data = NSData(contentsOfURL: url!){
                let pointer = UnsafePointer<UInt32>(data.bytes)
                let count = data.length / 4
                // Get our buffer pointer and make an array out of it
                let buffer = UnsafeBufferPointer<UInt32>(start:pointer, count:count)
                let array = [UInt32](buffer)
                
                for u in array{
                    print ("Value \(u)")
                }
                
            }
            
            // Have to cast the pointer to the right size
            
      //  }
        
        
    }
    
    func handleInterruption(notification: NSNotification){
        /* Audio Session is interrupted. The player will be paused here */
        
        let interruptionTypeAsObject =
        notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSNumber
        
        let interruptionType = AVAudioSessionInterruptionType(rawValue:
            interruptionTypeAsObject.unsignedLongValue)
        
        print ("Interruption")
        if let type = interruptionType{
            print (type)
            if type == .Ended{
                
                /* resume the audio if needed */
                
            }
        }
    }
    
    func sinus(){
        for i in 0...MaxPoints{
            values[i] = (CGFloat)(50.0 + 30.0 * sin((Double)(i) * ratio / 20.0 *  M_PI) )
        }
        
    }
    func expo(){
        for i in 0...MaxPoints{
            values[i] = 100.0 - (CGFloat)(20.0 + 60.0 * 1.0 / exp((Double(i) * ratio ) / 20.0 ) )
        }
        
    }
    
    func mixte(){
        for i in 0...MaxPoints{
            values[i] = 100.0 - (CGFloat)(20.0 + 60.0 * 1.0 / exp((Double(i) * ratio ) / 20.0 ) ) + (CGFloat)(50.0 * sin((Double(i) * ratio ) / 5.0 *  M_PI)  / exp((Double(i) * ratio ) / 10.0  ))
        }
        
    }
 
    func randValues(){
        let rbase = 30 + Double (arc4random_uniform(40)) + 1
        let r1 = Double(arc4random_uniform(50)) + 1
        let r2 = Double(arc4random_uniform(20)) + 1
        let r3 = Double(arc4random_uniform(10)) + 1
        let r4 = Double(arc4random_uniform(20)) + 5
        for i in 0...MaxPoints{
            values[i] = 100.0 - ((CGFloat)(rbase + r1 * 1.0 / exp((Double(i) * ratio ) / r2 ) ) + (CGFloat)(50.0 * sin((Double(i) * ratio ) / r3 *  M_PI)  / exp((Double(i) * ratio ) / r4  )))
        }
        
    }
    
    init(){
        
        ratio = Double(100.0 / Double(MaxPoints))
        
        for _ in 0...MaxPoints {
            values.append(0)
        }
        
        dateFormatter.dateFormat = myDateFormat
    }
    convenience init(vc : ViewController){
        self.init()
        myVC = vc
        
    }
    
    func getSavedServeurValue(){
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
        
        if let t = defaults.stringForKey("tag"){
            myServeur.tag =  t
        }

    }
    
    func setNewServeurValue(address: String!, port: Int, service: String!, tag: String!){
        myServeur.address = address
        myServeur.port = port
        myServeur.service = service
        myServeur.tag = tag
        let defaults = NSUserDefaults.standardUserDefaults()
        
       // print("Nouvelle valeurs :\(myServeur)")
        
        defaults.setObject(myServeur.address, forKey: "address")
        defaults.setInteger(myServeur.port, forKey: "port")
        defaults.setObject(myServeur.service, forKey: "service")
        defaults.setObject(myServeur.tag, forKey: "tag")
        
        
    }
    
    func handler (data: NSData?, response: NSURLResponse?, error: NSError?) {
        //handle what you need
        if error != nil{
            print("Response: \(response)")
            showMessage("Report",Message:"Server unreachable",Button:"Ok")
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
            showMessage("Report",Message:String(MaxPoints+1) + " values sent",Button:"Ok")
            print("Response: \(response)")
        }
    }
    
    func showMessage(Title:String, Message:String, Button:String){
        if let vc = myVC {
            vc.showMessage(Title, Message: Message, Button: Button)
            
        }

    }
    

    func setJsonData(){
        
        var savedData = [String: AnyObject]()
        var PointData = [String: AnyObject]()
        
        for i in 0...MaxPoints{
            let tIndex = NSTimeInterval(Double(stopDate.secondsFrom(startDate)) / Double(MaxPoints) * Double(i))
            
            let dt : NSDate = startDate.dateByAddingTimeInterval(tIndex)
            
            PointData["Date"] = dateFormatter.stringFromDate(dt)
        
            PointData["Value"] = String(values[i])
            savedData["Data " + String(i)] = PointData
            PointData.removeAll()
        }
        
        
        
        jsonObject = [
            "Type": "DataLog",
            "Tag" : myServeur.tag,
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
        //print (jsonObject)
        
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
