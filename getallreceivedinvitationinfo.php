<?php
	include('dbconnect.php');

	
// 	class $aSentInvitationInfo{
// 		public $id;
// 		public $person;
// 		public $item;
// 		public $descr;
// 		public $link;
// 		public $price;
// 	}

	$strInvitedEmail	 = $_POST["sInvitedEmail"];


	$arr = null;
	
	$arr["sInvitedEmail"] = $strInvitedEmail;
	$arr["Success"] = "0";
	
	
	/*** Select the record . ***/
	$strSQL = "SELECT * FROM invitations WHERE 1 
		";

	$objQuery = mysql_query($strSQL);
	if(!$objQuery) //  error.
	{
		$arr["Success"] = "0";  // (0=Failed , 1=Complete)
		$arr["error_message"] = "no sent inviatation exist!";
	
		echo json_encode($arr);
	
		echo mysql_error();
	
		exit();
	}

	$j = 0;
	

// 	$row = mysql_fetch_array($objQuery);
	
// 	$arr["row"] = $row;
	
	while($row = mysql_fetch_array($objQuery))
	{
		
		$rowInvitedEmail = $row["InvitedEmail"];
		
		if ($rowInvitedEmail == $strInvitedEmail)
		{
		
			$arr["Success"] = "1";
	
			// Get meeting information
	    	$invitationID = $row["InvitationID"];
			$strMeetingName = $row["MeetingName"];
			$strMeetingDescription = $row["MeetingDescription"];
			$strInviterEmail = $row["InviterEmail"];
			
			
			//Get selected meeting time info
			$strSQL = "SELECT * FROM selectedinvitationtime WHERE InvitationID = '".$invitationID."' ";
			$objTimeQuery = mysql_query($strSQL);
			$objResult = mysql_fetch_array($objTimeQuery);
			if ($objResult)
			{
				$srtSelectedMeetingTime = $objResult["SelectedMeetingTime"];
				$haveSelectedMeetingTimeFlag = 1;
			}
			else {
				$srtSelectedMeetingTime = "";
				$haveSelectedMeetingTimeFlag = 0;
			}
				
			if ($haveSelectedMeetingTimeFlag == 0)
			{
				
				continue;
			}
				
			//Get selected meeting location info
			$strSQL = "SELECT SelectedInvitationLocation FROM selectedinvitationlocation WHERE InvitationID = '".$invitationID."' ";
			$objLocationQuery = mysql_query($strSQL);
			$objResult = mysql_fetch_array($objLocationQuery);
			if ($objResult)
			{
				$srtSelectedMeetingLocation = $objResult["SelectedInvitationLocation"];
				$haveSelectedMeetingLocationFlag = 1;
			}
			else {
					
				$srtSelectedMeetingLocation = "";
				$haveSelectedMeetingLocationFlag = 0;
			}
			
			if ($haveSelectedMeetingLocationFlag == 0)
			{
			
				continue;
			}
			
			//Get all meeting time info
			$strSQL = "SELECT * FROM invitationtimes WHERE InvitationID = '".$invitationID."' ";
			$objAllTimeQuery = mysql_query($strSQL);
			
			$i = 0;
			while($objResult = mysql_fetch_array($objAllTimeQuery))
			{
				$arrayAllTime[$i] = $objResult["MeetingTime"];
				$i ++;
			}
			
			//Get all meeting location info
			$strSQL = "SELECT * FROM invitationlocations WHERE InvitationID = '".$invitationID."' ";
			$objAllTimeQuery = mysql_query($strSQL);
			
			$i = 0;
			while($objResult = mysql_fetch_array($objAllTimeQuery))
			{
				$arrayAllLocation[$i] = $objResult["MeetingLocation"];
				$i ++;
			}
			
			

			
		
	
			$aReceivedInvitationInfo[$j] = array(
					"InvitationId" => intval($invitationID),
					"MeetingName" => $strMeetingName,
					"MeetingDescription" => $strMeetingDescription,
					"MeetingTime" => $arrayAllTime,
					"MeetingLocation" => $arrayAllLocation,
					"InvitedFriendEmail" => $strInvitedEmail,
					"InviterFriendEmail" => $strInviterEmail,
					"selectedMeetingTime" => $srtSelectedMeetingTime,
					"selectedMeetingLocation" => $srtSelectedMeetingLocation,
					"haveSelectedMeetingTimeFlag" => $haveSelectedMeetingLocationFlag,
					"haveSelectedMeetingLocationFlag" => $haveSelectedMeetingLocationFlag,
			);
			$j ++;
		
		}// end of if ($rowInviterEmail == $strInviterEmail)
	}// end of while($row = mysql_fetch_array($objQuery))

	if ($j == 0)
	{	
		$arr["Success"] = "0";
	}
	
	
	$arr["invitationNum"] = $j;
	$arr["i"] = $i;

	$arr["arrayReceivedMeetingInfo"] = $aReceivedInvitationInfo;

	echo json_encode($arr);
	exit();

	/**
	return 
		 // (0=Failed , 1=Complete)
		 // MemberID
		 // Error Message
	*/
	
	mysql_close($objConnect);
	
?>