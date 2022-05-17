<?php

$postdataxx=array(
'networkId' => 1,
'planId' => 61,
'phoneNumber' => '07083499315',
'reference' => 'TRX-7384'.mt_rand()

);

$url = "https://simhosting.ogdams.ng/api/v1/vend/data";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($postdataxx));  //Post Fields
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$headers = [
     "Content-Type: application/json",
    'Authorization: Bearer sk_live_5d527f08-24ba-4832-bed4-2d9ca66d4ace',
];
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
$response = curl_exec($ch);

if(! $response){
$response = curl_error($ch);
}

echo stripslashes($response);

curl_close($ch);
//curl_close($ch);

//echo $request;


?>