


<?php

	include('dbconnect.php');
	
	/*** for Sample 
		$_POST["sUsername"] = "test";
		$_POST["sEmail"] = "test@gmail.com";
		$_POST["sPassword"] = "123";
	*/

	$strUsername	= $_POST["sUsername"];
	$strEmail		= $_POST["sEmail"];
	$strPassword	= $_POST["sPassword"];
    $strDeviceToken	= $_POST["sDeviceToken"];
    
    
    $arr = null;
    
    /* Just for test. */
    $arr["Username"] = $strUsername;
    $arr["Email"] = $strEmail;
    $arr["Password"] = $strPassword;
    $arr["DeviceToken"] = $strDeviceToken;
    


	/*** Check Email Exists ***/
	$strSQL = "SELECT * FROM accountinfo WHERE Email = '".$strEmail."' ";
	$objQuery = mysql_query($strSQL);
	$objResult = mysql_fetch_array($objQuery);
	if($objResult)   // Email Exists 
	{
		$arr["Success"] = "0";   // (0=Failed , 1=Complete)
		$arr["error_message"] = "Email Exists!";
		
		echo json_encode($arr);
		exit();
	}
	
	/*** Insert the information in the accountinfo table. ***/
	$strSQL = "INSERT INTO `meetupdb`.`accountinfo` (`DeviceToken`, `UsernName`, `Email`, `Password`) 
	VALUES ('$strDeviceToken', '$strUsername', '$strEmail', '$strPassword')";
	
	
	$objQuery = mysql_query($strSQL);
	if(!$objQuery) // Insert error.
	{
		$arr["Success"] = "0";  // (0=Failed , 1=Complete)
		$arr["error_message"] = "Cannot save data!";
		
		echo json_encode($arr);
		
		echo mysql_error();
		
		exit();
	}
	else
	{
		$arr["Success"] = "1";  // (0=Failed , 1=Complete)
		$arr["error_message"] = "Create an account successfully!";

		echo json_encode($arr);
		exit();
	}

	/**
	return

		Status // (0=Failed , 1=Complete)
		Message //  Message
	*/	

	
	mysql_close($objConnect);
	
?>