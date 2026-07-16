PACKAGE_NAME=rpi-portable-player
VERSION=1.0.1
BUILD_DIR=build

clean:
	rm -rf $(BUILD_DIR) *.deb

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
	cp etc/systemd/system/bluetooth-audio.service $(BUILD_DIR)/etc/systemd/system/
	cp etc/systemd/system/gravity-daemon.service $(BUILD_DIR)/etc/systemd/system/
	cp etc/wireplumber/wireplumber.conf.d/50-bluez-no-seat.conf $(BUILD_DIR)/etc/wireplumber/wireplumber.conf.d/

	# Копируем исполняемые скрипты
	cp usr/local/bin/music-mount     $(BUILD_DIR)/usr/local/bin/
	cp usr/local/bin/bluetooth-audio $(BUILD_DIR)/usr/local/bin/
	cp usr/local/bin/gravity-daemon  $(BUILD_DIR)/usr/local/bin/
	cp usr/local/bin/gravity-player  $(BUILD_DIR)/usr/local/bin/
	chmod +x $(BUILD_DIR)/usr/local/bin/music-mount
	chmod +x $(BUILD_DIR)/usr/local/bin/bluetooth-audio
	chmod +x $(BUILD_DIR)/usr/local/bin/gravity-daemon
	chmod +x $(BUILD_DIR)/usr/local/bin/gravity-player

package: build_structure
	# Собираем дебиан-пакет
	dpkg-deb --build $(BUILD_DIR) $(PACKAGE_NAME)_$(VERSION)_arm64.deb
	echo "Пакет успешно собран!"

install:
	sudo dpkg -i ./$(PACKAGE_NAME)_$(VERSION)_arm64.deb

all: package install

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

