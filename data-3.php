<html>
    
    <body>
        
        Wecome this is a server data php trial man <?php
        
print "server starting";
// Read request parameters
$latitude= $_REQUEST["latitude"];
$longitude = $_REQUEST["longitude"];// Store values in an array
$returnValue = array("latitude"=>$latitude, "longitude"=>$longitude );// Send back request in JSON format


$mystring="Done";
$servername = "sxb1plzcpnl473185";
$username = "bolbol";
$password = "bolbol";
$dbname = "coordinates";

echo json_encode($mystring);
echo json_encode($returnValue); 



// Create connection

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
} 

$conn = new mysqli($servername, $username, $password, $dbname);
$sql = "INSERT INTO `my_coords` (latitude,longitude) VALUES('$latitude','$longitude')";
$sqlsec="SELECT * FROM my_coords ORDER BY DESC ID LIMIT 1";
$trial="SELECT * FROM my_coords WHERE  ID=(SELECT max(ID) FROM my_coords)";
$trial2="SELECT * FROM my_coords";



if ($longitude!=Null && $latitude!=Null){

	echo "iphone";


	if ($conn->query($sql) === TRUE) {
	  echo "New record created successfully";
	} else {
	  echo "Error: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
}

elseif($longitude==Null || $latitude==Null){

    echo "python callling";
    
   
	if ($result = $conn -> query($trial)) {
	  echo "RESULTS OUT";
	  echo "<br>";
	  echo $result->num_rows ;
	  $row = $result -> fetch_array(MYSQLI_NUM);
      echo "LAT" . $row[0];
      echo "LON" .$row[1];
     
	} else {
	  echo "Error: " . $trial . "<br>" . $conn->error;
	}
	
	$conn->close();
  	
	
	
} 



?>
        
        
        </body>
    
    </html>