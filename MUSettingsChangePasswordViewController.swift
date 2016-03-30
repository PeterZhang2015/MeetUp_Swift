//
//  MUSettingsChangePasswordViewController.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 15/10/2015.
//  Copyright © 2015 Chongzheng Zhang. All rights reserved.
//

import UIKit

class MUSettingsChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordAgain: UITextField!

    @IBAction func updateForChangePasswordVC(sender: AnyObject) {
        
    }
    
    /* Override shouldPerformSegueWithIdentifier in order to check validation.  */
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        
        /* Check the validation of meeting name. */
        if identifier == "SegueFromChangePasswordVC" {
            
            /*Get AppDelegate. */
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            
            if (currentPassword.text!.isEmpty) { //Check whether the Current Password is empty
                let alert = UIAlertView()
                alert.title = "No Current Password"
                alert.message = "You have to fill the Current Password!"
                alert.addButtonWithTitle("OK")
                alert.show()

     
            }
                
            else if (newPassword.text!.isEmpty){ //Check whether the new password is empty

                let alert = UIAlertView()
                alert.title = "No New Password"
                alert.message = "You have to fill the New Password!"
                alert.addButtonWithTitle("OK")
                alert.show()
                
            }
                    
            else if (newPasswordAgain.text!.isEmpty){ //Check whether the new password again is empty
    
                let alert = UIAlertView()
                alert.title = "No New Password Again"
                alert.message = "You have to fill the New Password Again!"
                alert.addButtonWithTitle("OK")
                alert.show()
    
            }
                    
            else if (newPassword.text != newPasswordAgain.text){ //Check whether the new password again is the same as the new password
    
                let alert = UIAlertView()
                alert.title = "Different New Password"
                alert.message = "New Password Again must be the same as the New Password!"
                alert.addButtonWithTitle("OK")
                alert.show()
 
            }
                    
            else
            {

                let myEmail = appDelegate.accountInfo!.Email
                let url: NSURL = NSURL(string: "http://192.168.0.23.xip.io/~chongzhengzhang/php/changepassword.php")!  // the web link of the provider.
                let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
                request.HTTPMethod = "POST";  //Post to PHP in provider.
                
                // Compose change password information with user email, current password, and new password.
                let postString: NSString = "sEmail=\(myEmail)&sCurrentPassword=\(currentPassword.text!)&sNewPassword=\(newPassword.text!)"
                
                //Set the change password information as the HTTP body
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
                        
                        let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                        
                        let success:NSString = jsonData.valueForKey("Success") as! NSString
                        
                        NSLog("Success ==> %@", success);
                        
                        if(success == "1")
                        {
                            /*Show the successful result. */
                            NSLog("Change Password Successfully");
           
                            let title = "Success!"
                            let message = "Change Passsword Successfully!"
                            sendAlertView(title, message: message)

                        }
                        else
                        {
                            var error_msg:NSString
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            }
                            else {
                                
                                error_msg = "Unknown Error"
                                
                            }
                            
                            let title = "Failed To Change Passsword!"
                            let message = error_msg as String
                            sendAlertView(title, message: message)
 
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            /*Set the current view controller as the main tab bar of the application. */
                            appDelegate.window?.rootViewController = appDelegate.tabBarController
                            //self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
  
                    })
                    
                    task.resume()
            }


        }
        
        
        // by default, transition
        return true
    }

 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
