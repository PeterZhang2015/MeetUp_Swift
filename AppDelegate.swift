//
//  AppDelegate.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 25/08/2015.
//  Copyright (c) 2015 Chongzheng Zhang. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var bIsLogin: Bool?    // Define the bIsLogin in order to judge whether the user has logged in. If the user has not logged in, it should show MUMainViewController to the user, otherwise, it should show TabBarController to the user.
   
    var accountInfo: AccountInfo?  // store the login information when the user login successfully.
    
    var tabBarController: UITabBarController?    // Main tab bar view controller for the application.
    
    let defaults = NSUserDefaults.standardUserDefaults()   //Set defaults to save and get data.
    let deviceTokenConstant = "deviceTokenKey"   //Set constant for getting device token.

    
    /*Handling when the application launched in didFinishLaunchingWithOptions function. */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        

      //  let sEmail = ""
      //  let sPassword = ""
     //   self.accountInfo.init(sEmail, sPassword)

       // self.accountInfo.init(Email: "", Password: "")
        
        
        
        // Push notification was received when the app was in the background
        
        // .....

 
        // Set lauched view.
        self.window = UIWindow(frame:UIScreen.mainScreen().bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)  // Get the storyboard according to it's name.
        
        self.tabBarController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarVC") as? UITabBarController // instantiate desired ViewController.
  
        
        if ((self.bIsLogin) != true){   // BOOL value to know if user is logged in or not.If user succefully logged in set value of this as true else false.
            
            print("Register to APNS.")
            
            let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
            
            let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
            
            application.registerUserNotificationSettings( settings )
            application.registerForRemoteNotifications()

            let LaunchViewController = storyboard.instantiateViewControllerWithIdentifier("LaunchVC") as! MULaunchViewController   // Get the MULaunchViewController according to it's storyboard identifier.
            
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController = LaunchViewController    // Set the MUMainViewController as the RootViewController.

        }
        
        // Check whether device token for push notification exists.
       
        
//        let deviceToken = defaults.objectForKey(deviceTokenConstant) as! String?
//        
//        if (deviceToken == nil) {
//        
//            print("There is no deviceToken saved when application is launched.")
//            
//            let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
//            
//            let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
//            
//            application.registerUserNotificationSettings( settings )
//           // application.registerForRemoteNotifications()
//            
//        }
//        else
//        {
//            
//            print("Get deveiceToken successfully!")
//            NSLog("Device Token ==> %@", deviceToken!);
//        
//        }
//    
        
       // return true
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
//    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
//        print("didRegisterUserNotificationSettings notificationSettings.")
//        
//        application.registerForRemoteNotifications()
//    }
    
//    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
//        
//        print("handleActionWithIdentifier forRemoteNotification.")
//        //handle the actions
//        if (identifier == "declineAction"){
//            
//            
//        }
//        else if (identifier == "answerAction"){
//            
//        }
//        else{
//            
//        }
//
//    }
  
    
    
    /* Register APNS in order to get device token for futher push notification function. */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        print("Got token data! (deviceToken)")
        
        
     //   let deviceTokenString2 = NSString(format: "%@", deviceToken) as String
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )

        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        print(deviceTokenString )
        
        defaults.setObject(deviceTokenString, forKey: deviceTokenConstant)  // Save the retrived device token, and send it to provider when login the application.
        
 
        
    }
    
    /* Fail to register APNS. */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Couldn’t register to APNS: (error)")
    }
    
    
    /* Receives push notification from APNS. */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
        
        
        print("!!!!!!Received Push Notification from APNS!!!!!")
        
        /* Get invitationID from push notification message. */
        if let aps = userInfo["aps"] as? NSDictionary {
            if let invitationID = aps["invitationID"] as? NSInteger {
                
                NSLog("invitationID ==> %d", invitationID);

                
                if let eventType = aps["eventType"] as? NSInteger{
                    
                    NSLog("eventType ==> %d", eventType);
                    
                    // 1-------Notify invited user about coming new invitation. 2-------Notify inviter user about selected time. 3-------Notify inviter user about selected location. 4-------Notify inviter user about meeting starting. 5-------Notify invited user about meeting starting.
                    
                    switch eventType{
                        
                    case 1:  // 1-------Notify invited user about coming new invitation.
                        
                        NSLog("#########Received push notification 1 ==> Notify invited user about coming new invitation")
                        
                        /* Send Http message to supported web server in order to get the invitation information. */
                        let url: NSURL = NSURL(string: "http://meetupappsupportedserver.com/getinvitationinfo.php")!  // the web link of the provider.
                        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
                        request.HTTPMethod = "POST";  //Post to PHP in provider.
                        
                        // Compose request information.
                        let postString: NSString = "iInvitationID=\(invitationID)"
                        
                        //Set information as the HTTP body
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                        let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding)!
                        let postLength:NSString = String( postData.length )
                        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.setValue("application/json", forHTTPHeaderField: "Accept")
                        
                        /**********Send Post and process response. ***************/
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
                                
                                let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                                
                                NSLog("Response ==> %@", responseData);
                                
                                let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                                
                                let success:NSString = jsonData.valueForKey("Success") as! NSString
                                
                                NSLog("Success ==> %@", success);
                                
                                if(success == "1")
                                {
                                    /*Show the successful result. */
                                    NSLog("Get invitation information Successfully");
                                    
                                    /*Get information from response. */
                                    let meetingName: String = jsonData.valueForKey("MeetingName") as! String
                                    
                                    let meetingDescription: String = jsonData.valueForKey("MeetingDescription") as! String
                                    let invitedEmail: String = jsonData.valueForKey("InvitedEmail") as! String
                                    let inviterEmail: String = jsonData.valueForKey("InviterEmail") as! String
                                    let meetingTime: [String] = jsonData.valueForKey("MeetingTime") as! [String]
                                    let meetingLocation: [String] = jsonData.valueForKey("MeetingLocation") as! [String]
                                    
                                    
                                    
                                    NSLog("meetingTime ==> %@", meetingTime);
                                    NSLog("meetingLocation ==> %@", meetingLocation);
                                    
                                    
                                    var  aReceivedInvitation: Invitation?
                                    
                                    aReceivedInvitation = Invitation(InvitationId: invitationID,MeetingName: meetingName, MeetingDescription: meetingDescription, MeetingTime: meetingTime, MeetingLocation: meetingLocation, InvitedFriendEmail: invitedEmail, InviterFriendEmail: inviterEmail,selectedMeetingTime: "", selectedMeetingLocation: "", haveSelectedMeetingTimeFlag: false, haveSelectedMeetingLocationFlag: false)
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        
                                        let navigationVC: UINavigationController = self.tabBarController?.viewControllers![1] as! UINavigationController
                                        
                                        /***It is used to adjust first row of table viewcontroller under the navigation item. otherwise, the first row will moves up and hides under the nav-bar.****/
                                        navigationVC.navigationBar.translucent = false
                                        /***reference: https://github.com/samvermette/SVPullToRefresh/issues/181***/
                                        
                                        let receivedInvitationVC: MUReceivedInvitationsTableViewController = navigationVC.visibleViewController as! MUReceivedInvitationsTableViewController
                                        
                                        receivedInvitationVC.receivedInvitations.append(aReceivedInvitation!)
                                        
                                        receivedInvitationVC.tableView.reloadData()
                                        
                                        
                                        self.window?.makeKeyAndVisible()
                                        
                                        /*********** Way of transfering to a specific tabbar. *****************/
                                        self.tabBarController?.selectedIndex = 1 // 0-send invitation viewcontroller, 1-received invitation viewcontroller, 2-settings.
                                        self.window?.rootViewController = self.tabBarController
                                        
                                        
                                    })
                                    
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
                                    
                                    let title = "Failed To Get Invitation Information!"
                                    let message = error_msg as String
                                    sendAlertView(title, message: message)
                                    
                                }
                                
                            }
                            
                        })
                        
                        task.resume()
      
                        break
                        
                    case 2: // received push notification for inviter user about the selected meeting time by the invited user.

                        NSLog("#########Received push notification 2 ==> Notify inviter user about selected time.")
                        
                        /* Send Http message to supported web server in order to get selected meeting time for the inviter user. */
                        let url: NSURL = NSURL(string: "http://meetupappsupportedserver.com/getselectedmeetingtime.php")!  // the web link of the provider.
                        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
                        request.HTTPMethod = "POST";  //Post to PHP in provider.
                        
                        // Compose request information.
                        let postString: NSString = "iInvitationID=\(invitationID)"
                        
                        //Set information as the HTTP body
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                        let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding)!
                        let postLength:NSString = String( postData.length )
                        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.setValue("application/json", forHTTPHeaderField: "Accept")
                        
                        /**********Send Post and process response. ***************/
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
                                
                                let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                                
                                NSLog("Response ==> %@", responseData);
                                
                                let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                                
                                let success:NSString = jsonData.valueForKey("Success") as! NSString
                                
                                NSLog("Success ==> %@", success);
                                
                                if(success == "1")
                                {
                                    /*Show the successful result. */
                                    NSLog("Get selected meeting time Successfully");
                                    
                                    /*Get information from response. */
                                    let selectedMeetingTime: String = jsonData.valueForKey("SelectedMeetingTime") as! String
                 
                                    NSLog("selectedMeetingTime ==> %@", selectedMeetingTime);

                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                    
                                        let navigationVC: UINavigationController = self.tabBarController?.viewControllers![0] as! UINavigationController
                                        
                                        /***It is used to adjust first row of table viewcontroller under the navigation item. otherwise, the first row will moves up and hides under the nav-bar.****/
                                        navigationVC.navigationBar.translucent = false
                                        /***reference: https://github.com/samvermette/SVPullToRefresh/issues/181***/
        
                                        let sentInvitationsVC: MUSentInvitationsTableViewController = navigationVC.viewControllers[0] as! MUSentInvitationsTableViewController
                                        
                                        
                                        

                                        for section in 0..<sentInvitationsVC.tableView.numberOfSections {
                                            
                                            for row in 0..<sentInvitationsVC.tableView.numberOfRowsInSection(section) {
                                                
                                                let indexPath = NSIndexPath(forRow: row, inSection: section)
                                                
                                          
                                                if(sentInvitationsVC.Invitations[indexPath.row].InvitationId == invitationID)
                                                {
                                                    sentInvitationsVC.Invitations[indexPath.row].haveSelectedMeetingTimeFlag = true
                                                    
                                                    sentInvitationsVC.Invitations[indexPath.row].MeetingTime.removeAll()
                                                    
                                                    sentInvitationsVC.Invitations[indexPath.row].MeetingTime.append(selectedMeetingTime)
                                                    
                                                    sentInvitationsVC.Invitations[indexPath.row].selectedMeetingTime = selectedMeetingTime
                                                    
                                                    
                                                        sentInvitationsVC.tableView(sentInvitationsVC.tableView, didSelectRowAtIndexPath: indexPath)
                                                    
                                                    sentInvitationsVC.performSegueWithIdentifier("SegueToDetailSentInvitationVC", sender: self)
                                                    
                            
                                                        let title = "Check selected meeting time!"
                                                        let message = "Meeting time has been selected by the invited user, please have a check!"
                                                        sendAlertView(title, message: message)
                                                    
                                                    
//                   /*********************************************Begin :Test****************************/
//                                                    
//                                                    let url: NSURL = NSURL(string: "http://meetupappsupportedserver.com/remindinvitation.php")!  // the web link of the provider.
//                                                    let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
//                                                    request.HTTPMethod = "POST";  //Post to PHP in provider.
//                                                    
//                                                    // Compose request information.
//                                                    let postString: NSString = "iInvitationID=\(invitationID)"
//                                                    
//                                                    //Set information as the HTTP body
//                                                    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
//                                                    let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding)!
//                                                    let postLength:NSString = String( postData.length )
//                                                    request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
//                                                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//                                                    request.setValue("application/json", forHTTPHeaderField: "Accept")
//                                                    
//                                                    /**********Send Post and process response. ***************/
//                                                    let session = NSURLSession.sharedSession()
//                                                    
//                                                    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//                                                        
//                                                        print("error: \(error)")
//                                                        print("Response: \(response)")
//                                                        let responseData = NSString(data: data!, encoding: NSUTF8StringEncoding)!
//                                                        print("Body: \(responseData)")
//                                                        
//                                                        
//                                                        let statusCode = (response as! NSHTTPURLResponse).statusCode
//                                                        
//                                                        NSLog("Response code: %ld", statusCode);
//                                                        
//                                                        
//                                                        if (statusCode >= 200 && statusCode < 300)
//                                                        {
//                                                            
//                                                            let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
//                                                            
//                                                            NSLog("Response ==> %@", responseData);
//                                                            
//                                                            let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
//                                                            
//                                                            let success:NSString = jsonData.valueForKey("Success") as! NSString
//                                                            
//                                                            NSLog("Success ==> %@", success);
//                                                            
//                                                            if(success == "1")
//                                                            {
//                                                                /*Show the successful result. */
//                                                                NSLog("Trigger remind successfully.");
//                                                                
//                                
//                                                                
//                                                                dispatch_async(dispatch_get_main_queue(), {
//                                                                    
//                                                                    let navigationVC: UINavigationController = self.tabBarController?.viewControllers![0] as! UINavigationController
//                                                                    
//                                                                    /***It is used to adjust first row of table viewcontroller under the navigation item. otherwise, the first row will moves up and hides under the nav-bar.****/
//                                                                    navigationVC.navigationBar.translucent = false
//                                                                    /***reference: https://github.com/samvermette/SVPullToRefresh/issues/181***/
//                                                                    
//                                                                    let sentInvitationsVC: MUSentInvitationsTableViewController = navigationVC.viewControllers[0] as! MUSentInvitationsTableViewController
//                                                                    
//                                                                    // let sentInvitationsVC: MUSentInvitationsTableViewController = navigationVC.topViewController as! MUSentInvitationsTableViewController
//                                                                    
//                                                                    
//                                                                    for section in 0..<sentInvitationsVC.tableView.numberOfSections {
//                                                                        
//                                                                        for row in 0..<sentInvitationsVC.tableView.numberOfRowsInSection(section) {
//                                                                            
//                                                                            let indexPath = NSIndexPath(forRow: row, inSection: section)
//                                                                            
//                                                                            if (sentInvitationsVC.Invitations[indexPath.row].InvitationId == invitationID)
//                                                                            {
//                                                                                
//                                                                                sentInvitationsVC.tableView(sentInvitationsVC.tableView, didSelectRowAtIndexPath: indexPath)
//                                                                                
//                                                                                let title = "Meeting remind!"
//                                                                                let message = "Meeting will be hold in 1 hour, please prepare!"
//                                                                                sendAlertView(title, message: message)
//                                                                            }
//                                                                            
//                                                                            
//                                                                        }
//                                                                    }
//                                                                    
//                                                                    
//                                                                })
//                                                                
//                                                            }
//                                                            else
//                                                            {
//                                                                var error_msg:NSString
//                                                                if jsonData["error_message"] as? NSString != nil {
//                                                                    error_msg = jsonData["error_message"] as! NSString
//                                                                }
//                                                                else {
//                                                                    
//                                                                    error_msg = "Unknown Error"
//                                                                    
//                                                                }
//                                                                
//                                                                let title = "Failed To Get Invitation Information!"
//                                                                let message = error_msg as String
//                                                                sendAlertView(title, message: message)
//                                                                
//                                                            }
//                                                            
//                                                        }
//                                                        
//                                                    })
//                                                    
//                                                    task.resume()
//                                                    
//                                                    /******************End:  Test*******************/
//                                                    
 
                                                    
                                                    
                                                    
                                                }
                                                

               
                                            }
                                        }
                     
                                        
                                    })
                                    
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
                                    
                                    let title = "Failed To Get Invitation Information!"
                                    let message = error_msg as String
                                    sendAlertView(title, message: message)
                                    
                                }
                                
                            }
                            
                        })
                        
                        task.resume()
                        

                        
                        
                        break
                        
                    case 3:
                        // received push notification for inviter user about the selected meeting location by the invited user.
                        
                        NSLog("#########Received push notification 3 ==> Notify inviter user about selected location.")
                        
                        /* Send Http message to supported web server in order to get selected meeting location for the inviter user. */
                        let url: NSURL = NSURL(string: "http://meetupappsupportedserver.com/getselectedmeetinglocation.php")!  // the web link of the provider.
                        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
                        request.HTTPMethod = "POST";  //Post to PHP in provider.
                        
                        // Compose request information.
                        let postString: NSString = "iInvitationID=\(invitationID)"
                        
                        //Set information as the HTTP body
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                        let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding)!
                        let postLength:NSString = String( postData.length )
                        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.setValue("application/json", forHTTPHeaderField: "Accept")
                        
                        /**********Send Post and process response. ***************/
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
                                
                                let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                                
                                NSLog("Response ==> %@", responseData);
                                
                                let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                                
                                let success:NSString = jsonData.valueForKey("Success") as! NSString
                                
                                NSLog("Success ==> %@", success);
                                
                                if(success == "1")
                                {
                                    /*Show the successful result. */
                                    NSLog("Get selected meeting location Successfully");
                                    
                                    /*Get information from response. */
                                    let selectedMeetingLocation: String = jsonData.valueForKey("SelectedMeetingLocation") as! String
                                    
                                    NSLog("selectedMeetingLocation ==> %@", selectedMeetingLocation);
                                    
                                    
                                    
            
                                    dispatch_async(dispatch_get_main_queue(), {
                                        
                                        let navigationVC: UINavigationController = self.tabBarController?.viewControllers![0] as! UINavigationController
                                        
                                        /***It is used to adjust first row of table viewcontroller under the navigation item. otherwise, the first row will moves up and hides under the nav-bar.****/
                                        navigationVC.navigationBar.translucent = false
                                        /***reference: https://github.com/samvermette/SVPullToRefresh/issues/181***/
                                        
                                        let sentInvitationsVC: MUSentInvitationsTableViewController = navigationVC.viewControllers[0] as! MUSentInvitationsTableViewController
                                        
                                       // let sentInvitationsVC: MUSentInvitationsTableViewController = navigationVC.topViewController as! MUSentInvitationsTableViewController
                                        
                                        
                                        for section in 0..<sentInvitationsVC.tableView.numberOfSections {
                                            
                                            for row in 0..<sentInvitationsVC.tableView.numberOfRowsInSection(section) {
                                                
                                                let indexPath = NSIndexPath(forRow: row, inSection: section)
                          
                                                if (sentInvitationsVC.Invitations[indexPath.row].InvitationId == invitationID)
                                                {
                                                    sentInvitationsVC.Invitations[indexPath.row].haveSelectedMeetingLocationFlag = true
                                                    
                                                    sentInvitationsVC.Invitations[indexPath.row].selectedMeetingLocation = selectedMeetingLocation
                                                    
                                                    sentInvitationsVC.Invitations[indexPath.row].MeetingLocation.removeAll()
                                                    
                                                    
                                                    sentInvitationsVC.Invitations[indexPath.row].MeetingLocation.append(selectedMeetingLocation)
                                                    
                                                    sentInvitationsVC.Invitations[indexPath.row].selectedMeetingLocation = selectedMeetingLocation
                                                    
                                                    sentInvitationsVC.tableView(sentInvitationsVC.tableView, didSelectRowAtIndexPath: indexPath)
                                                    
                                                    sentInvitationsVC.performSegueWithIdentifier("SegueToDetailSentInvitationVC", sender: self)
                                                    
                                                    
                                                    let title = "Check selected meeting location!"
                                                    let message = "Meeting location has been selected by the invited user, please have a check!"
                                                    sendAlertView(title, message: message)
                                                }
                                                
                                                
                                            }
                                        }
                                        
                                        
                                    })
                                    
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
                                    
                                    let title = "Failed To Get Invitation Information!"
                                    let message = error_msg as String
                                    sendAlertView(title, message: message)
                                    
                                }
                                
                            }
                            
                        })
                        
                        task.resume()

                        
                        
                        break
                        
                    case 4:
                        //4-------Notify inviter user about meeting starting. 
                        
                        NSLog("#########Received push notification 4 ==> Notify inviter user about meeting starting.")
                        
  //                      dispatch_async(dispatch_get_main_queue(), {
                            
                            let navigationVC: UINavigationController = self.tabBarController?.viewControllers![0] as! UINavigationController
                            
                            /***It is used to adjust first row of table viewcontroller under the navigation item. otherwise, the first row will moves up and hides under the nav-bar.****/
                            navigationVC.navigationBar.translucent = false
                            /***reference: https://github.com/samvermette/SVPullToRefresh/issues/181***/
                            
                            let sentInvitationsVC: MUSentInvitationsTableViewController = navigationVC.viewControllers[0] as! MUSentInvitationsTableViewController
                            
                            // let sentInvitationsVC: MUSentInvitationsTableViewController = navigationVC.topViewController as! MUSentInvitationsTableViewController
                            
                            
                            for section in 0..<sentInvitationsVC.tableView.numberOfSections {
                                
                                for row in 0..<sentInvitationsVC.tableView.numberOfRowsInSection(section) {
                                    
                                    let indexPath = NSIndexPath(forRow: row, inSection: section)
                                    
                                    if (sentInvitationsVC.Invitations[indexPath.row].InvitationId == invitationID)
                                    {

                                        sentInvitationsVC.tableView(sentInvitationsVC.tableView, didSelectRowAtIndexPath: indexPath)
                                    sentInvitationsVC.performSegueWithIdentifier("SegueToDetailSentInvitationVC", sender: self)
                        
                                    }
                                    
                                    
                                }
                            }
                            
                            
       //                 })

                        
                        
                        break
                        
                    case 5:
                        
                        //5-------Notify invited user about meeting starting.
                        
                        NSLog("#########Received push notification 5 ==> Notify invited user about meeting starting.")
                        
                        
  //                      dispatch_async(dispatch_get_main_queue(), {
                            
                            let navigationVC: UINavigationController = self.tabBarController?.viewControllers![1] as! UINavigationController
                            
                            /***It is used to adjust first row of table viewcontroller under the navigation item. otherwise, the first row will moves up and hides under the nav-bar.****/
                            navigationVC.navigationBar.translucent = false
                            /***reference: https://github.com/samvermette/SVPullToRefresh/issues/181***/
                            
                            let ReceivedInvitationsVC: MUReceivedInvitationsTableViewController = navigationVC.viewControllers[0] as! MUReceivedInvitationsTableViewController
                            
                            // let sentInvitationsVC: MUSentInvitationsTableViewController = navigationVC.topViewController as! MUSentInvitationsTableViewController
                            
                            
                            for section in 0..<ReceivedInvitationsVC.tableView.numberOfSections {
                                
                                for row in 0..<ReceivedInvitationsVC.tableView.numberOfRowsInSection(section) {
                                    
                                    let indexPath = NSIndexPath(forRow: row, inSection: section)
                                    
                                    if (ReceivedInvitationsVC.receivedInvitations[indexPath.row].InvitationId == invitationID)
                                    {
                                        
                                        ReceivedInvitationsVC.tableView(ReceivedInvitationsVC.tableView, didSelectRowAtIndexPath: indexPath)
                                        
                                    ReceivedInvitationsVC.performSegueWithIdentifier("SegueToDetailInvitationVC", sender: self)
                                        

                                    }
                                    
                                }
                            }
                            
                            
         //               })
                        
                        break
                        
                    default:
                        
                        break
                        
                    }
                    
                
                
               }
                
            }
            
            
        }
        

        
    }
    
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }





}

