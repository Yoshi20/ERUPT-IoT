# ERUPT-IoT

## DNS

http://apps.erupt.ch

## Host

Hetzner Server (Nürnberg)
IPv4: 5.75.145.55
IPv6: 2a01:4f8:1c1e:759d::/64

## Deployment

```
mina deploy
```

## Console

```
ssh deployer@5.75.145.55
cd /var/www/erupt-iot/current/
bin/rails console
```

## Set ENVs

```
ssh deployer@5.75.145.55
vim ~/.bashrc
```

## Full Restart

```
sudo service nginx stop
sudo service nginx start
```
