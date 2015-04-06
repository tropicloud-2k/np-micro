# ------------------------
# NP START
# ------------------------

np_start() { np_env && exec /usr/bin/s6-svscan $home/run; }

# ------------------------
# NP STOP
# ------------------------

np_stop() { exec /usr/bin/s6-svscanctl -st $home/run; }

# ------------------------
# NP RESTART
# ------------------------

np_restart() { np_env && exec /usr/bin/s6-svc -t $home/run/$2; }

# ------------------------
# NP RELOAD
# ------------------------

np_reload() { np_env && exec /usr/bin/s6-svc -h $home/run/$2; }

# ------------------------
# NP STATUS
# ------------------------

np_status() {}

# ------------------------
# NP LOG
# ------------------------

np_log() {}

# ------------------------
# NP LOGIN
# ------------------------

np_login() { su -l $user; }

# ------------------------
# NP ROOT
# ------------------------

np_root() { /bin/sh; }

# ------------------------
# NP HALT
# ------------------------

np_halt() { exec /usr/bin/s6-svscanctl -st $home/run; }
