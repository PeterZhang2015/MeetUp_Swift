//
//  MULoginViewController.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 25/08/2015.
//  Copyright (c) 2015 Chongzheng Zhang. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MULoginViewController: UIViewController ,UITextFieldDelegate ,FBSDKLoginButtonDelegate{

    @IBOutlet weak var LoginEmail: UITextField!
   
    @IBOutlet weak var LoginPassword: UITextField!
    
    @IBOutlet var fbButtonInStoryboard: FBSDKLoginButton!
    
    let defaults = NSUserDefaults.standardUserDefaults()   //Set defaults to save and get data.

    @IBAction func Login(sender: AnyObject) {
     
        if (LoginEmail.text!.isEmpty) { //Check whether the Email is empty
            
            let alert = UIAlertView()
            alert.title = "No Email"
            alert.message = "You have to fill the Email!"
            alert.addButtonWithTitle("OK")
            alert.show()
            
        }
        else if (LoginPassword.text!.isEmpty){ //Check whether the password is empty

            
            let alert = UIAlertView()
            alert.title = "No Password"
            alert.message = "You have to fill the Password!"
            alert.addButtonWithTitle("OK")
            alert.show()
            
            
        }
        else
        {
            /* Get stored device token. */
            let defaults = NSUserDefaults.standardUserDefaults()   //Set defaults to save and get data.

            let deviceToken = defaults.objectForKey(GlobalConstants.kdeviceToken) as! String?
            
            loginApplication(deviceToken, userEmail: (LoginEmail.text!), userPassword: (LoginPassword.text!), loginWithFacebook: 0)
            
            
        }


    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if (FBSDKAccessToken.currentAccessToken() == nil)
//        {
//            
//            NSLog("Facebook login successfully!")
//        }
//        else
//        {
//            
//            NSLog("Facebook login error!")
//        }
        
      //  let fbLoginButton = FBSDKLoginButton()
        fbButtonInStoryboard.readPermissions = ["public_profile", "email", "user_friends"]
        
        
        fbButtonInStoryboard.delegate = self
      //  self.view.addSubview(fbButtonInStoryboard)

        
        
        self.LoginEmail.delegate = self;
        self.LoginPassword.delegate = self;
        

        // Do any additional setup after loading the view.
    }
    
    

    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error != nil)
        {
            NSLog("error ===> %@", error.localizedDescription)
            
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            
            NSLog("Facebook login completely!")
            
            if result.grantedPermissions.contains("email")
            {

                let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name,picture.width(480).height(480)"])
            
                
                 graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
   
                    if ((error) != nil)
                    {
                        // Process error
                        NSLog("error ===> %@", error.localizedDescription)
                    }
                    else
                    {
                       // NSLog("fetched user: %@", result)
   
  
                        let userName : NSString = result.valueForKey("name") as! NSString
                        NSLog("User Name is: %@", userName)
               
                        let userEmail : NSString = result.valueForKey("email") as! NSString
                        NSLog("User Email is: %@", userEmail)
 
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.accountInfo = AccountInfo(Email: userEmail as String, Password: "")
                        
                        appDelegate.accountInfo?.Email = userEmail as String
                        
                        /* Get stored device token. */
                        let defaults = NSUserDefaults.standardUserDefaults()   //Set defaults to save and get data.

                        let deviceToken = defaults.objectForKey(GlobalConstants.kdeviceToken) as! String?
                        
                        self.loginApplication(deviceToken, userEmail: userEmail as String, userPassword: "", loginWithFacebook: 1)
               
                    }
                })// end of graphRequest.startWithCompletionHandler
            }// end of if result.grantedPermissions.contains("email")
            
  
        }

    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        NSLog("Facebook login out!")
    
    }
    
    func loginApplication(deviceToken: String!, userEmail: String, userPassword: String, loginWithFacebook: Int) {
        

        /* Send device token together with loginEmailand longinPassword to the provider through HTTP request message. */
        
        
        let url: NSURL = NSURL(string: "http://192.168.0.20.xip.io/~chongzhengzhang/php/login.php")!
        
        //let url: NSURL = NSURL(string: "http://192.168.0.20.xip.io/~chongzhengzhang/php/login.php")!  // the web link of the provider.
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        
        request.HTTPMethod = "POST";  //Post to PHP in provider.
        
        // Compose login information with device token, login Email, and loginPassword
        let postString: NSString = "devicetoken=\(deviceToken!)&sEmail=\(userEmail)&sPassword=\(userPassword)&iLoginWithFacebook=\(loginWithFacebook)"
     //   let postString: NSString = "devicetoken=\(deviceToken!)&sEmail=\(LoginEmail.text!)&sPassword=\(LoginPassword.text!)"loginWithFacebook
        
        
        //Set the login information as the HTTP body
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion:true)!
        let postLength:NSString = String( postData.length )
        request.addValue(postLength as String, forHTTPHeaderField: "Content-Length")
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            print("error: \(error)")
            
            print("Response: \(response)")
            let responseData = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            print("Body: \(responseData)")
            
            
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            NSLog("Response code: %ld", statusCode);
            
            if (statusCode >= 200 && statusCode < 300)
            {
                
                let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                
                
                let success:NSString = jsonData.valueForKey("Success") as! NSString
                
                NSLog("Success ==> %@", success);
                
                
                if(success == "1")
                {
                    /*Get AppDelegate. */
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    /*Set the bIsLogin in AppDelegate to true. */
                    appDelegate.bIsLogin = true
                    
                    /*Initial accountInfo object. */
                    appDelegate.accountInfo = AccountInfo(Email: userEmail, Password: userPassword)
                    
                    
                    /*Show the successful login result. */
                    NSLog("Login Success");
                    
                    
                    /******Initial viewcontroller in TabBar. *********/
                    let sentInvitationVC = self.storyboard!.instantiateViewControllerWithIdentifier("SentInvitationsVC") as! MUSentInvitationsTableViewController
                    
                    
                    let receivedInvitationVC = self.storyboard!.instantiateViewControllerWithIdentifier("ReceivedInvitationsVC") as! MUReceivedInvitationsTableViewController
                    
                    let settingsVC = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsVC") as! MUSettingsTableViewController
                    
                    
                    self.tabBarController?.setViewControllers([sentInvitationVC, receivedInvitationVC, settingsVC], animated: false)
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.view.endEditing(true) // This is used to hide keyboard.
                        
                        appDelegate.tabBarController?.selectedIndex = 0 // 0-send invitation viewcontroller, 1-received invitation viewcontroller, 2-settings.
                        
                        appDelegate.window?.rootViewController = appDelegate.tabBarController
                        
                    })
                    
                }  // end of if(success == "1")
                else
                {
                    var error_msg:NSString
                    
                    if jsonData["error_message"] as? NSString != nil
                    {
                        error_msg = jsonData["error_message"] as! NSString
                    }
                    else
                    {
                        error_msg = "Unknown Error"
                    }
                    
                    let title = "Login Failed!"
                    let message = error_msg as String
                    sendAlertView(title, message: message)
                    
                }
                
            }// end of if (statusCode >= 200 && statusCode < 300)
            else
            {
                let title = "Login Failed!"
                let message = "Connection Failed"
                sendAlertView(title, message: message)
                
            }
            
        })// end of task = session.dataTaskWithRequest
        
   
        task.resume()
         

    }
    
    
    
//    func application(application: UIApplication,
//        openURL url: NSURL,
//        sourceApplication: String?,
//        annotation: AnyObject?) -> Bool {
//            return FBSDKApplicationDelegate.sharedInstance().application(
//                application,
//                openURL: url,
//                sourceApplication: sourceApplication,
//                annotation: annotation)
//    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    
    func ProcessHttpPostResponseForLogin(statusCode: Int, data: NSData)  {

        
        
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
