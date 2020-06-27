#!/bin/sh -xe

mysql $( grep -A 10 '^.database' /var/www/ojs/config.inc.php  | egrep '(username|password|name)' | sed -e 's/^name/database/' -e 's/username/user/g' -e 's/ //g' -e 's/^/--/g')

