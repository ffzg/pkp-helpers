#!/bin/sh -xe

pkp=$( basename $0 | cut -d- -f1 )

mysql $( grep -A 10 '^.database' /var/www/$pkp/config.inc.php  | egrep '(username|password|name)' | sed -e 's/^name/database/' -e 's/username/user/g' -e 's/ //g' -e 's/^/--/g')

