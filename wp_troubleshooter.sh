#!/bin/bash

url=$1;
rnd_str=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%*()-+' | fold -w 32 | head -1);
db_cfg=cfg_$rnd_str;

if [ "$url" == '' ]; then
  echo "Error, target link/domain is missing, e.g. wp_troubleshooter.sh domain.com/something";
  exit 0;
fi

check_if_ok() {
  w='';
  w=$(wget --spider $url -o wget.log; cat wget.log | grep response... | tail -1 | cut -d' ' -f 6);
  rm wget.log;
}

check_if_ok;
if [ "$w" == "200" ]; then
  echo "The return code is 200 OK, aborting.";
  exit 0;
fi

# Check permissions.

echo "Checking permissions...";
chmod 750 ./;
find ./ -type f -not -perm 644 -not -name ".ftpquota" -exec chmod 644 -c {} \; ; find ./ -type d -not -perm 755 -not -group nobody -exec chmod 755 -c {} \;
check_if_ok;

if [ "$w" != "200" ]; then
  echo "The error is still here.";
else
  echo "The error is gone, it was caused by incorrect files/folders permissions.";
  exit 0;
fi

# Check .htaccess.

echo "Renaming .htaccess.";
mv .htaccess .htaccess_$rnd_str;
check_if_ok;

if [ "$w" != "200" ]; then
  echo "The error is still here, renaming .htaccess back.";
  mv .htaccess_$rnd_str .htaccess;
else
  mv .htaccess_$rnd_str .htaccess;
  echo "The error is gone, it was caused by .htacecss, renaming it back";
  exit 0;
fi

#Check all plugins.
echo "Renaming ./wp-content/plugins.";
mv ./wp-content/plugins wp-content/plugins_$rnd_str;

check_if_ok;
if [ "$w" != "200" ]; then
  echo "The error is still here, renaming ./wp-content/plugins back.";
  mv ./wp-content/plugins_$rnd_str wp-content/plugins;
else
  mv ./wp-content/plugins_$rnd_str wp-content/plugins;
  echo "The error is gone, it was caused by the one of the plugins, renaming ./wp-content/plugins back.";
  exit 0;
fi

# Check default files.
echo "Replacing the WordPress default files..."
wget https://wordpress.org/latest.tar.gz && tar -xf latest.tar.gz && rsync -r wordpress/* ./ && rm -rf wordpress latest.tar.gz;

check_if_ok;
if [ "$w" == "200" ]; then
  echo "The error is gone, it was caused by an error in one of the default files.";
  exit 0;
fi


# Check the theme.
# get the database name, user, and user password from config.php
db_name=$(grep "define( 'DB_NAME', '.*' );" wp-config.php | cut -d' ' -f 3 | tr -d "'");
db_user=$(grep "define( 'DB_USER', '.*' );" wp-config.php | cut -d' ' -f 3 | tr -d "'");
db_pas=$(grep "define( 'DB_PASSWORD', '.*' );" wp-config.php | cut -d' ' -f 3 | tr -d "'");
tpref=$(grep "\$table_prefix = '.*'" wp-config.php | grep -oP "\'.+\'" | grep -oP "[\w\d_]*");
wpoptions=$tpref"options";
def_theme="twentytwenty";

# Set up config file for logging into the database without the password prompt
echo -e "[client]\nuser=$db_user\npassword=$db_pas" > $db_cfg;

cur_theme=$(mysql --defaults-extra-file=$db_cfg $db_name -e "select option_value from $wpoptions where option_name='stylesheet';" | tail -n +2);

echo "Changing the current $cur_theme theme to $def_theme.";

mysql --defaults-extra-file=$db_cfg $db_name -e "update $wpoptions set option_value='$def_theme' where option_name='template' or option_name='stylesheet';"

check_if_ok;
if [ "$w" == "200" ]; then
  echo "The error is gone, it was caused by the $cur_theme theme.";
else 
  echo "The error is not caused by .htaccess, plugins, default files, or the current theme.";
  echo "Let's disable everything.";
  echo "Disabling .htaccess, all plugins.";
  
  mv .htaccess .htaccess_$rnd_str;
  mv ./wp-content/plugins wp-content/plugins_$rnd_str;
  check_if_ok;

  if [ "$w" == "200" ]; then
    echo "The error is gone. Reversing the changes.";

  else
    echo "Nope, it didn't work. Reversing the changes.";
    echo "Try resetting CageFS, disabling ModSecurity.";
    echo "If none of that works, send to web developer; or check with SME first and then send to web developer.";
  fi

  mv .htaccess_$rnd_str .htaccess;
  mv ./wp-content/plugins_$rnd_str wp-content/plugins;

fi

echo "Changing the $def_theme theme back to $cur_theme.";

mysql --defaults-extra-file=$db_cfg $db_name -e "update $wpoptions set option_value='$cur_theme' where option_name='template' or option_name='stylesheet';";

rm $db_cfg;
