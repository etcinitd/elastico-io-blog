+++
date = "2017-06-17T18:18:41+04:30"
draft = false
title = "ساده ترین راه برای دانلود تصاویر رسمی داکر چیست؟"

+++


ساده ترین راه برای دانلود تصاویر رسمی داکر چیست؟
===

اگر با [مفاهیم پایه ای داکر](http://elastico.io/blog/docker-basic-concepts.html) آشنا هستید و قصد دارید برای پروژه بعدی خود از آن استفاده کنید، ممکن است برای دانلود تصاویر رسمی داکر (official docker images) به مشکلاتی برخورده باشید.  

ساده ترین و سریعترین راه در حال حاضر برای انجام این کار استفاده از سرویس الستیکو هاب است. به عنوان مثال برای اجرای یک سرور tomcat میتوانید دستور زیر را اجرا کنید:

```
docker run -ti hub.elastico.io/library/tomcat
```

یا برای اجرای یک پایگاه داده های mysql از طریق کانتینر رسمی آن میتوانید دستور زیر را بکار ببرید:

```
docker run -d --name=test-mysql -e MYSQL_ROOT_PASSWORD=passw123 hub.elastico.io/library/mysql
```
و سپس با استفاده از دستور زیر خروجی آن را بررسی کنید:

```
docker logs test-mysql
```

و در نهایت با کمک دستور زیر به آن متصل شوید:

```
docker run -it --rm --link test-mysql:mysql hub.elastico.io/library/mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
```

سرویس الستیکو هاب به زودی امکان جستجوی این تصاویر را هم فراهم میکند ولی در حال حاضر میتوانید آنها را از طریق جستجو در داکر هاب (hub.docker.com) پیدا کرده و سپس با قرار دادن `hub.elastico.io/library` در ابتدای نام تصاویر آنها را به راحتی دریافت و اجرا کنید.

جهت آشنایی بیشتر با داکر میتوانید مقاله [دستورات پرکاربرد داکر](http://elastico.io/blog/useful-docker-commands.html) را مطالعه کنید یا اگر به صورت جدی تر قصد استفاده از این فنآوری را دارید در راستای مدیریت بهتر کانتینرها با ابزارهای [داکر کامپوز](http://elastico.io/blog/docker-compose-intro-part1.html) و [کوبرنتیس](http://elastico.io/blog/what-is-kubernetes-why-need-it.html) آشنا شوید.
