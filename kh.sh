#!/bin/bash
#
# Parsing useful WordPress-related information within a document root.
#+ It relies on /usr/local/sbin/wpfixwrap to get input details in a pre-defined
#+ order. The script does not apply any changes itself, but provides info only.
VERSION="20220406"
 
# MVP TESTING START #
DOCROOT="/home/emporeuss/public_html"
DOMAIN="futureen.us"
# MVP TESTING END   #
 
set -euo pipefail
 
################################################################################
# Getting input data and defining basic variables. Variables are caught
#+ the same way as in /usr/local/sbin/wpfix, i.e. position-based.
################################################################################
# ACTION="${3}"
# DIR="${4}"
# URL="${5}"
CP_USER="$(echo ${DOCROOT} | cut -d'/' -f3)"
CP_USER_IP="$(uapi Variables get_user_information name=ip | grep -oE "([0-9]{1,3}[\.]){3}[0-9]{1,3}")"
 
# SHELL_PIPE preserves ASCII formatting. (c) https://make.wordpress.org/cli/handbook/references/internal-api/wp-cli-utils-ispiped/
WPCLI="/usr/local/sbin/wp \
        --path=${DOCROOT} \
        --skip-plugins \
        --skip-themes" 2>/dev/null
 
NC="\e[0m"
WHITE="\e[1;97m"
GREEN="\e[1;92m"
RED="\e[1;91m"
YELLOW="\e[1;93m"
 
H1() {
  printf -- "\n\n${WHITE}# ⯆ %s${NC}\n" "$(echo "$@" | tr '[:lower:]' '[:upper:]')"
  printf -- "=%.0s" {1..80} ; echo
}
 
H2() {
  printf -- "\n${WHITE}## ⯆ %s${NC}\n" "$(echo "$@" | tr '[:lower:]' '[:upper:]')"
  printf -- "-%.0s" {1..80} ; echo
}
 
# A single time stamp for further use. Results in yyyy-mm-dd_epoch layout and
#+ is useful for further differentiation of prefixed files.
TIMESTAMP="$(date +%F_%s)"
 
################################################################################
# Logging and cleanup
################################################################################
LOGFILE="${DOCROOT}/${TIMESTAMP}_wpinfo_${DOMAIN}.log"
 
to_log() {
  tee -a "${LOGFILE}"
}
 
err() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S %z')] Error:${NC} $*" >&2
}
 
cleanup() {
  # a kind reminder
  echo -e "\n\n${YELLOW}Do not forget to remove ${LOGFILE} once finished!${NC}\n\n"
  # clearing the formatting
  sed -i 's/\x1b\[[0-9;]*m//g' "${LOGFILE}"
  # making the file inaccessible via web
  chmod 440 "${LOGFILE}"
}
trap cleanup EXIT
 
################################################################################
# Dump of functions
################################################################################
top_header() {
  H1 "WordPress at ${DOMAIN} | wpinfo v.${VERSION}"
}
 
cp_general() {
  echo -e "${WHITE}⯈ cPanel user:${NC}   ${CP_USER}"
  echo -e "${WHITE}⯈ cPanel IP:${NC}     ${CP_USER_IP}"
  echo -e "${WHITE}⯈ (sub)Domain:${NC}   ${DOMAIN}"
  echo -e "${WHITE}⯈ Document root:${NC} ${DOCROOT}"
  echo -e "${WHITE}⯈ Log location:${NC}  ${LOGFILE}"
}
 
http_status() {
  H2 "Via DNS query and curl"
  echo -e "Start location: http://${DOMAIN}\n"
  curl -skLI \
    --max-redirs 5 \
    --max-time 5 \
    -w "Final location: %{url_effective}" \
    "${DOMAIN}" 2>&1 \
      | { grep -E "^[[:space:]]*$|HTTP|[L,l]ocation|[S,s]erver" || test $? = 1; }
 
  H2 "Directly from ${CP_USER_IP} and wget"
  # curl v7.19.7 does not support --resolve ; hence, wget :()
  echo -e "Start location: https://${DOMAIN} (forced https!)\n"
  { wget --server-response \
    --no-check-certificate \
    --spider \
    --max-redirect=5 \
    --timeout=5 \
    --header="Host: ${DOMAIN}" \
    https://"${CP_USER_IP}" 2>&1 || true; } \
    | { grep -E "^Connecting|(^[[:space:]]+(HTTP|[L,l]ocation|[S,s]erver))" || test $? = 1; }
}
 
wp_config_check() {
  local WP_DB_NAME
  local WP_DB_USER
  local WP_DB_PASS
  local WP_DB_HOST
  local WP_DB_PRFX
  local WP_DB_CONN
  local WP_DB_CONN_V
 
  WP_DB_NAME="$( ${WPCLI} config get DB_NAME )" || true
  WP_DB_USER="$( ${WPCLI} config get DB_USER )" || true
  WP_DB_PASS="$( ${WPCLI} config get DB_PASSWORD )" || true
  WP_DB_HOST="$( ${WPCLI} config get DB_HOST )" || true
  WP_DB_PRFX="$( ${WPCLI} config get table_prefix )" || true
  WP_DB_CONN="mysql -t -u ${WP_DB_USER} -p${WP_DB_PASS} ${WP_DB_NAME}"
  WP_DB_CONN_V=""
   
  # Assessing the possibility to connect to db using the list of mysql user's
  #+ processes. The output table should retain its formatting.
  # WP_DB_PROC="$( ${WP_DB_CONN} -e 'SHOW PROCESSLIST;')"
  if ! ${WP_DB_CONN} -e 'SHOW PROCESSLIST;' 2>/dev/null | grep -qi "processlist"; then
    # if db connection test is unsuccessful
    WP_DB_CONN_V="0"
  else
    # if db connection test is successful
    WP_DB_CONN_V="1"
  fi;
 
  # Output
  echo -e "${WHITE}⯈ MySQL Database:${NC} ${WP_DB_NAME}"
  echo -e "${WHITE}⯈ MySQL User:${NC} ${WP_DB_USER}"
  echo -e "${WHITE}⯈ MySQL User Password:${NC} ${WP_DB_PASS}"
  echo -e "${WHITE}⯈ MySQL Hostname:${NC} ${WP_DB_HOST}"
  echo -e "${WHITE}⯈ Table prefix:${NC} ${WP_DB_PRFX}"
  if [[ "${WP_DB_CONN_V}" == "0" ]]; then
    err "Database connection was not successful. Tested with:\n${WP_DB_CONN} -e 'SHOW PROCESSLIST;' >/dev/null"
    exit 1
  elif [[ "${WP_DB_CONN_V}" == "1" ]]; then
    echo -e "${GREEN}⯈ Connection was successful.${NC}"
  fi
}
 
wp_general() {
  local WP_WPMU_V
  local WP_MAINTENANCE_V
   
  if ${WPCLI} core is-installed --network; then
    WP_WPMU_V="${YELLOW}yes!${NC}";
  else
    WP_WPMU_V="no";
  fi;
  
  if ${WPCLI} maintenance-mode is-active; then
    WP_MAINTENANCE_V="${YELLOW}active${NC}";
  else
    WP_MAINTENANCE_V="inactive";
  fi;
   
  # Output
  echo -e "${WHITE}⯈ WP core version:${NC} $(${WPCLI} core version || true)"
  echo -e "${WHITE}⯈ WP language:${NC} $(${WPCLI} language core list \
           --fields=language \
           --status=active \
           --format=csv \
           | grep -vi language)"
  echo -e "${WHITE}⯈ WPMU:${NC} ${WP_WPMU_V}"
  echo -e "${WHITE}⯈ Maintenance mode:${NC} ${WP_MAINTENANCE_V}"
  echo -e "${WHITE}⯈ Cache type:${NC} $(${WPCLI} cache type || true)"
 
  echo -e "${WHITE}⯈ Custom-defined constants in wp-config.php:${NC}"
  grep -Eio "define\(.*\);" ${DOCROOT}/wp-config.php \
    | grep -viE "DB_(NAME|USER|PASSWORD|HOST|CHARSET|COLLATE)|KEY|SALT|ABSPATH"
}
 
wp_options() {
  local WP_SITEURL
  local WP_HOMEURL
  local WP_ADMINEMAIL
  local WP_TEMPLATE
  local WP_STYLESHEET
 
  WP_SITEURL="$( ${WPCLI} option get siteurl || true )"
  if [[ "${WP_SITEURL}" =~ ${DOMAIN} ]]; then
    WP_SITEURL_V="${WP_SITEURL} | ${GREEN}Matches${NC} ${DOMAIN}";
  else
    WP_SITEURL_V="${WP_SITEURL} | ${RED}Does not match${NC} ${DOMAIN}";
  fi;
 
  WP_HOMEURL="$( ${WPCLI} option get home || true )"
  if [[ "${WP_HOMEURL}" =~ ${DOMAIN} ]]; then
    WP_HOMEURL_V="${WP_HOMEURL} | ${GREEN}Matches${NC} ${DOMAIN}";
  else
    WP_HOMEURL_V="${WP_HOMEURL} | ${RED}Does not match${NC} ${DOMAIN}";
  fi;
 
  WP_ADMINEMAIL="$( ${WPCLI} option get admin_email || true )"
  WP_TEMPLATE="$( ${WPCLI} option get template || true )"
  WP_STYLESHEET="$( ${WPCLI} option get stylesheet || true )"
   
  # Output
  echo -e "${WHITE}⯈ Site URL in DB:${NC} ${WP_SITEURL_V}"
  echo -e "${WHITE}⯈ Home URL in DB:${NC} ${WP_HOMEURL_V}"
  echo -e "${WHITE}⯈ Website admin email:${NC} ${WP_ADMINEMAIL}"
  echo -e "${WHITE}⯈ Template:${NC}   ${WP_TEMPLATE}"
  echo -e "${WHITE}⯈ Stylesheet:${NC} ${WP_STYLESHEET}"
  echo -ne "${WHITE}⯈ Posts:${NC} $(${WPCLI} post list --post_type=post --format=count || true) "
  echo -e "| ${WHITE}Pages:${NC} $(${WPCLI} post list --post_type=page --format=count || true)"
  echo -ne "${WHITE}⯈ Users:${NC} $(${WPCLI} user list --format=count || true) "
  echo -e "| ${WHITE}Admins:${NC} $(${WPCLI} user list --role=administrator --format=count || true)"
  echo -e "${WHITE}⯈ Comments:${NC}\n$(${WPCLI} comment count || true)"
}
 
wp_themes() {
  # Output
  H2 "List of themes"
  SHELL_PIPE=0 ${WPCLI} theme list --fields=title,name,status,version,update || true
 
  H2 "Auto-update status of themes"
  SHELL_PIPE=0 ${WPCLI} theme auto-updates status --all || true
}
 
wp_plugins() {
  # Output
  H2 "List of plugins"
  SHELL_PIPE=0 ${WPCLI} plugin list --all --fields=title,name,status,version,update || true
 
  H2 "Auto-update status of plugins"
  SHELL_PIPE=0 ${WPCLI} plugin auto-updates status --all || true
}
 
wp_crons() {
  # Output
  H2 "Test wp-cron trigger for ${DOMAIN}"
  SHELL_PIPE=0 ${WPCLI} cron test || true
 
  H2 "All scheduled wp-cron events for ${DOMAIN}"
  SHELL_PIPE=0 ${WPCLI} cron event list --fields=hook,next_run_relative,schedule || true
 
  H2 "cPanel account's crons"
  /usr/bin/crontab -l | grep -v "^$" || true
}
 
wp_log_files() {
  # Output
  find "${DOCROOT}" \
    -regextype posix-extended \
    -regex '.+(\.|_)log' \
    -exec ls -lht --time-style=long-iso {} + 2>/dev/null \
      | grep -viE "${DOMAIN}\.log$" \
      | awk '{print $6" "$7" "$5" "$8}' \
      | sort -r \
      | head -n5 \
      | while read -r ERLOG; do
          ERLOG_PATH="$(echo "${ERLOG}" | awk '{print $4}')";
          echo -e "${WHITE}⯈${NC} ${ERLOG}";
          tail -n50 "${ERLOG_PATH}" | { grep -E "^\[" || test $? = 1; } | tail -n5
        done;
}
 
wp_verify_checksums() {
  # Output
  H2 "WP system core files"
  SHELL_PIPE=0 ${WPCLI} core verify-checksums || true
cat<<EOF
 
 
Notes:
- False positive warnings DO happen. Do not perceive the list as an ultimate truth.
- "File should not exist" means that the file is not present in the default WordPress installation and is not required for WordPress to operate normally. Such a file might have been added by the suspicious scripts and may consist of backdoor code (the one used by the malware script to re-create itself).
- "File doesn't verify against checksum" means that the file can be found in the default WordPress installation, but the file's content is different. This may indicate that smbd or smth has tampered with this file. A closer look at its content is suggested. The warning can be fixed by replacing WordPress core files, if you are aware that no custom changes have been applied to the core files.
EOF
 
  H2 "WP plugins system files"
  SHELL_PIPE=0 ${WPCLI} plugin verify-checksums --all --strict || true
 
cat<<EOF
 
 
Notes:
- False positive warnings DO happen. Do not perceive the list as an ultimate truth.
- "Could not retrieve the checksums" means that plugin's default files are not available for comparison. This is a common warning for so-called "paid" plugins. Such plugins can be analyzed manually, e.g. at least by comparing the plugin's version against the one on the plugin's official website.
- "Checksum does not match" means that a particular plugin's file is not identical to the one offered by the plugin's developer. This may indicate that smbd or smth has tampered with this file. A closer look at its content is suggested. The warning can be fixed by re-installing the plugin, if you are aware that no custom changes have been applied to the plugin's files.
- "File was added" means that a certain file does not correspond to a default plugin core installation. Still, there are plugins, e.g. Elementor, which can create new files in their own folders and, as a result, triggering the warning message.
EOF
}
 
################################################################################
# Main function to rule them all
################################################################################
main() {
  top_header
 
  H1 "cPanel account general information"
  cp_general
 
  H1 "HTTP response status codes"
  http_status
 
  H1 "Database connection"
  [[ -s ${DOCROOT}/wp-config.php ]] \
    || { err "File ${DOCROOT}/wp-config.php is empty or absent." ; exit 1 ; }
  wp_config_check
   
  H1 "WordPress general information"
  wp_general
   
  H2 "Options"
  wp_options
 
  H1 "Themes"
  wp_themes
 
  H1 "Plugins"
  wp_plugins
 
  H1 "Cron jobs"
  wp_crons
 
  H1 "Five recent log files within ${DOCROOT}"
  wp_log_files
 
  H1 "Comparing existing WP files with the default ones"
  wp_verify_checksums
}
 
################################################################################
# Let's go
################################################################################
main "$@" |& to_log