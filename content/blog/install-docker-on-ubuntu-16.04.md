+++
date = "2017-01-16T23:05:01+04:30"
draft = false
title = "نصب داکر بر روی اوبونتو "

+++


Install Docker on Ubuntu 16.04
نصب داکر بر روی اوبونتو 16.04
===

در این پست به چگونگی نصب داکر بر روی اوبونتو می پردازیم.
برای انجام دستورات زیر نیاز دارید که دسترسی root داشته باشید.

از آنجا که پکیج موجود در مخزن اوبونتو 16.04 برای نصب داکر ممکن است آخرین نسخه نباشد، پیشنهاد می شود آخرین نسخه را از مخزن رسمی داکر دریافت کنید.

 ابتدا اطلاعات پکیج ها را بروز رسانی کنید:

```
sudo apt-get update
```

حال برای نصب داکر، کلید GPG برای مخزن رسمی داکر را به سیستم اضافه کنید:

```
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
```
سپس مخزن داکر را به سورس APT اضافه کنید :

```
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
```

در قدم بعدی اطلاعات پکیج ها به همراه مخزن جدید داکر (که اضافه شده است) را بروز رسانی کنید:

```
sudo apt-get update
```

مطمئن شوید که داکر را از مخزن داکر دانلود می کنید نه مخزن پیش فرض اوبونتو. 
برای این کار دستور زیر را وارد کنید :

```
apt-cache policy docker-engine
```
و می بایست خروجی زیر را مشاهده کنید:

```
docker-engine:
  Installed: (none)
  Candidate: 1.11.1-0~xenial
  Version table:
     1.11.1-0~xenial 500
        500 https://apt.dockerproject.org/repo ubuntu-xenial/main amd64 Packages
     1.11.0-0~xenial 500
        500 https://apt.dockerproject.org/repo ubuntu-xenial/main amd64 Packages
```
این پیام نشان میدهد که گزینه انتخابی برای نصب، از مخزن داکر می باشد. البته نسخه نشان داده شده می تواند متفاوت باشد.

در نهایت داکر را نصب کنید:

```
sudo apt-get install -y docker-engine
```
حالا داکر نصب شده است و Deamon داکر اجرا شده و پروسس داکر برای اجرا در هنگام راه اندازی (بوت) فعال شده است. با دستور زیر می توانید اجرا بودن آن را چک کنید:
```
sudo systemctl status docker
```
نتایج می بایست مانند زیر باشد و وضعیت سرویس را در حال اجرا و فعال نشان دهد (Active & running):

```
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2016-05-01 06:53:52 CDT; 1 weeks 3 days ago
     Docs: https://docs.docker.com
 Main PID: 749 (docker)
```

حال نصب داکر تمام شده است.


### مرحله بعدی اجرای دستورات داکر بدون نیاز به sudo

 برای اجرا دستورات داکر می بایست دستورات را با sudo اجرا کنید و در واقع نیاز به سطح دسترسی root دارید. اگر تمایل دارید آنها را بدون sudo اجرا کنید میتوانید نام کاربری خود را به گروه داکر که در حین نصب داکر ساخته شده است اضافه کنید. برای این منظور مراحل زیر را جهت آن انجام دهید:

```
sudo usermod -aG docker username
```

حال میتوانید دستور داکر را بدون نیاز به سطح دسترسی root اجرا کنید.
