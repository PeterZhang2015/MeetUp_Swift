


<?php

	include('dbconnect.php');
	

	/*Get invitationID from POST message. */
	$iInvitationID		= $_POST["iInvitationID"];
	

	/*Initialize return array. */
    $arr = null;
    
    
    /*** Get the information in the invitation table. ***/
	$strSQL = "SELECT SelectedMeetingTime FROM selectedinvitationtime WHERE InvitationID = '".$iInvitationID."' ";
	$objQuery = mysql_query($strSQL);
	//$objResult = mysql_fetch_array($objQuery, MYSQL_ASSOC);
	$objResult = mysql_fetch_array($objQuery);
	if(!$objResult)   // invitationID does not exist. 
	{
		$arr["Success"] = "0";   // (0=Failed , 1=Complete)
		$arr["error_message"] = "Invitation ID does not exist!";
		
		echo json_encode($arr);
		exit();
	}
	
	$arr["SelectedMeetingTime"] = $objResult['SelectedMeetingTime'];


	$arr["Success"] = "1";    // (0=Failed , 1=Complete)
    // Return debug information.
	echo json_encode($arr);
	exit();
    

    mysql_close($objConnect);
    
 
    
    
?>