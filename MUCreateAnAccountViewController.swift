//
//  MUCreateAnAccountViewController.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 25/08/2015.
//  Copyright (c) 2015 Chongzheng Zhang. All rights reserved.
//

import UIKit

class MUCreateAnAccountViewController: UIViewController ,UITextFieldDelegate{

    
    @IBOutlet weak var SignUpUserName: UITextField!

    
    @IBOutlet weak var SignUpEmail: UITextField!
  
    
    @IBOutlet weak var SignUpPassword: UITextField!
    
    
    @IBOutlet weak var SignUpConfirmPassword: UITextField!

    
    @IBAction func CreateAnAccount(sender: AnyObject) {
        
        if (SignUpUserName.text!.isEmpty) { //Check whether the username is empty
            
            let alert = UIAlertView()
            alert.title = "No UserName"
            alert.message = "You have to fill the UserName!"
            alert.addButtonWithTitle("OK")
            alert.show()
            
        }
        else if (SignUpEmail.text!.isEmpty){ //Check whether the Email is empty
            
            
            let alert = UIAlertView()
            alert.title = "No Email"
            alert.message = "You have to fill the Email!"
            alert.addButtonWithTitle("OK")
            alert.show()
            
            
        }
        else if (SignUpPassword.text!.isEmpty){ //Check whether the Email is empty
            
            
            let alert = UIAlertView()
            alert.title = "No Password"
            alert.message = "You have to fill the Password!"
            alert.addButtonWithTitle("OK")
            alert.show()
            
            
        }
        else if (SignUpConfirmPassword.text!.isEmpty){ //Check whether the Email is empty
            
            
            let alert = UIAlertView()
            alert.title = "No Confirm Password"
            alert.message = "You have to fill the Confirm Password!"
            alert.addButtonWithTitle("OK")
            alert.show()
            
            
        }
        else
        {
            if (SignUpPassword.text != SignUpConfirmPassword.text){  //Check whether the comfirm password is different from password. 

                
            let alert = UIAlertView()
            alert.title = "Unmatched Password"
            alert.message = "Confirm Password is different from Password!"
            alert.addButtonWithTitle("OK")
            alert.show()
                
            }
            else
            {
                /* Get stored device token. */
                let defaults = NSUserDefaults.standardUserDefaults()   //Set defaults to save and get data.
                let deviceTokenConstant = "deviceTokenKey"   //Set constant for getting device token.
                let deviceToken = defaults.objectForKey(deviceTokenConstant) as! String?
             
            //    let deviceToken = "1234"  //Just for debug.
                
                /* send sign up data to web server. */
                let url: NSURL = NSURL(string: "http://meetupappsupportedserver.com/createaccount.php")!
     
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)

                request.HTTPMethod = "POST";  //Post to PHP
                
                // Compose a query string
                let postString: NSString = "sDeviceToken=\(deviceToken!)&sUsername=\(SignUpUserName.text!)&sEmail=\(SignUpEmail.text!)&sPassword=\(SignUpPassword.text!)"
                

                
                //Set the sign up information as the HTTP body
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                
                let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion:true)!
                let postLength:NSString = String( postData.length )
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                let session = NSURLSession.sharedSession()
                
                let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                    
                    
                    print("Response: \(response)")
                    let responseData = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                    print("Body: \(responseData)")
                    
                    print("error: \(error)")
                
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    
                    NSLog("Response code: %ld", statusCode);
                    
                    if (statusCode >= 200 && statusCode < 300)
                    {
                        let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //    var error: NSError?
                        
                        let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                        
                        print(jsonData.description )
                        
                        let success:NSString = jsonData.valueForKey("Success") as! NSString
                        
                        NSLog("Success ==> %@", success);
                        
                        if(success == "1")
                        {
                            NSLog("Sign Up Succeed");
                            
                            let title = "Success!"
                            let message = "Create an account successfully!"
                            sendAlertView(title, message: message)
        
                        }
                        else
                        {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            
                            let title = "Sign Up Failed!"
                            let message = error_msg as String
                            sendAlertView(title, message: message)
        
                        }
                        
                    }
                    else
                    {
                        let title = "Sign Up Failed!"
                        let message = "Connection Failed"
                        sendAlertView(title, message: message)
                        

                    }
     
                
                })
                
                task.resume()
            }
            
        }
         
        
    }
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.SignUpUserName.delegate = self;
        self.SignUpEmail.delegate = self;
        self.SignUpPassword.delegate = self;
        self.SignUpConfirmPassword.delegate = self;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
