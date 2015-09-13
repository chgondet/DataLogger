//
//  ViewController.swift
//  Legende
//
//  Created by Christophe on 10/09/2015.
//  Copyright © 2015 Christophe. All rights reserved.
//

import UIKit
import Foundation

import CoreGraphics


class ViewController: UIViewController {
    
    var datalogger : DataLogger! = nil
    var datePickerView:UIDatePicker = UIDatePicker()
    var dateTextField:UITextField? = nil
    let dateFormatter = NSDateFormatter()
    

    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgGrid: UIImageView!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var stopDate: UITextField!
    
    @IBOutlet weak var infoStart: UILabel!
    @IBOutlet weak var infoStop: UILabel!

    @IBOutlet weak var Slider: UISlider!
    
    @IBAction func sliderAction(sender: UISlider) {
      //  NSLog(String(sender.value))
        datalogger.stopDate = NSDate()
        datalogger.startDate = datalogger.stopDate.dateByAddingTimeInterval(Double(sender.value))
        showDate()
        
    }
    @IBAction func btnRandom(sender: UIButton) {
        datalogger.randValues()
        DrawTable(datalogger.values)
    }
    @IBAction func btnMixte(sender: UIButton) {  datalogger.mixte()
        DrawTable(datalogger.values)
    }
    @IBAction func btnExpo(sender: UIButton) {
        datalogger.expo()
        DrawTable(datalogger.values)
        
    
    }
    @IBAction func btnSinus(sender: UIButton){
        
        datalogger.sinus()
        DrawTable(datalogger.values)
        
    }
    
    
    
    
    
    @IBAction func startTextFieldEditing(sender: UITextField) {
       // datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        
        
        dateTextField = sender
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    @IBAction func datePickerEnd(sender: UITextField) {
        
    }
    @IBAction func btnSend(sender: UIButton) {
        datalogger.submitAction()
        
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        
        if (dateTextField == startDate) {
            datalogger.startDate = sender.date
        }
        else {
            datalogger.stopDate = sender.date
        }
        showDate()
        
    }
    
    func showDate(){
        startDate.text = dateFormatter.stringFromDate(datalogger.startDate)
        stopDate.text = dateFormatter.stringFromDate(datalogger.stopDate)
        infoStart.text = dateFormatter.stringFromDate(datalogger.startDate)
        infoStop.text = dateFormatter.stringFromDate(datalogger.stopDate)
        
        
    }
    @IBAction func goToSettings(sender: AnyObject) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("settingsView")
        self.presentViewController(nextViewController, animated: true, completion: nil)
        
    }
   
   
    var lastX : Int = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
         datalogger = appDelegate.datalogger
        
        // Do any additional setup after loading the view, typically from a ni
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
       showDate()
        
       // DrawGrid()
       // DrawTable(datalogger.values)

    }
    
    override func viewDidAppear(animated: Bool) {
        DrawTable(datalogger.values)
    }
    
    func DrawTable (vals : [CGFloat]){
       // print (values)
       // NSLog("Largeur %d, Longueur %d",(Int)(imgView.frame.height),(Int)(imgView.frame.width))
        UIGraphicsBeginImageContext(imgView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(context, CGLineCap.Round )
        CGContextSetLineWidth(context, 2)
        CGContextSetRGBStrokeColor(context,0.7, 0.7, 1.0, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextMoveToPoint(context,0,imgView.frame.height - vals[0] / 100.0 *  imgView.frame.height)
        for i in 1...100{
            CGContextAddLineToPoint(context, (CGFloat)(i) / (CGFloat)(100.0) * (imgView.frame.width) ,imgView.frame.height - vals[i] / 100.0 *  imgView.frame.height)
            
        }
        CGContextStrokePath(context)
        
        
        imgView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
       // addText()
        
    }
    
    let baseFontSize: CGFloat = 10.0
    
       
    func DrawGrid (){
        // print (values)
        // NSLog("Largeur %d, Longueur %d",(Int)(imgView.frame.height),(Int)(imgView.frame.width))
        UIGraphicsBeginImageContext(imgGrid.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineCap(context, CGLineCap.Square )
        CGContextSetLineWidth(context, 1)
        CGContextSetRGBStrokeColor(context,1, 1, 1, 1)
        CGContextSetBlendMode(context, CGBlendMode.Color)
        
        for i in 1...10{
            let x1 = (CGFloat)(0)
            let x2 = imgGrid.frame.width
            let y = (CGFloat)(imgGrid.frame.height) / 10 * (CGFloat)(i)
            
            CGContextMoveToPoint(context,x1,y)
            CGContextAddLineToPoint(context, x2 ,y  )
            CGContextStrokePath(context)
        }
        
        imgGrid.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }

    
    var location = CGPoint(x: 0, y: 0)
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        if let touch = touches.first {
            location = touch.locationInView(imgView)
          //  NSLog("Start %.2f,%.2f",location.x,location.y)
            
            if location.y<imgView.frame.height{
                let p=max(min((Int)(location.x/imgView.frame.width*100),100),0)
                let h=(CGFloat)(max(min((Int)(location.y/imgView.frame.height*100),100),0))
                datalogger.values[p]=100.0 - h
                DrawTable(datalogger.values)
                lastX = p
                }
    

        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            //location = touch.locationInView(self.view)
            //NSLog("view %.2f,%.2f",location.x,location.y)
            location = touch.locationInView(imgView)
            //NSLog("imgView %.2f,%.2f",location.x,location.y)
            if location.y<imgView.frame.height{
                let p=max(min((Int)(location.x/imgView.frame.width*100),100),0)
                let h=(CGFloat)(max(min((Int)(location.y/imgView.frame.height*100),100),0))
                datalogger.values[p]=100.0 - h
                if abs(p-lastX)>1{
                    doInterpol(p)
                }
                DrawTable(datalogger.values)
                lastX = p
            }
        }
    }
    
    func doInterpol(newPos: Int){
        
            let x1 = min(newPos,lastX)
            let x2 = max(newPos,lastX)
            let y1 = datalogger.values[x1]
            let y2 = datalogger.values[x2]
            let dY = (CGFloat)(y2-y1)
            let dX = (CGFloat)(x2-x1)
            let m = dY/dX
            
            for i in x1...x2{
                datalogger.values[i] = y1 + (m * (CGFloat)(i-x1))
            }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first {
        
            location = touch.locationInView(imgView)
        

        if location.y<imgView.frame.height{
            let p=max(min((Int)(location.x/imgView.frame.width*100),100),0)
            let h=(CGFloat)(max(min((Int)(location.y/imgView.frame.height*100),100),0))
            datalogger.values[p]=100.0 - h
            if (p-lastX)>1{
                doInterpol(p)
            }
            DrawTable(datalogger.values)
            lastX = p
        }

        DrawTable(datalogger.values)
    }
    }
    
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
  
}

