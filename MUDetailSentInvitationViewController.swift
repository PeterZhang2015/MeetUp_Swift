//
//  MUDetailSentInvitationViewController.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 2/09/2015.
//  Copyright (c) 2015 Chongzheng Zhang. All rights reserved.
//

import UIKit

class MUDetailSentInvitationViewController: UIViewController {
    
    var AnInvitation: Invitation?
    
    var sourceVC: Int? //    0-Sent Invitation VC, 1-Received Invitation VC
    
    var HaveSelectedMeetingTime: Int? //    0-not selected, 1-selected
    var HaveSelectedMeetingLocation: Int? //    0-not selected, 1-selected

    @IBOutlet weak var DisplayMeetingNameText: UITextView!
    
    
    @IBOutlet weak var DisplayMeetingDescriptionText: UITextView!
    
    
    @IBOutlet weak var inviterFriendEmail: UIButton!
    
    
    
    @IBAction func cancelForDetailMeetingTimeVC(segue:UIStoryboardSegue) {
        
        
    }
    
    @IBAction func cancelForDetailMeetingLocationVC(segue:UIStoryboardSegue) {
        
        
    }
    
    @IBAction func cancelForDetailInvitedFriendVC(segue:UIStoryboardSegue) {
        
        
    }
    
    @IBAction func cancelForDetailInviterFriendVC(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func CancelForDetailMeetingTimeVC(segue:UIStoryboardSegue) {
        
    }

    

    
    @IBAction func CancelForDetailMeetingLocationVC(segue:UIStoryboardSegue) {
    }
    

    
    @IBAction func selectForDetailMeetingTimeVC(segue:UIStoryboardSegue) {
        
        let sourceVC:MUDetailMeetingTimeViewController = segue.sourceViewController as! MUDetailMeetingTimeViewController
    
        
        self.HaveSelectedMeetingTime = 1 //    0-not selected, 1-selected
        
     //   let meetingTimeNum = sourceVC.meetingTimeArray.count
        
        
      //  if (meetingTimeNum > 1) // Reset MeetingTime array by the selected meeting time.
     //   {
            let delegate:UIPickerViewDelegate = sourceVC.meetingTimePicker.delegate!
            
    
            let selectedMeetingTime: String = delegate.pickerView!(sourceVC.meetingTimePicker, titleForRow: sourceVC.meetingTimePicker.selectedRowInComponent(0), forComponent: 0)!
            
            /* send data to web server. */
            let url: NSURL = NSURL(string: "http://192.168.0.23.xip.io/~chongzhengzhang/php/selectedmeetingtime.php")!
            
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            
            request.HTTPMethod = "POST";  //Post to PHP
            
            // Compose a query string
     //       let postString: NSString = "sSelectedMeetingTime=\(selectedMeetingTime)"
            

            let postString: NSString = "sSelectedMeetingTime=\(selectedMeetingTime)&iInvitationID=\(AnInvitation!.InvitationId)"

            
            //Send selected meeting time to web server.
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
                    
                    if(success != "1")
                    {
                        var error_msg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                        
                        let title = "Select meeting time Failed!"
                        let message = error_msg as String
                        sendAlertView(title, message: message)
                        
                    }
                    else
                    {
                        
                        self.AnInvitation?.selectedMeetingTime = selectedMeetingTime
                    }
                    
                }
                else
                {
                    let title = "Select meeting time Failed!"
                    let message = "Error reponse!"
                    sendAlertView(title, message: message)
     
                }
 
            })
            
            task.resume()
    

            /******Reset meeting time array by selected meeting time. **********/
            AnInvitation!.MeetingTime.removeAll()
    
            AnInvitation!.MeetingTime.append(selectedMeetingTime)
    
     //   }


    }
    

        @IBAction func SelectForDetailMeetingLocationVC(segue:UIStoryboardSegue) {
    
        let sourceVC:MUDetailMeetingLocationViewController = segue.sourceViewController as! MUDetailMeetingLocationViewController
        
        
        self.HaveSelectedMeetingLocation = 1 //    0-not selected, 1-selected
        sourceVC.GetToMeetLocationButton.hidden = false
        sourceVC.HaveSelected = 1  //    0-not selected, 1-selected
           
            
        let meetingLocationNum = sourceVC.meetingLocationArray.count
        if (meetingLocationNum == 0)
        {
            let title = "Set meeting location error!"
            let message = "You have to set at least one location!"
            sendAlertView(title, message: message)
        }
        else
        {
    
            let delegate:UIPickerViewDelegate = sourceVC.meetingLocationPicker.delegate!
            
            
            let selectedMeetingLocation: String = delegate.pickerView!(sourceVC.meetingLocationPicker, titleForRow: sourceVC.meetingLocationPicker.selectedRowInComponent(0), forComponent: 0)!
            
            AnInvitation?.selectedMeetingLocation = selectedMeetingLocation
            
            /*Set information after setting the meeting location. */
            sourceVC.selectedMeetingLocation = selectedMeetingLocation
            
            
            /* send data to web server. */
            let url: NSURL = NSURL(string: "http://192.168.0.23.xip.io/~chongzhengzhang/php/selectedmeetinglocation.php")!
            
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            
            request.HTTPMethod = "POST";  //Post to PHP
            
            // Compose a query string
            //       let postString: NSString = "sSelectedMeetingTime=\(selectedMeetingTime)"
            
            
            let postString: NSString = "sSelectedMeetingLocation=\(selectedMeetingLocation)&iInvitationID=\(AnInvitation!.InvitationId)"
            
            
            //Send selected meeting time to web server.
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
                    
                    if(success != "1")
                    {
                        var error_msg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                        
                        let title = "Select meeting location Failed!"
                        let message = error_msg as String
                        sendAlertView(title, message: message)
                        
                    }
                    else
                    {
                        
                        self.AnInvitation?.selectedMeetingLocation = selectedMeetingLocation
                    }
                    
                }
                else
                {
                    let title = "Select meeting location Failed!"
                    let message = "Error reponse!"
                    sendAlertView(title, message: message)
                    
                }
                
            })
            
            task.resume()
            
            
            /******Reset meeting lcation array by selected meeting location. **********/
            AnInvitation!.MeetingLocation.removeAll()
            
            AnInvitation!.MeetingLocation.append(selectedMeetingLocation)
            
        }
        
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SegueToDetailMeetingTimeVC"{
            
            
//            let destinationNavigationController:UINavigationController = segue.destinationViewController as! UINavigationController
//            
//            let detailMeetingTimeVC: MUDetailMeetingTimeViewController
//            = destinationNavigationController.topViewController as! MUDetailMeetingTimeViewController
            
            let detailMeetingTimeVC: MUDetailMeetingTimeViewController
                        = segue.destinationViewController as! MUDetailMeetingTimeViewController
            
            detailMeetingTimeVC.meetingTimeArray = AnInvitation!.MeetingTime
            
            detailMeetingTimeVC.sourceVC = self.sourceVC
            detailMeetingTimeVC.HaveSelected = self.HaveSelectedMeetingTime

        }
        else if segue.identifier == "SegueToDetailMeetingLocationVC"{
            
            
//            let destinationNavigationController:UINavigationController = segue.destinationViewController as! UINavigationController
//            
//            let detailMeetingLocationVC: MUDetailMeetingLocationViewController = destinationNavigationController.topViewController as! MUDetailMeetingLocationViewController
            
            let detailMeetingLocationVC: MUDetailMeetingLocationViewController = segue.destinationViewController as! MUDetailMeetingLocationViewController
            
            detailMeetingLocationVC.meetingLocationArray = AnInvitation!.MeetingLocation
            
            detailMeetingLocationVC.sourceVC = self.sourceVC
            detailMeetingLocationVC.HaveSelected = self.HaveSelectedMeetingLocation
            
            detailMeetingLocationVC.selectedMeetingLocation = self.AnInvitation?.selectedMeetingLocation
            
            
        }
        else if segue.identifier == "SegueToDetailInvitedFriendVC"{
            
            
//            let destinationNavigationController:UINavigationController = segue.destinationViewController as! UINavigationController
//            
//            let detailInvitedFriendVC: MUDetailInvitedFriendViewController = destinationNavigationController.topViewController as! MUDetailInvitedFriendViewController
            
            
            let detailInvitedFriendVC: MUDetailInvitedFriendViewController = segue.destinationViewController as! MUDetailInvitedFriendViewController
            
            
            detailInvitedFriendVC.InvitedFriendEmail = AnInvitation?.InvitedFriendEmail

        }
        else if segue.identifier == "SegueToDetailInviterFriendVC"{
            
            
//            let destinationNavigationController:UINavigationController = segue.destinationViewController as! UINavigationController
//            
//            let detailInviterFriendVC: MUDetailInviterFriendViewController = destinationNavigationController.topViewController as! MUDetailInviterFriendViewController
            
            let detailInviterFriendVC: MUDetailInviterFriendViewController = segue.destinationViewController as!MUDetailInviterFriendViewController
            
            detailInviterFriendVC.InviterFriendEmail = AnInvitation?.InviterFriendEmail
            
        }
        else
        {
            
        
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    
        /*Display meeting name. */
        DisplayMeetingNameText.userInteractionEnabled = true
        DisplayMeetingNameText.editable = false
        
        DisplayMeetingNameText.text = AnInvitation?.MeetingName
        
        /*Display meeting description. */
        DisplayMeetingDescriptionText.userInteractionEnabled = true
        DisplayMeetingDescriptionText.editable = false
        
        DisplayMeetingDescriptionText.text = AnInvitation?.MeetingDescription


 
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
