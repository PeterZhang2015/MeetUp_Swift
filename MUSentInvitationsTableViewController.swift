//
//  MUSentInvitationsTableViewController.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 25/08/2015.
//  Copyright (c) 2015 Chongzheng Zhang. All rights reserved.
//

import UIKit

class MUSentInvitationsTableViewController: UITableViewController {
    
    
    var  Invitations = [Invitation]()
    var  SelectRowInvitation: Invitation?
    
    var haveGotSentInvitationInfo: Bool?
    
    
 
    @IBAction func cancelForDetailSentInvitationVC(segue:UIStoryboardSegue) {
        
        
//        let sourceVC:MUDetailSentInvitationViewController = segue.sourceViewController as! MUDetailSentInvitationViewController
//        
//        if (sourceVC.sourceVC == 1)   //    0-Sent Invitation VC, 1-Received Invitation VC
//        {
//            
//            //performSegueWithIdentifier("ReceivedInvitationsVC", sender: self)
//           // dispatch_async(dispatch_get_main_queue(), {
//            /*Get AppDelegate. */
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            
//            appDelegate.window?.makeKeyAndVisible()
//            
//            /*********** Way of transfering to a specific tabbar. *****************/
//            appDelegate.tabBarController?.selectedIndex = 1 // 0-send invitation viewcontroller, 1-received invitation viewcontroller, 2-settings.
//            appDelegate.window?.rootViewController = self.tabBarController
//         //   })
//        }

        
    }
    


    
    @IBAction func cancelForAnSentInvitationVC(segue:UIStoryboardSegue) {
        
  
        
    }
    
    
    @IBAction func doneForAnSentInvitationVC(segue:UIStoryboardSegue) {
        
        if let AnSentInvitationVC = segue.sourceViewController as? MUAnSentInvitationViewController {
            
            //add the new invitation to the invitation array
            Invitations.append(AnSentInvitationVC.newInvitation!)
            
            tableView.reloadData()
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.haveGotSentInvitationInfo = false
        
        // It is used to trigger cellForRowAtIndexPath for updating table data in time.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.tableView.reloadData()
            
        })

    }
    
    
    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(animated);
        
        // It is used to trigger cellForRowAtIndexPath for updating table data in time.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.tableView.reloadData()
            
        })
        
        if ((self.haveGotSentInvitationInfo != true))
        {
        
            let url: NSURL = NSURL(string: "http://192.168.0.23.xip.io/~chongzhengzhang/php/getallsentinvitationinfo.php")! // the web link of the provider.
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            
            request.HTTPMethod = "POST";  //Post to PHP in provider.
            
            
            /*Get AppDelegate. */
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            // Compose login information with device token, login Email, and loginPassword
            let postString: NSString = "sInviterEmail=\(appDelegate.accountInfo!.Email)"
            
            NSLog("Input Email for querying sent invitation info ==> %@", appDelegate.accountInfo!.Email);
            
            
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

                        /*Show the successful login result. */
                        NSLog("Get sent invitation info Successfully!");

                        let invitationNum = jsonData.valueForKey("invitationNum") as! Int
                        
                        let arraySentMeetingInfo = jsonData.valueForKey("arraySentMeetingInfo") as! NSArray
                        
                        self.Invitations.removeAll()

                        for index in 0 ..< invitationNum
                        {
                            let invitationID:NSNumber = arraySentMeetingInfo[index]["InvitationId"] as! NSNumber
                            let meetingName:String = arraySentMeetingInfo[index]["MeetingName"] as! String
                            let meetingDescription:String = arraySentMeetingInfo[index]["MeetingDescription"] as! String
                            let meetingTime:[String] = arraySentMeetingInfo[index]["MeetingTime"] as! [String]
                            let meetingLocation:[String] = arraySentMeetingInfo[index]["MeetingLocation"] as! [String]
                            let invitedFriendEmail:String = arraySentMeetingInfo[index]["InvitedFriendEmail"] as! String
                            let inviterFriendEmail:String = arraySentMeetingInfo[index]["InviterFriendEmail"] as! String
                            let haveSelectedMeetingTimeFlag:Bool = arraySentMeetingInfo[index]["haveSelectedMeetingTimeFlag"] as! Bool
                            let haveSelectedMeetingLocationFlag:Bool = arraySentMeetingInfo[index]["haveSelectedMeetingLocationFlag"] as! Bool
                            
                            let selectedMeetingTime:String = ""
                            
        //                        if(haveSelectedMeetingTimeFlag)
        //                        {
        //                            let selectedMeetingTime:String = arraySentMeetingInfo[index]["selectedMeetingTime"] as! String
        //                        }
              
                            let selectedMeetingLocation:String = ""
        //                        if(haveSelectedMeetingLocationFlag)
        //                        {
        //                            let selectedMeetingLocation:String = arraySentMeetingInfo[index]["selectedMeetingLocation"] as! String
        //                        }
        //     
                            var oneRowInvitation: Invitation?
                            
                            oneRowInvitation = Invitation(InvitationId: invitationID,MeetingName: meetingName, MeetingDescription: meetingDescription, MeetingTime: meetingTime, MeetingLocation: meetingLocation, InvitedFriendEmail: invitedFriendEmail, InviterFriendEmail: inviterFriendEmail,selectedMeetingTime: selectedMeetingTime, selectedMeetingLocation: selectedMeetingLocation, haveSelectedMeetingTimeFlag:haveSelectedMeetingTimeFlag, haveSelectedMeetingLocationFlag:haveSelectedMeetingLocationFlag)
                            
                            self.Invitations.append(oneRowInvitation!)
                            self.tableView.reloadData()
                            
                        }
                        
                        self.haveGotSentInvitationInfo = true
           
                        // It is used to trigger cellForRowAtIndexPath for updating table data in time.
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.tableView.reloadData()
                            
                        })
                        
                        

                    }  // end of if(success == "1")
                    
                }// end of if (statusCode >= 200 && statusCode < 300)

                
            })
            
            task.resume()
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return Invitations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {


        /* Get the cell according to it's identifier. */
        let cell = tableView.dequeueReusableCellWithIdentifier("SentInvitationsCell", forIndexPath: indexPath)
        
        
        // Set the meeting name as the text label of the cell.
        cell.textLabel!.text = self.Invitations[indexPath.row].MeetingName

        return cell

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        SelectRowInvitation = self.Invitations[indexPath.row]
  
        //performSegueWithIdentifier("SegueToDetailSentInvitationVC", sender: self)

    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        SelectRowInvitation = self.Invitations[indexPath.row]
        
        //performSegueWithIdentifier("SegueToDetailSentInvitationVC", sender: self)
        
        return indexPath
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SegueToDetailSentInvitationVC"{  /* Transfer Invitation information of the selected row from MUSentInvitationsTableViewController to MUDetailSentInvitationViewController*/
            
            
//            let destinationNavigationController:UINavigationController = segue.destinationViewController as! UINavigationController
//            
//            let detailSentInvitationVC:MUDetailSentInvitationViewController = destinationNavigationController.topViewController as! MUDetailSentInvitationViewController
            
            let detailSentInvitationVC:MUDetailSentInvitationViewController = segue.destinationViewController as! MUDetailSentInvitationViewController
            
            detailSentInvitationVC.AnInvitation = self.SelectRowInvitation
            detailSentInvitationVC.sourceVC = 0  // 0-Sent Invitation VC, 1-Received Invitation VC
            
            if (self.SelectRowInvitation?.haveSelectedMeetingLocationFlag == true)
            {
                detailSentInvitationVC.HaveSelectedMeetingLocation = 1
            }
            
            if (self.SelectRowInvitation?.haveSelectedMeetingTimeFlag == true)
            {
                detailSentInvitationVC.HaveSelectedMeetingTime = 1
            }
            
        }
        
    }





    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
