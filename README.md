# SERVER TUESDAY!

## setup

Rent a cloud! With Ubuntu!

I made a digitalocean "droplet"

```
ssh -A {your droplet ip}
git clone git@github.com:amonks/server-tuesday.git
cd server-tuesday
./setup.py
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

