# Файлы для управления плеером

## Конфигурация

* `./etc/mpd.conf` — конфиг `mpd`, адаптированный для работы в пользовательском пространстве в паре с `pipewire`;
* `./etc/wireplumber/wireplumber.conf.d/50-bluez-no-seat.conf` — конфиг `pipewire` для работы в «безголовом»
* `./usr/local/bin/music-umount`
* `./usr/local/bin/music-mount`
* `./etc/udev/rules.d/99-music.rules`
* `./etc/systemd/system/music-umount.service`
* `./etc/systemd/system/music-mount.service`
