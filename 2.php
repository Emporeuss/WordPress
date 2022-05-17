<?php
$scan = scandir('Books & Library');
foreach($scan as $file) {
if (!is_dir("
http://www.ahistories.com/home/ahissoxv/public_html/wp-content/uploads/2022/03/Books
& Library")) {
echo $file.'\n';
}
}