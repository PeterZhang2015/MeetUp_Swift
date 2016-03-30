//
//  MUGlobalFunction.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 27/11/2015.
//  Copyright © 2015 Chongzheng Zhang. All rights reserved.
//

import Foundation
import UIKit




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



func createHttpPostRequest(destinationUrl: NSURL, postString: String)-> NSMutableURLRequest {
    
 
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



func sendHttpPost(request: NSMutableURLRequest, ProcessResponseFunc: (NSData) -> Void) {
    
    
    let session = NSURLSession.sharedSession()

    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in

        
        if (data != nil)
        {
            let responseData = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            print("responseData: \(responseData)")
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            NSLog("Response status code: %ld", statusCode);
            
            
            ProcessResponseFunc(data!)
            
        }
    
    
        })

    task.resume()
}














