PACKAGE_NAME=rpi-portable-player
VERSION=1.0.17
BUILD_DIR=build

# Объявляем все цели как псевдоцели, чтобы избежать конфликтов с именами файлов
.PHONY: all clean build_structure package install

# Цель по умолчанию (all) теперь просто вызывает последовательно две главные команды
all: package install

clean:
	# Флаг -f гарантирует, что rm не вернет ошибку, если папки или пакета нет
	rm -rf $(BUILD_DIR)
	rm -f *.deb

build_structure: clean
	# Создаем структуру каталогов пакета
	mkdir -p $(BUILD_DIR)/DEBIAN
	mkdir -p $(BUILD_DIR)/etc/udev/rules.d
	mkdir -p $(BUILD_DIR)/etc/systemd/system
	mkdir -p $(BUILD_DIR)/etc/wireplumber/wireplumber.conf.d
	mkdir -p $(BUILD_DIR)/usr/local/bin

	# Копируем метаданные пакета
	cp DEBIAN/control $(BUILD_DIR)/DEBIAN/
	cp DEBIAN/postinst $(BUILD_DIR)/DEBIAN/
	chmod +x $(BUILD_DIR)/DEBIAN/postinst

	# Копируем системные конфиги, правила и настройки WirePlumber
	cp etc/udev/rules.d/99-music.rules $(BUILD_DIR)/etc/udev/rules.d/
	cp etc/systemd/system/music-mount.service $(BUILD_DIR)/etc/systemd/system/
	cp etc/systemd/system/music-umount.service $(BUILD_DIR)/etc/systemd/
	cp etc/systemd/system/bluetooth-audio.service $(BUILD_DIR)/etc/systemd/system/
	cp etc/systemd/system/gravity-daemon.service $(BUILD_DIR)/etc/systemd/system/
	cp etc/wireplumber/wireplumber.conf.d/50-bluez-no-seat.conf $(BUILD_DIR)/etc/wireplumber/wireplumber.conf.d/

	# Копируем исполняемые скрипты
	cp usr/local/bin/player-functions $(BUILD_DIR)/usr/local/bin/
	cp usr/local/bin/music-mount $(BUILD_DIR)/usr/local/bin/
	cp usr/local/bin/gravity-daemon $(BUILD_DIR)/usr/local/bin/
	chmod +x $(BUILD_DIR)/usr/local/bin/music-mount
	chmod +x $(BUILD_DIR)/usr/local/bin/gravity-daemon

package: build_structure
	# Собираем дебиан-пакет
	dpkg-deb --build $(BUILD_DIR) $(PACKAGE_NAME)_$(VERSION)_arm64.deb
	echo "Пакет успешно собран!"

install:
	# Вызываем установку собранного пакета
	sudo dpkg -i ./$(PACKAGE_NAME)_$(VERSION)_arm64.deb

reload:
	sudo systemctl daemon-reload
	sudo udevadm control --reload-rules
	sudo udevadm trigger

find:
	find . -path ./.git -prune -o -type f -print

git:
	git add .
	git commit -am from-radxa
	git push origin main

pull:
	sudo ip link set wlan0 up
	git pull origin main

push:
	sudo ip link set wlan0 up
	git push origin main

