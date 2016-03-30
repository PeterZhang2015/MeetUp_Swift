//
//  MUAnSentInvitationViewController.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 28/08/2015.
//  Copyright (c) 2015 Chongzheng Zhang. All rights reserved.
//

import UIKit

class MUAnSentInvitationViewController: UIViewController ,UITextFieldDelegate, UITextViewDelegate{
    
    var newInvitation: Invitation?   // An new invitation in MUAnSentInvitationViewController

    var  meetingTimeArray = [String]()
    var  meetingLocationArray = [String]()
    var  invitedFriendEmail: String?
    
    @IBOutlet weak var meetingName: UITextField!

    
    @IBOutlet weak var meetingDescription: UITextView!
    
    @IBAction func doneForAddMeetingTimesVC(segue:UIStoryboardSegue) {
        
        if let AddMeetingTimesVC = segue.sourceViewController as? MUAddeMeetingTimesTableViewController {
            
            //add the new invitation to the invitation array
            self.meetingTimeArray = AddMeetingTimesVC.meetingTimeArray
            
            if (self.meetingTimeArray.count == 0)
            {
                let title = "Set meeting time error!"
                let message = "You have to set at least one meeting time!"
                sendAlertView(title, message: message)
            }
            
           // tableView.reloadData()
            
           // self.navigationController?.popViewControllerAnimated(True)
            
        }
        
    }
    
    @IBAction func doneForAddMeetingLocationsVC(segue:UIStoryboardSegue) {
        
        if let AddMeetingLocationsVC = segue.sourceViewController as? MUAddMeetingLocationsTableViewController {
            
            //add the new invitation to the invitation array
            self.meetingLocationArray = AddMeetingLocationsVC.meetingLocationArray
            
            if (self.meetingLocationArray.count == 0)
            {
                let title = "Set meeting location error!"
                let message = "You have to set at least one meeting location!"
                sendAlertView(title, message: message)
            }
            
            // tableView.reloadData()
            
        }
        
    }
    
    @IBAction func saveForInviteAFriendVC(segue:UIStoryboardSegue) {
        
        if let InviteAFriendVC = segue.sourceViewController as? MUInviteAnFriendViewController {
            
            //add the new invitation to the invitation array
            self.invitedFriendEmail = InviteAFriendVC.InvitedFriendEmail.text
            
            if ((InviteAFriendVC.InvitedFriendEmail.text?.isEmpty) == true)
            {
                let title = "Set invited friend email error!"
                let message = "You have to set at least one invited friend email!"
                sendAlertView(title, message: message)
            }
        
            // tableView.reloadData()
            
        }
        
    }
    @IBAction func cancelForInviteAFriendVC(segue:UIStoryboardSegue) {
        

    }
    

    /* Override shouldPerformSegueWithIdentifier in order to check validation.  */
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        
        /* Check the validation of meeting name. */
        if identifier == "doneForAnSentInvitationVC" {
            
            if (meetingName.text!.isEmpty) {
                
                let alert = UIAlertView()
                alert.title = "No Meeting Name"
                alert.message = "You have to fill the meeting name!"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
            /* Check the validation of meeting description. */
            else if (meetingDescription.text.isEmpty){
                
                let alert = UIAlertView()
                alert.title = "No Meeting Description"
                alert.message = "You have to fill the meeting description!"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
            /* Check the validation of meeting time. */
            else if (meetingTimeArray.count == 0){
                
                let alert = UIAlertView()
                alert.title = "No Meeting Time"
                alert.message = "You have to select at least one meeting time!"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
            /* Check the validation of meeting location. */
            else if (meetingLocationArray.count == 0){
                
                let alert = UIAlertView()
                alert.title = "No Meeting Location"
                alert.message = "You have to select at least one meeting location!"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
            /* Check the validation of invited friend Email. */
            else if (invitedFriendEmail?.isEmpty == true){
                
                let alert = UIAlertView()
                alert.title = "No Invited Friend"
                alert.message = "You have to invite a friend!"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
                
            else {

                /* Send meeting invitation request to the provider through HTTP request message. */
                
                let url: NSURL = NSURL(string: "http://192.168.0.23.xip.io/~chongzhengzhang/php/sendinvitation.php")!  // the web link of the provider.
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
                
                request.HTTPMethod = "POST";  //Post to PHP in provider.
                
                /*Get AppDelegate. */
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

                
                let InvitationId = 0  // It is a false initial invitation ID, the true invitation ID should be returned from website.
                
                let MeetingTimedata = try? NSJSONSerialization.dataWithJSONObject(self.meetingTimeArray, options: [])
                let MeetingTimeJsonArray = NSString(data: MeetingTimedata!, encoding: NSUTF8StringEncoding)
                
                let MeetingLocationdata = try? NSJSONSerialization.dataWithJSONObject(self.meetingLocationArray, options: [])
                let MeetingLocationJsonArray = NSString(data: MeetingLocationdata!, encoding: NSUTF8StringEncoding)
                
                NSLog("meetingTimeArray: %@", meetingTimeArray);
                
                NSLog("meetingLocationArray: %@", meetingLocationArray)
                
      
        //        NSLog("meetingLocationArray[1]: %@", meetingLocationArray[1]);
                
                newInvitation = Invitation(InvitationId:InvitationId, MeetingName: self.meetingName.text!, MeetingDescription: self.meetingDescription.text, MeetingTime: self.meetingTimeArray, MeetingLocation: self.meetingLocationArray, InvitedFriendEmail: self.invitedFriendEmail!, InviterFriendEmail: appDelegate.accountInfo!.Email,selectedMeetingTime: "", selectedMeetingLocation: "", haveSelectedMeetingTimeFlag: false, haveSelectedMeetingLocationFlag: false)
                
                // Compose login information with device token, login Email, and loginPassword
                let postString: NSString = "sInviterEmail=\(appDelegate.accountInfo!.Email)&sInvitedEmail=\(self.invitedFriendEmail!)&sMeetingName=\(self.meetingName.text!)&sMeetingDescription=\(self.meetingDescription.text!)&asMeetingTime=\(MeetingTimeJsonArray!)&asMeetingLocation=\(MeetingLocationJsonArray!)&iMeetingTimeNum=\(self.meetingTimeArray.count)&iMeetingLocationNum=\(self.meetingLocationArray.count)"
                
                //Set the meeting invitation information as the HTTP body
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                
                let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion:true)!
                let postLength:NSString = String( postData.length )
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
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
                        
                        let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        
                        let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                        
                        
                        let success:NSString =  jsonData.valueForKey("Success") as! NSString
                        
                        NSLog("Success ==> %@", success);
                        
                        
                        if(success == "1")
                        {
                            
                        //    let title = "Succeed!"
                         //   let message = "Save the Invitation Successfully!"
                      //      sendAlertView(title, message: message)
                            
                            /*******Update Invitation ID*********/
                            let InvitationID: Int = jsonData.valueForKey("InvitationID") as! Int
                            
                            self.newInvitation?.InvitationId = InvitationID
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                            appDelegate.window?.rootViewController = appDelegate.tabBarController
                            })
                            

                        }
                        else
                        {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            
                            let title = "Failed to save the invitation!"
                            let message = error_msg as String
                            sendAlertView(title, message: message)
          
                        }
                        
                    }
                    else
                    {
                        let title = "Failed to save the invitation!"
                        let message = "Connection Failed"
                        sendAlertView(title, message: message)

                    }

                    
                })
                
                task.resume()
                
            }

            return true
        }
  
        
        // by default, transition
        return true
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
     
        newInvitation?.MeetingName = meetingName.text!
        newInvitation?.MeetingDescription = meetingDescription.text
        invitedFriendEmail = ""
        
        self.meetingName.delegate = self;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "@\n" {
            self.resignFirstResponder()
            return false;
        }

        
        return true
        
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


