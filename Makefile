SHELL := /bin/zsh
APP_NAME := $(shell basename $(shell pwd))
# APP_NAME := $(shell git remote get-url origin | awk '{split($$0,a,"/");print a[2]}' | sed 's/\.git//g')

.PHONY: help # Show this help
help:
	@printf "Available targets for \033[92m$(APP_NAME)\033[0m:\n\n"
	@cat Makefile  | grep ".PHONY" | grep -v ".PHONY: _" | awk '{split($$0,a,".PHONY: ");split(a[2],b,"#");print "\033[36m"b[1]"\033[0m#"b[2]}' | column -s '#' -t


.PHONY: clean # 🫧
clean:
	rm -rf ./clam-*/
	git clean -fdx


.PHONY: macos # 🍎
macos:
	./getclams.arm64.macos.sh |& lolcat
