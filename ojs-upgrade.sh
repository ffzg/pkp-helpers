#!/bin/sh -xe

dir=/var/www/ojs
php=/usr/bin/php7.3
database_name=$( grep -A 100 '^\[database\]' $dir/config.inc.php  | grep ^name | head -1 | cut -d= -f2 )

date=$( date +%Y-%m-%d )

test -z "$1" && echo "Usage: $0 ~/ojs-3.3.0-6.tar.gz" && exit 1
test "$( id -u )" -ne 0 && echo "re-run as root: sudo $0 $*" && exit 1

targz=$1

tar_dir=$( basename $targz | sed 's/.tar.gz//')


echo "Backup $dir and $database_name"
tar cfpz /tmp/ojs-backup-$date.tar.gz $dir /srv/ojs/
mysqldump $database_name | gzip > /tmp/ojs-backup-$date.sql.gz
ls -al /tmp/ojs-backup-$date*

echo "Upgrade to $tar_dir"

cd /var/www
tar xf $targz

chown -R root:root $tar_dir
chown -R www-data $tar_dir/cache/ $tar_dir/public/

cp -vp ojs/config.inc.php $tar_dir
cp -rvp ojs/public/* $tar_dir/public/

cp -rpv ojs/plugins/generic/defaultTranslation $tar_dir/plugins/generic/

mv ojs ojs.old.$date
mv $tar_dir ojs

cd ojs

sudo -u www-data $php tools/upgrade.php check

sudo -u www-data $php tools/upgrade.php upgrade 2>&1 | tee ~/ojs-upgrade-$date.log

