<?php
 $to = "vova.futureen@gmail.com";
 $subject = "Test email!";
 $body = "Hello,\n\nThis is test email! Please do not delete it!";
 if (mail($to, $subject, $body)) {
    echo("<p>Message successfully sent!</p>");
   } else {
    echo("<p>Message delivery failed...</p>");
   }
?>