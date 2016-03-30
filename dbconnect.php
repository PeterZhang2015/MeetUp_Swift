
<?php  
	
	/*** Connect to the server. ***/
    $conn = mysql_connect('localhost', 'root', '123456');  
    if (!$conn)
    {
		die('Could not connect: ' . mysql_error());
    }
	
	/*** Connect to the database. ***/
	$objDB = mysql_select_db("meetupdb");
	if (!$objDB)
    {
		die('Could not connect: ' . mysql_error());
    }
?>