<body>
<?php
        //open a connection to dbase server
        include 'open.php';

        $attribute = $_POST['spotifyAttributes'];
        echo "<br><br>";
        echo "You entered ";
        echo $attribute;

if (!empty($attribute)){
	echo "not empty";
        if ($result = $conn->query("CALL GenreAvgs('".$attribute."');")) {
           echo "display graph??? here";
        }
}

        //close the connection to dbase
        $conn->close();

?>
</body>

