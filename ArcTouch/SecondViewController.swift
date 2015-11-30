//
//  SecondViewController.swift
//  ArcTouch
//
//  Created by Jeronimo Perez on 30/11/15.
//  Copyright © 2015 Jeronimo Perez. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    var id = 0;
    var nameVia = "";
    var route: String = "";
    var times: String = "";
    var selecter = ["WEEKDAY","SATURDAY","SUNDAY"]
    var select: Int = 0;
    @IBOutlet weak var textView_RouteStreets: UITextView!
    
    @IBOutlet weak var textView_time: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("ID \(id)")
        title = nameVia
        descargarDatosDepartures()
        descargarDatosTimes(selecter[0])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func clickSelector(sender: UISegmentedControl) {
        var search = selecter[sender.selectedSegmentIndex]
        times = ""; //clear data
        descargarDatosTimes(search)
    }
    
    
    // MARK: - Download Data
    private func descargarDatosDepartures(){
        
        let username = "WKD4N7YMA1uiM8V"
        let password = "DtdTtzMLQlA0hk2C1Yi5pLyVIlAQ68"
        
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0));
        
        // crate the request
        let string = ["params":["stopName" : id]]
        var dataString:NSData = NSData()
        do{
            dataString = try NSJSONSerialization.dataWithJSONObject(string, options: .PrettyPrinted)
        }catch{
            
        }
        
        //url
        let url = NSURL(string: "https://api.appglu.com/v1/queries/findStopsByRouteId/run")
        
        let request = NSMutableURLRequest(URL: url!)

        request.HTTPMethod = "POST";
        request.HTTPBody = dataString
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json" , forHTTPHeaderField: "Content-Type")
        request.setValue("staging" , forHTTPHeaderField: "X-AppGlu-Environment")
        
        let session = NSURLSession.sharedSession();
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if let response = response, data = data {
                let jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
                //print(jsonData)
                if let rows = jsonData["rows"] as? [AnyObject] {
                    for row in rows {
                        if let name = row["name"] as? String{
                            self.route += name + "\r\n";
                        }
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.textView_RouteStreets.text = self.route //upload route streets
                    })
                }
                
            }else{
                print(error)
            }
        }
        task.resume()
        
    }

    
    private func descargarDatosTimes(selec: String){
        
        let username = "WKD4N7YMA1uiM8V"
        let password = "DtdTtzMLQlA0hk2C1Yi5pLyVIlAQ68"
        
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0));
        
        //create the request
        let string = ["params":["stopName" : id]]
        var dataString:NSData = NSData()
        do{
            dataString = try NSJSONSerialization.dataWithJSONObject(string, options: .PrettyPrinted)
        }catch{
            
        }
        
        //url download
        let url = NSURL(string: "https://api.appglu.com/v1/queries/findDeparturesByRouteId/run")
        
        let request = NSMutableURLRequest(URL: url!)
        //añadir cabeceras pos si necesita pass
        request.HTTPMethod = "POST";
        request.HTTPBody = dataString
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json" , forHTTPHeaderField: "Content-Type")
        request.setValue("staging" , forHTTPHeaderField: "X-AppGlu-Environment")
        
        let session = NSURLSession.sharedSession();
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if let response = response, data = data {
                let jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
                //working data
                if let rows = jsonData["rows"] as? [AnyObject] {
                    for row in rows {
                        if let name = row["calendar"] as? String{
                            if(name == selec){
                                    if let time = row["time"] as? String{
                                        self.times += time + "\r\n"; //upload timetable
                                }
                            }
                        }
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.textView_time.text = self.times //actualize Times
                    })
                }
                
            }else{
                print(error)
            }
        }
        task.resume()
        
    }

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
