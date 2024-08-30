# ERUPT-IoT

## DNS

http://apps.erupt.ch

## Host

Hetzner Server (Nürnberg)
IPv4: 5.75.145.55
IPv6: 2a01:4f8:1c1e:759d::/64

## Deployment

```
git c prod
git merge main
git push
mina deploy
```

## Console

```
mina console
```
or
```
ssh deployer@5.75.145.55
cd /var/www/erupt-iot/current/
bin/rails console
```

## Logs

```
mina log
```
or
```
ssh deployer@5.75.145.55
tail -f /var/www/erupt-iot/current/log/production.log
```

```
sudo tail -f /var/log/nginx/error.log
```


## Set ENVs

```
ssh deployer@5.75.145.55
vim ~/.bashrc
source ~/.bashrc
```

## Full Restart

```
sudo service nginx stop
sudo service nginx start
```

## delayed_jobs

```
cd /var/www/erupt-iot/current/
bin/delayed_job start
bin/delayed_job stop
bin/delayed_job status
```
