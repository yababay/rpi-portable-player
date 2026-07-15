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

