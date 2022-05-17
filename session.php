<?php
session_start();

$_SESSION["count"]++;

print_r($_SESSION);