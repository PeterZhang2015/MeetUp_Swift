<?php
	include('dbconnect.php');

	
	$strEmail = $_POST["sEmail"];
	$strCurrentPassword	 = $_POST["sCurrentPassword"];
	$strNewPassword = $_POST["sNewPassword"];
	
	/*** Select the record in the accountinfo table according to the received Email and Password. ***/
	$strSQL = "SELECT * FROM accountinfo WHERE 1 
		AND Email = '".$strEmail."'    
		";

	$objQuery = mysql_query($strSQL);
	$objResult = mysql_fetch_array($objQuery);
	$intNumRows = mysql_num_rows($objQuery);
	if($intNumRows==0)   // No record matched!
	{
		$arr["Success"] = "0";
		$arr["Email"] = $strEmail;
		$arr["error_message"] = "Incorrect Email";
		
		echo json_encode($arr);
		echo mysql_error();
		exit();
	}
	else     // Find the mathced record according to the received Email and Password.  
	{
		
		if ($objResult["Password"] != $strCurrentPassword)  // Current Password is different from actual password.
		{
			$arr["Success"] = "0";
			$arr["Email"] = $strEmail;
			$arr["error_message"] = "Current Password is incorrect!";
		}
		else {
			
			/*** Update the Password in accountinfo table of the database. ***/
			$strSQL = "UPDATE accountinfo 
					   SET Password = $strNewPassword
					   WHERE 1
						AND Email = '".$strEmail."'
						";
			
			$objQuery = mysql_query($strSQL);
			if($objQuery)   // Update password successfully!
			{
				$arr["objQuery"] = $objQuery;
				$arr["Success"] = "1";
				$arr["Email"] = $strEmail;
				$arr["error_message"] = "Change Password Successfully";
			}
			else  // Fail to update password.
			{
				$arr["Success"] = "0";
				$arr["Email"] = $strEmail;
				$arr["error_message"] = "Incorrect Email";
					
				echo json_encode($arr);
				echo mysql_error();
				exit();	
			}
			

		}
		
		


		echo json_encode($arr);
		exit();
	}

	/**
	return 
		 // (0=Failed , 1=Complete)
		 // MemberID
		 // Error Message
	*/
	
	mysql_close($objConnect);
	
?>