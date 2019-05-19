# SERVER TUESDAY!

## setup

Rent a cloud! With Ubuntu!

I made a digitalocean "droplet"

```
ssh -A {your droplet ip}
git clone git@github.com:amonks/server-tuesday.git
cd server-tuesday
./setup.sh
```

## adding a user

add their public key to the users folder here, then push to github (see "making changes" below)

## connecting as a user

```
ssh {username}@{hostname}
```

then, set up a password

```
passwd
```

## sharing sessions

we can use tmux to share sessions! it's like we're all at the same computer!

one person should `make_shared_tmux {party name}` then other people should `join_shared_tmux {party name}`!

## making changes

goal: if we bork the server, we can set it back up again from scratch really easily

approach: let's maintain a script that sets up the server

when you want to install something globally, instead of installing it manually, add an installation step to the setup script and commit and push to git.

after making your change, push it to github

```
git add .
git commit
# write some message, save, exit
git push
```


## adding a service

let's serve some web!

from your home directory,

```
mkdir web
cd web
echo hello > index.html
serve -p 5000
```

then, in another window, `curl localhost:5000`


tada! your website is serving! but it isn't public…

let's add it to the caddyfile

```
sudo su root
cd /root/server-tuesday
nano Caddyfile
./setup.sh
```

Tada! now you can visit popefucker.com/{whatever path} and see your website! IF and only if the server is running.

Let's make it run at boot.

```
cp services/jon.service services/{you}.service # change the user and name
nano services/{you}.service
nano setup.sh # add an "add_service" at the end
./setup.sh
systemctl status {you}
```



