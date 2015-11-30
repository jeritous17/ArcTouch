//
//  ViewController.swift
//  ArcTouch
//
//  Created by Jeronimo Perez on 30/11/15.
//  Copyright © 2015 Jeronimo Perez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var arrayLongName: [String] = []
    var arrayId: [Int] = [];
    var segueIndexRow = 0;
    
    let textCellIdentifier = "TextCell"
    
    @IBOutlet weak var editText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickSearch(sender: UIButton) {
        //delete Data
        self.arrayLongName.removeAll();
        self.arrayId.removeAll()
        tableView.reloadData()
        
        //search
        dispatch_async(
            dispatch_get_main_queue(), {
                self.descargarDatos(self.editText.text!)
    
        })
        
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayLongName.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let row = indexPath.row
        cell.textLabel?.text = arrayLongName[row] as! String
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        self.segueIndexRow = row;
    }
    
    
    // MARK: - Download Data
    
    private func descargarDatos(searchWord: NSString){
        
        let username = "WKD4N7YMA1uiM8V"
        let password = "DtdTtzMLQlA0hk2C1Yi5pLyVIlAQ68"
        let search = searchWord

        //create login
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0));
        
        //create request with params
        let string = ["params":["stopName" : "%\(search)%"]]
        var dataString:NSData = NSData()
        do{
            dataString = try NSJSONSerialization.dataWithJSONObject(string, options: .PrettyPrinted)
        }catch{
            
        }

        //Url to use
        let url = NSURL(string: "https://api.appglu.com/v1/queries/findRoutesByStopName/run")
        
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
                
                //Working with the response
                if let rows = jsonData["rows"] as? [AnyObject] {
                    for row in rows {
                        if let longName = row["longName"] as? String{
                            self.arrayLongName += [longName]; //add data
                        }
                        if let id = row["id"] as? Int{
                            self.arrayId += [id]; //add data
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData() //reload table
                    })
                    
                    
                    
                }

            }else{
                print(error)
            }
        }
        task.resume()
        
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue", let destination = segue.destinationViewController as? SecondViewController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPathForCell(cell) {
                var id = arrayId[indexPath.row]
                destination.id = id; //to send the id of the route
                destination.nameVia = arrayLongName[indexPath.row] //send the name of via
            }
        }
    }

}

