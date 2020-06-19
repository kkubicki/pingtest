#!/bin/sh /etc/rc.common

EXTRA_COMMANDS="backup restore"
EXTRA_HELP=<<EOF
        backup  Backup vnstat database
        restore Restore vnstat database
EOF

START=98
STOP=10

vnstat_option() {
	sed -ne "s/^[[:space:]]*$1[[:space:]]*['\"]\([^'\"]*\)['\"].*/\1/p" /etc/vnstat.conf
}

BACKUP_FILE=/mnt/share/vnstat_backup.tar.gz
LOGGER_TAG=vnstat_backup
VNSTAT_DIR="$(vnstat_option DatabaseDir)"

backup_database() {
	if [ ! -d $VNSTAT_DIR ]; then
		logger -t $LOGGER_TAG -p err "cannot backup, data directory $VNSTAT_DIR does not exist (yet)"
	else
		logger -t $LOGGER_TAG -p info "backing up database"
		/bin/tar -zcf $BACKUP_FILE -C $VNSTAT_DIR .
	fi
}

restore_database() {
	if [ ! -f $BACKUP_FILE ]; then
		logger -t $LOGGER_TAG -p err "cannot restore, backup file does not exist (yet)"
	else
		logger -t $LOGGER_TAG -p info 'restoring database'
		[ ! -d $VNSTAT_DIR ] && mkdir $VNSTAT_DIR
		/bin/tar -xzf $BACKUP_FILE -C $VNSTAT_DIR
	fi
}

start() {
	restore_database
}

stop() {
	backup_database
}

backup() {
	backup_database
}

restore() {
	restore_database
}