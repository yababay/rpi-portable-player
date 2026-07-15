# Файлы для управления плеером

## Конфигурация

* `./etc/mpd.conf` — конфиг `mpd`, адаптированный для работы в пользовательском пространстве в паре с `pipewire`;
* `./etc/wireplumber/wireplumber.conf.d/50-bluez-no-seat.conf` — конфиг `pipewire` для работы в «безголовом»

## Управление флешкой

* `./etc/udev/rules.d/99-music.rules` — реагирует на подключение / отключение флешки;
* `./etc/systemd/system/music-umount.service` — срабатывает при подключении флешки: монтирует, вызывает скрипт;
* `./etc/systemd/system/music-mount.service` — срабатывает при отключении флешки: размонтирует, вызывает скрипт;
* `./usr/local/bin/music-umount` — управление плеером и аудиоустройствами при монтировании (восстановление композиции, включение звука, если одно из устройств готово);
* `./usr/local/bin/music-mount` — управление плеером и аудиоустройствами при размонтировании (остановка плеера, запоминание композиции);

Перед началом работы нужно однократно выполнить `sudo loginctl enable-linger $USERNAME`, чтобы эмулировать присутствие пользователя в системе для `pipewire`. 

Также нужно запустить аудиосервисы от имени пользователя:

```bash
systemctl --user restart pipewire.service
systemctl --user restart wireplumber.service
systemctl --user restart mpd.service
```
