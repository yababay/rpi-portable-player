#!/bin/bash

DEVNAME=$1
ACTION=$2
MOUNT_POINT="/mnt/music"
STATE_DIR="/var/lib/mpd/usb_states"

# Создаем папку для хранения позиций флешек, если её нет
mkdir -p $STATE_DIR

# Получаем уникальный UUID вставленной флешки
UUID=$(blkid -o value -s UUID $DEVNAME)

if [ "$ACTION" = "add" ] && [ -n "$UUID" ]; then
         # 1. Принудительно размонтируем старое и чистим точку
         umount -l $MOUNT_POINT 2>/dev/null
         mkdir -p $MOUNT_POINT

         # 2. Монтируем вставленную флешку
         mount -o ro,uid=pi,gid=pi $DEVNAME $MOUNT_POINT

         # 3. Обновляем базу данных MPD
         /usr/bin/mpc update --wait
         /usr/bin/mpc clear

         STATE_FILE="$STATE_DIR/$UUID"

         # 4. Логика выбора: фиксированный плейлист ИЛИ перемешивание всего
         if [ -f "$MOUNT_POINT/autoplay.m3u" ]; then
                # Нашли autoplay.m3u — отключаем случайный порядок
                /usr/bin/mpc random off
           
                # Загружаем плейлист
                cat "$MOUNT_POINT/autoplay.m3u" | /usr/bin/mpc add
           
                # Проверяем, есть ли сохраненная позиция для этой флешки
                if [ -f "$STATE_FILE" ]; then
                        # Читаем номер трека и секунду из файла сохранения
                        read TRACK TIME < "$STATE_FILE"
         
                        # Переходим на нужный трек
                        /usr/bin/mpc play $TRACK
                        # Перематываем на нужную секунду
                        /usr/bin/mpc seek $TIME
                else
                        # Если флешка новая — просто играем с начала
                        /usr/bin/mpc play
                fi
          else
                # Плейлиста нет — загружаем всё скопом
                /usr/bin/mpc listall | /usr/bin/mpc add
          
                # Включаем режим перемешивания (Shuffle)
                /usr/bin/mpc random on
                /usr/bin/mpc play
         fi

          # Включаем режим повтора всей флешки
         /usr/bin/mpc repeat on

elif [ "$ACTION" = "remove" ]; then
         # Перед тем как стереть всё, пытаемся сохранить позицию (если флешка вынимается программно)
         # Примечание: если флешку выдернуть «на горячую», UUID получить не удастся, 
         # поэтому для аудиокниг лучше перед извлечением ставить на паузу с пульта.
         if [ -n "$UUID" ] && [ -f "$MOUNT_POINT/autoplay.m3u" ]; then
                # Получаем номер текущего трека (индекс с 1) и позицию в секундах
                CURRENT_TRACK=$(/usr/bin/mpc status | grep -E "\[playing\]|\[paused\]" | awk '{print $2}' | cut -d/ -f1 | tr -d '#[]')
                CURRENT_TIME=$(/usr/bin/mpc status | grep -E "\[playing\]|\[paused\]" | awk '{print $3}' | cut -d/ -f1 | awk -F: '{if(NF==3){print $1*3600+$2*60+$3}else{print $1*60+$2}}')
           
                if [ -n "$CURRENT_TRACK" ] && [ -n "$CURRENT_TIME" ]; then
                        echo "$CURRENT_TRACK $CURRENT_TIME" > "$STATE_DIR/$UUID"
                fi
         fi

         /usr/bin/mpc stop
         /usr/bin/mpc clear
         umount -l $MOUNT_POINT
fi
