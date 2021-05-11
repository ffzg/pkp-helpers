#!/bin/sh -xe

# invoke with:
# sudo NO_BACKUP=1 ./omp-upgrade.sh ~/omp-3.3.0-6.tar.gz
# to skip backup

app=$( basename $0 | cut -d- -f1 )
dir=/var/www/$app
php=/usr/bin/php7.3
database_name=$( grep -A 100 '^\[database\]' $dir/config.inc.php  | grep ^name | head -1 | cut -d= -f2 )

date=$( date +%Y-%m-%d )

test -z "$1" && echo "Usage: $0 ~/$app-3.3.0-6.tar.gz" && exit 1
test "$( id -u )" -ne 0 && echo "re-run as root: sudo $0 $*" && exit 1

targz=$( realpath $1 )

tar_dir=$( basename $targz | sed 's/.tar.gz//')

if [ -z "$NO_BACKUP" ] ; then
echo "Backup $dir and $database_name"
tar cfpz /tmp/$app-backup-$date.tar.gz $dir /srv/$app/
mysqldump $database_name | gzip > /tmp/$app-backup-$date.sql.gz
ls -al /tmp/$app-backup-$date*
fi

echo "Upgrade to $tar_dir"

cd /var/www
tar xf $targz

chown -R root:root $tar_dir
chown -R www-data $tar_dir/cache/ $tar_dir/public/

cp -vp $app/config.inc.php $tar_dir
cp -rvp $app/public/* $tar_dir/public/

cp -rpv $app/plugins/generic/defaultTranslation $tar_dir/plugins/generic/

mv $app $app.old.$date
mv $tar_dir $app

cd $app

sudo -u www-data $php tools/upgrade.php check

sudo -u www-data $php tools/upgrade.php upgrade 2>&1 | tee ~/$app-upgrade-$date.log

