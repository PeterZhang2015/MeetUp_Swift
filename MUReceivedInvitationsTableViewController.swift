//
//  MUReceivedInvitationsTableViewController.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 25/08/2015.
//  Copyright (c) 2015 Chongzheng Zhang. All rights reserved.
//

import UIKit

class MUReceivedInvitationsTableViewController: UITableViewController {

    var  receivedInvitations = [Invitation]()
    var  SelectRowInvitation: Invitation?
    
    var haveGotReceivedInvitationInfo: Bool?
    
    @IBAction func cancelForDetailSentInvitationVC(segue:UIStoryboardSegue) {
        

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.haveGotReceivedInvitationInfo = false

        // It is used to trigger cellForRowAtIndexPath for updating table data in time.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.tableView.reloadData()
            
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(animated);
        
        // It is used to trigger cellForRowAtIndexPath for updating table data in time.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.tableView.reloadData()
            
        })
        
      //  if ((self.haveGotReceivedInvitationInfo != true))
 //       {
            
            let url: NSURL = NSURL(string: "http://meetupappsupportedserver.com/getallreceivedinvitationinfo.php")! // the web link of the provider.
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            
            request.HTTPMethod = "POST";  //Post to PHP in provider.
            
            
            /*Get AppDelegate. */
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
    
            // Compose login information with device token, login Email, and loginPassword
            let postString: NSString = "sInvitedEmail=\(appDelegate.accountInfo!.Email)"
            
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
                        NSLog("Get received invitation info Successfully!");
                        
                        let invitationNum = jsonData.valueForKey("invitationNum") as! Int
                        

                        let arraySentMeetingInfo = jsonData.valueForKey("arrayReceivedMeetingInfo") as! NSArray
                        
                        self.receivedInvitations.removeAll()
                        
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
                            
//                            let selectedMeetingTime:String = ""
//                            let selectedMeetingLocation:String = ""
                            
      
                            let selectedMeetingTime:String = arraySentMeetingInfo[index]["selectedMeetingTime"] as! String
   
                            let selectedMeetingLocation:String = arraySentMeetingInfo[index]["selectedMeetingLocation"] as! String
                       
    
                            var oneRowInvitation: Invitation?
                            
                            oneRowInvitation = Invitation(InvitationId: invitationID,MeetingName: meetingName, MeetingDescription: meetingDescription, MeetingTime: meetingTime, MeetingLocation: meetingLocation, InvitedFriendEmail: invitedFriendEmail, InviterFriendEmail: inviterFriendEmail,selectedMeetingTime: selectedMeetingTime, selectedMeetingLocation: selectedMeetingLocation, haveSelectedMeetingTimeFlag:haveSelectedMeetingTimeFlag, haveSelectedMeetingLocationFlag:haveSelectedMeetingLocationFlag)
                            
                            self.receivedInvitations.append(oneRowInvitation!)
                            self.tableView.reloadData()
                            
                        }
                        
                        self.haveGotReceivedInvitationInfo = true
                        
                        // It is used to trigger cellForRowAtIndexPath for updating table data in time.
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.tableView.reloadData()
                            
                        })
                            
               
                        
                        
                    }  // end of if(success == "1")
                    
                }// end of if (statusCode >= 200 && statusCode < 300)
                
                
            })
            
            task.resume()
      //  }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return receivedInvitations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get the cell according to it's identifier. */
        let cell = tableView.dequeueReusableCellWithIdentifier("ReceivedInvitationsCell", forIndexPath: indexPath)
        
        
        // Set the meeting name as the text label of the cell.
        cell.textLabel!.text = receivedInvitations[indexPath.row].MeetingName
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        SelectRowInvitation = self.receivedInvitations[indexPath.row]
        
        //performSegueWithIdentifier("SegueToDetailInvitationVC", sender: self)
        
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        SelectRowInvitation = self.receivedInvitations[indexPath.row]
        
        //performSegueWithIdentifier("SegueToDetailInvitationVC", sender: self)
        
        return indexPath
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SegueToDetailInvitationVC"{  /* Transfer Invitation information of the selected row from MUSentInvitationsTableViewController to MUDetailSentInvitationViewController*/
            
            
       //     let destinationNavigationController:UINavigationController = segue.destinationViewController as! UINavigationController
            
        //    let detailSentInvitationVC:MUDetailSentInvitationViewController = destinationNavigationController.topViewController as! MUDetailSentInvitationViewController
            
            let detailSentInvitationVC:MUDetailSentInvitationViewController = segue.destinationViewController as!MUDetailSentInvitationViewController
            
            detailSentInvitationVC.AnInvitation = self.SelectRowInvitation
            detailSentInvitationVC.sourceVC = 1  // 0-Sent Invitation VC, 1-Received Invitation VC
            
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
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
