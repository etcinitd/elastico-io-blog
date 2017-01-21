+++
date = "2017-01-16T23:05:01+04:30"
draft = false
title = "نصب داکر بر روی اوبونتو Ubuntu 16.04 LTS"

+++


نصب داکر بر روی اوبونتو (Ubuntu 16.04 LTS)
===

در این مطلب به چگونگی نصب داکر بر روی سیستم عامل اوبونتو می پردازیم. برای انجام دستورات زیر نیاز دارید که دسترسی root داشته باشید.

از آنجا که بسته (package) موجود در مخزن اوبونتو 16.04 برای نصب داکر ممکن است آخرین نسخه نباشد، پیشنهاد می شود آخرین نسخه را از مخزن رسمی داکر دریافت کنید.

برای این کار ابتدا اطلاعات تمام بسته ها را بروز رسانی کنید:

```
sudo apt-get update
```

حال برای نصب داکر، کلید GPG مخصوص مخزن رسمی داکر را به سیستم خود اضافه کنید:

```
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
```
سپس مخزن داکر را به منابع APT اضافه کنید تا بتوانید با کمک دستور `apt-get‍` بسته های این مخزن را نصب کنید:

```
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
```

در قدم بعدی، دوباره اطلاعات بسته ها را که این بار شامل مخزن جدید داکر میشود بروز رسانی کنید:

```
sudo apt-get update
```

قبل از نصب مطمئن شوید که موتور داکر را از مخزن پروژه داکر دانلود می کنید، نه از مخزن پیش فرض اوبونتو. 
برای این کار دستور زیر را وارد کنید:

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
این پیام نشان میدهد که گزینه انتخابی برای نصب، مخزن پروژه داکر است. البته نسخه نشان داده شده برای شما ممکن است متفاوت باشد ولی آدرس مخزن باید حتما در سایت `apt.dockerproject.org` باشد.

در نهایت، موتور داکر را نصب کنید:

```
sudo apt-get install -y docker-engine
```
زمانی که عملیات نصب به پایان رسید، موتور داکر به صورت خودکار اجرا شده و پردازه داکر برای اجرا در هنگام راه اندازی سیستم (boot) فعال شده است. با دستور زیر می توانید وضعیت اجرایی آن را چک کنید:
```
sudo systemctl status docker
```
نتایج باید مشابه زیر باشد که وضعیت سرویس را در حال اجرا و فعال نشان میدهد (Active & running):

```
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2016-05-01 06:53:52 CDT; 1 weeks 3 days ago
     Docs: https://docs.docker.com
 Main PID: 749 (docker)
```

در این مرحله نصب داکر تمام شده است.


### اجرای دستورات داکر بدون نیاز به sudo

 برای اجرای دستورات داکر می بایست آنها را با کمک دستور `sudo` اجرا کنید و در واقع نیاز به سطح دسترسی root دارید. اگر تمایل دارید بتوانید این دستورات را بدون `sudo` اجرا کنید میتوانید نام کاربری خود را به گروه داکر که در حین نصب ساخته شده است، اضافه کنید. 

برای این منظور دستور زیر را پس از جایگزین کردن نام کاربری مورد نظرتان اجرا کنید:

```
sudo usermod -aG docker USERNAME
```

حال میتوانید دستورات داکر را بدون نیاز به `sudo` اجرا کنید، ولی دقت کنید که این کار در عمل به هر کاربری که عضو گروه `docker` شده باشد سطح دسترسی root میدهد.

برای آشنایی بیشتر با این فناوری میتوانید مقاله های [مفاهیم پایه ای داکر](http://elastico.io/blog/docker-basic-concepts.html) و [دستورات پرکاربرد داکر](http://elastico.io/blog/useful-docker-commands.html) را مطالعه کنید.

