dbup
====

dbup is a repurposing of the [bup](https://github.com/bup/bup) tool to
synchronise Docker images over low bandwidth connections.

It works by putting deduplicated images in a 'data pool' which can be easily
synchronised using whatever tool you prefer.

Getting ready to save images:

```
$ IMG=dockerinpractice/dbup
$ docker pull $IMG
latest: Pulling from dockerinpractice/dbup
[...]
Status: Downloaded newer image for dockerinpractice/dbup:latest
$ VOLS='-v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/pool:/pool'
$ alias dbup="docker run --rm $VOLS $IMG"
```

The above alias will save images into 'pool' in the current directory.

```
$ ls pool
ls: cannot access pool: No such file or directory
$ dbup save ubuntu:14.04.1
Saving image!
Done!
$ du -sh pool/
74M     pool/
```

We can sync this to a target directory:

```
$ mkdir -p target/pool
$ rsync -prv pool/ target/pool/
[...]
sent 76,499,147 bytes  received 459 bytes  152,999,212.00 bytes/sec
total size is 76,478,486  speedup is 1.00
```

But what kind of savings might we see?

```
$ dbup save ubuntu:14.04.2
Saving image!
Done!
$ du -sh pool/
86M     pool/
$ rsync -prv pool/ target/pool/
[...]
sent 13,176,021 bytes  received 169 bytes  26,352,380.00 bytes/sec
total size is 89,583,993  speedup is 6.80
```

As you can see, a dbup data pool is very amenable to syncing.

Time to load the image back in:

```
$ docker rmi ubuntu:14.04.2
Untagged: ubuntu:14.04.2
[...]
$ cd target
target $ dbup load ubuntu:14.04.2
Loading image!
Done!
target $ docker images | grep '14\.04\.2'
ubuntu   14.04.2      d0955f21bf24        11 weeks ago        188.3 MB
```
