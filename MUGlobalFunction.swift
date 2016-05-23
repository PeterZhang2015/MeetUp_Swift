//
//  MUGlobalFunction.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 27/11/2015.
//  Copyright © 2015 Chongzheng Zhang. All rights reserved.
//

import Foundation
import UIKit



/* Send Alert view to the user. */
func sendAlertView(title: String, message: String) {
    
    dispatch_async(dispatch_get_main_queue(), {
        
        let alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
      //  alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    })

}


/* Create Http request to the supported web server. */
func createHttpPostRequest(destinationUrl: NSURL, postString: NSString)-> NSMutableURLRequest {
 
    let request:NSMutableURLRequest = NSMutableURLRequest(URL:destinationUrl)
    
    request.HTTPMethod = "POST";  //Post to PHP in provider.
    
    //Set information as the HTTP body
    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
    let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion:true)!
    let postLength:NSString = String( postData.length )
    
    request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    return request
    
}


/* Send Http request to supported web server for the information of an invitation and process corressponding response for an invitation. */
func interactionWithRemoteServerForAnInvitationThroughHttpPost(invitationID: NSInteger, request: NSMutableURLRequest, processResponseFunc: (NSInteger, NSData, NSURLResponse) -> Void, failToGetHttpResponse: (NSInteger, NSString) -> Void) -> Void {
    
    
    let session = NSURLSession.sharedSession()

    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in

        if (error != nil)
        {
            print("error: \(error)")
            failToGetHttpResponse(invitationID, error!.localizedDescription)
        }
        else
        {
            if ((data != nil) && (response != nil))
            {

                processResponseFunc(invitationID, data!, response!)
                
            }
            else
            {
                let errorMsg = "Unknown error"
                failToGetHttpResponse(invitationID, errorMsg)
            }
        }
    
        })

    task.resume()
}

/* Send Http request to supported web server without invitation information and process corressponding response for an invitation. */
func interactionWithRemoteServerWithoutInvitationThroughHttpPost(request: NSMutableURLRequest, processResponseFunc: (NSData, NSURLResponse) -> Void, failToGetHttpResponse: (NSString) -> Void) -> Void {
    
    
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        
        if (error != nil)
        {
            print("error: \(error)")
            failToGetHttpResponse(error!.localizedDescription)
        }
        else
        {
            if ((data != nil) && (response != nil))
            {
                
                processResponseFunc(data!, response!)
                
            }
            else
            {
                let errorMsg = "Unknown error"
                failToGetHttpResponse(errorMsg)
            }
        }
        
    })
    
    task.resume()
}



/* Process the HTTP response for an invitation according to the status code. */
func processHttpResponseAccordingToStatusCode(invitationID: NSInteger, statusCode: Int, data: NSData, processSuccessfulHttpResponse: (invitationID: NSInteger, jsonData: NSDictionary) -> Void, processFailureHttpResponse: (invitationID: NSInteger, errorMsg: NSString) -> Void) -> Void {
    
    let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
    
    if (statusCode >= 200 && statusCode < 300)
    {
        
        let responseData:NSString  = NSString(data:data, encoding:NSUTF8StringEncoding)!
        
        NSLog("Response ==> %@", responseData);
        
        let success:NSString = jsonData.valueForKey("Success") as! NSString
        
        NSLog("Success ==> %@", success);
        
        if(success == "1")
        {
            /*Get required information Successfully. */
            NSLog("Get required information Successfully. ");
            
            processSuccessfulHttpResponse(invitationID: invitationID, jsonData: jsonData)
            
        }
        else
        {
            /*Fail to get required information. */
            NSLog("Fail to get required information. ");
            var error_msg:NSString
            if jsonData["error_message"] as? NSString != nil {
                error_msg = jsonData["error_message"] as! NSString
            }
            else {
                
                error_msg = "Unknown Error"
                
            }
            
            processFailureHttpResponse(invitationID: invitationID, errorMsg: error_msg)
        }
        
    } // if (statusCode >= 200 && statusCode < 300)
    else
    {
        /*Fail to get required information. */
        NSLog("Fail to get required information. ");
        
        let error_msg = "Wrong status code"
        
        processFailureHttpResponse(invitationID: invitationID, errorMsg: error_msg)
    }  // end of the else of if (statusCode >= 200 && statusCode < 300)

}


/* Process the HTTP response without invitation according to the status code. */
func processHttpResponseAccordingToStatusCode(statusCode: Int, data: NSData, processSuccessfulHttpResponse: (jsonData: NSDictionary) -> Void, processFailureHttpResponse: (errorMsg: NSString) -> Void) -> Void {
    
    let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
    
    if (statusCode >= 200 && statusCode < 300)
    {
        
        let responseData:NSString  = NSString(data:data, encoding:NSUTF8StringEncoding)!
        
        NSLog("Response ==> %@", responseData);
        
        let success:NSString = jsonData.valueForKey("Success") as! NSString
        
        NSLog("Success ==> %@", success);
        
        if(success == "1")
        {
            /*Get required information Successfully. */
            NSLog("Get required information Successfully. ");
            
            processSuccessfulHttpResponse(jsonData: jsonData)
            
        }
        else
        {
            /*Fail to get required information. */
            NSLog("Fail to get required information. ");
            var error_msg:NSString
            if jsonData["error_message"] as? NSString != nil {
                error_msg = jsonData["error_message"] as! NSString
            }
            else {
                
                error_msg = "Unknown Error"
                
            }
            
            processFailureHttpResponse(errorMsg: error_msg)
        }
        
    } // if (statusCode >= 200 && statusCode < 300)
    else
    {
        /*Fail to get required information. */
        NSLog("Fail to get required information. ");
        
        let error_msg = "Wrong status code"
        
        processFailureHttpResponse(errorMsg: error_msg)
    }  // end of the else of if (statusCode >= 200 && statusCode < 300)
    
}

/*  Decode arrayMeetingInfo in the JASON value from response of supported web server as an invitation information. */
func decodeInvitationInfo(arryMeetingInfo: AnyObject) -> Invitation {
    
    var oneRowInvitation: Invitation?
    
    let invitationID:NSNumber = arryMeetingInfo["InvitationId"] as! NSNumber
    let meetingName:String = arryMeetingInfo["MeetingName"] as! String
    let meetingDescription:String = arryMeetingInfo["MeetingDescription"] as! String
    let meetingTime:[String] = arryMeetingInfo["MeetingTime"] as! [String]
    let meetingLocation:[String] = arryMeetingInfo["MeetingLocation"] as! [String]
    let invitedFriendEmail:String = arryMeetingInfo["InvitedFriendEmail"] as! String
    let inviterFriendEmail:String = arryMeetingInfo["InviterFriendEmail"] as! String
    let haveSelectedMeetingTimeFlag:Bool = arryMeetingInfo["haveSelectedMeetingTimeFlag"] as! Bool
    let haveSelectedMeetingLocationFlag:Bool = arryMeetingInfo["haveSelectedMeetingLocationFlag"] as! Bool
    
    
    let selectedMeetingTime:String = arryMeetingInfo["selectedMeetingTime"] as! String
    
    let selectedMeetingLocation:String = arryMeetingInfo["selectedMeetingLocation"] as! String
    
    
    oneRowInvitation = Invitation(InvitationId: invitationID,MeetingName: meetingName, MeetingDescription: meetingDescription, MeetingTime: meetingTime, MeetingLocation: meetingLocation, InvitedFriendEmail: invitedFriendEmail, InviterFriendEmail: inviterFriendEmail,selectedMeetingTime: selectedMeetingTime, selectedMeetingLocation: selectedMeetingLocation, haveSelectedMeetingTimeFlag:haveSelectedMeetingTimeFlag, haveSelectedMeetingLocationFlag:haveSelectedMeetingLocationFlag)
    
    return oneRowInvitation!
}


// end of MUGobalFunction.swift













