<?php
$serverName = "127.0.0.1";
$dbName = "mysql";
$userName = "root";
$password = "Kh@666666";/*密码默认不用填*/
try {
    $conn = new PDO("mysql:host=$serverName;dbname=$dbName", $userName, $password);
    echo "connect mysql success";
} catch(PDOExeption $e) {
    echo $e->getMessage();
}
?>