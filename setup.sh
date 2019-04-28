#! /usr/bin/env bash

dir=`pwd`
source ~/.profile


set -e
trap "[[ \$BASH_COMMAND != echo* && \$BASH_COMMAND != section* ]] && echo \$(prompted \$BASH_COMMAND)" DEBUG

function prompted() {
	echo -e "\e[32m> $@\e[39m"
}

function section() {
	echo -e "\n\n\n\e[1m\e[35m$@\e[39m\e[0m\n"
}

function end_section() {
	echo -e "\n\e[1m\e[35mDone.\e[39m\e[0m\n"
}

function add_service() {
	trap "[[ \$BASH_COMMAND != echo* && \$BASH_COMMAND != section* ]] && echo \$(prompted \$BASH_COMMAND)" DEBUG
	if ! diff services/$@.service /etc/systemd/system/$@.service; then
		section Setting up $@ service

		cp services/$@.service /etc/systemd/system/
		chmod 644 /etc/systemd/system/$@.service
		systemctl daemon-reload
		systemctl enable $@
		end_section
	fi
	echo
}




section Updating package repositories

add-apt-repository ppa:neovim-ppa/unstable -y
add-apt-repository ppa:jonathonf/python-3.6 -y

apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y

end_section
echo


section Enabling firewall
ufw allow OpenSSH
ufw --force enable
end_section
echo


if ! which fish; then
	section Installing fish shell
	apt-get install fish -y
	end_section
fi
echo

if ! grep -q fish /etc/shells; then
	section Approving fish shell
	echo "/usr/bin/fish" | tee -a /etc/shells
	end_section
fi
echo

if ! which nvim; then
	section Installing neovim
	apt-get install neovim  -y
	end_section
fi
echo


python3_version=3.6
if ! which python$python3_version; then
	section Installing python $python3_version

	apt-get install software-properties-common python-software-properties -y
	apt-get install python$python3_version -y
	rm /usr/bin/python3
	ln -s /usr/bin/python$python3_version /usr/bin/python3
	if ! test -f /usr/lib/python3/dist-packages/apt_pkg.cpython-36m-x86_64-linux-gnu.so; then
		ln -s   /usr/lib/python3/dist-packages/apt_pkg.cpython-35m-x86_64-linux-gnu.so \
			/usr/lib/python3/dist-packages/apt_pkg.cpython-36m-x86_64-linux-gnu.so
	fi
	end_section
fi
echo


if ! which node; then
	section Installing node

	curl -sL https://deb.nodesource.com/setup_12.x | bash -
	apt-get install -y nodejs
	if ! test -f /usr/local/bin/node; then
		ln -s /usr/bin/nodejs /usr/local/bin/node
	fi
	end_section
fi
echo

if ! which yarn; then
	section Installing yarn
	npm i -g yarn
	end_section
fi
echo


if ! which go; then
	section Installing golang

	go_version=1.12.4
	curl -o go.tgz https://dl.google.com/go/go$go_version.linux-amd64.tar.gz
	tar -C /usr/local -xzf go.tgz
	if ! grep -qw GOPATH ~/.profile; then
		echo 'export GOPATH=$HOME/go' | tee -a ~/.profile
		echo 'export PATH=$PATH:$GOPATH/bin' | tee -a ~/.profile
		echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a ~/.profile
		source ~/.profile
	fi
	end_section
fi
echo


if ! which psql; then
	section install postgresql db

	apt install postgresql postgresql-contrib
	cp conf/pg_hba.conf /etc/postgresql/9.5/main/
	systemctl restart postgresql
	end_section
fi
echo


for file in `ls bin`; do
	if ! diff bin/$file /usr/local/bin/$file; then
		section Installing $file
		cp bin/$file /usr/local/bin
		end_section
	fi
done
echo


if ! which caddy_with_plugins; then
	section Installing caddy server

	rm -rf /etc/ssl/caddy/

	mkdir -p $GOPATH/src/popefucker.com
	cp -r caddy-with-plugins $GOPATH/src/popefucker.com
	cd $GOPATH
	GO111MODULE=on go get github.com/mholt/caddy/caddy

	cd $GOPATH/pkg/mod/github.com/mholt/caddy\@v1.0.0/
	git apply $dir/caddy-caddyhttp-httpserver-plugin.patch || echo Patch already applied
	cd $GOPATH/src/popefucker.com/caddy-with-plugins
	GO111MODULE=on go build $GOPATH/src/popefucker.com/caddy-with-plugins/main.go
	mv main /usr/local/bin/caddy_with_plugins
	cd $dir

	mkdir -p /etc/caddy
	mkdir -p /etc/ssl/caddy
	mkdir -p /var/www
	chown --recursive root:www-data /etc/caddy
	chown --recursive root:www-data /etc/ssl/caddy
	chmod 0770 /etc/ssl/caddy
	chown --recursive www-data:www-data /var/www

	touch /etc/caddy/Caddyfile

	cp services/caddy.service /etc/systemd/system/
	sed -i "s/__GANDIV5_API_KEY__/$GANDIV5_API_KEY/g" /etc/systemd/system/caddy.service
	chmod 644 /etc/systemd/system/caddy.service
	systemctl daemon-reload

	ufw allow 80
	ufw allow 443

	touch /var/www/index.html
	echo hello > /var/www/index.html

	systemctl enable caddy

	end_section
fi
echo


if ! diff Caddyfile /etc/caddy/Caddyfile; then
	section Loading new caddy confgiguration

	cp Caddyfile /etc/caddy/Caddyfile
	systemctl restart caddy
	end_section
fi
echo


if ! diff conf/tmux.conf /etc/tmux.conf; then
	section Updating global tmux conf
	cp conf/tmux.conf /etc/tmux.conf
	end_section
fi
echo


if ! diff /etc/xdg/nvim/init.vim conf/init.vim; then
	section Updating global neovim conf
	mkdir -p /etc/xdg/nvim/
	cp conf/init.vim /etc/xdg/nvim/init.vim
	end_section
fi
echo


if ! grep -q friends /etc/group; then
	section Making friends group
	groupadd friends
	end_section
fi
echo

# make each user
for username in `ls users` ; do
	if ! id -u $username ; then
		section Making user $username

		useradd --create-home --shell /usr/bin/fish --groups sudo,friends $username
		passwd --delete $username
		end_section
	fi
	echo

	if ! diff /home/$username/.ssh/authorized_keys users/$username; then
		section "Setting up ssh authorized_keys for $username"
		mkdir -p /home/$username/.ssh
		cp users/$username /home/$username/.ssh/authorized_keys
		chown --recursive $username /home/$username
		end_section
	fi
	echo

	cd /
	if ! sudo -u postgres psql -t -c '\du' | cut -d \| -f 1 | grep -qw $username; then
		section "Making postgres user for $username"
		sudo -u postgres createuser --superuser $username || true
		sudo -u postgres createdb $username || true
		end_section
	fi
	cd $dir
done


add_service counter
add_service api
add_service client


section 🎉 Done!

