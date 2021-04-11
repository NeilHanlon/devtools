.PHONY: all

all: srpmproc/srpmproc

.dnf:
	sudo yum -y install epel-release
	sudo yum -y groupinstall "Development Tools"
	sudo yum -y install golang mock nginx createrepo
	touch .dnf

.system:
	sudo systemctl start nginx
	sudo systemctl enable nginx
	touch .system


srpmproc:
	git clone https://git.rockylinux.org/release-engineering/public/srpmproc.git
	cd srpmproc; git checkout -b working 99809a4ead5c3cc8907739365a07df35117a2669 # srpmproc HEAD is broken right now


srpmproc/srpmproc: srpmproc
	cd srpmproc; CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/srpmproc


install: srpmproc/srpmproc .dnf .system
	install -m 644 etc_mock/*.cfg /etc/mock/
	install -m 644 etc_mock/rockybuild8.tpl /etc/mock/templates/
	install -m 644 etc_mock/rockycentos-8.tpl /etc/mock/templates/
	install -m 644 etc_mock/myrocky.tpl /etc/mock/templates/
	install -m 755 srpmproc/srpmproc /usr/local/bin/
	install -m 755 bin/* /usr/local/bin/
	test -d /usr/share/nginx/html/repo || mkdir /usr/share/nginx/html/repo
	chmod 777 /usr/share/nginx/html/repo


clean:
	rm -rf srpmproc