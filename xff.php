<?php
    $ip = '0.0.0.0';
    $ip = $_SERVER['REMOTE_ADDR'];
    $clientDetails = json_decode(file_get_contents("http://ipinfo.io/$ip/json"));
    echo "You're logged in from: <b>" . $clientDetails->country . "</b>";
?>
