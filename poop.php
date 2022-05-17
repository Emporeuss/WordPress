<?php
if (file_exists('init.php')) {
    require('init.php');
} elseif (file_exists('../init.php')) {
    require('../init.php');
} else {
    echo "Init File not Found";
}

session_start();

$_SESSION["count"]++;

print_r($_SESSION);