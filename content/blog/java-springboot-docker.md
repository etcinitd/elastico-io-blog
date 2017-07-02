+++
date = "2017-07-01T14:54:29+04:30"
draft = false
title = "توسعه و اجرای یک پروژه جاوایی با Spring Boot و داکر (Docker)"

+++

توسعه و اجرای یک پروژه جاوایی با Spring Boot و داکر (Docker)
===

از آنجایی که استفاده از فنآوری داکر هر روز در حال گسترش است و به نظر میرسد به زودی تبدیل به بستر استاندارد اجرای نرم افزارهای سمت سرور خواهد شد، در این مقاله سعی داریم روش اجرای یک برنامه جاوایی مبتنی بر Spirng Boot را همراه با جزییات کافی و به صورت مرحله به مرحله به کمک داکر شرح دهیم. حتی اگر قبلا با داکر کار کرده اید امیدواریم این مقاله ایده های خوبی برای روشهای بهینه استفاده از آن به شما بدهد.

*مطالعه این مقاله نیاز به آشنایی قبلی با داکر ندارد ولی جهت اجرای دستورات آن نیاز دارید حداقل داکر را نصب کرده باشید. برای این کار میتوانید روش نصب داکر روی [ویندوز](http://elastico.io/blog/install-docker-windows.html)، [لینوکس CentOS](http://elastico.io/blog/install-docker-centos7.html) یا [لینوکس Ubuntu](http://elastico.io/blog/install-docker-on-ubuntu-16.04.html) را مطالعه کنید. همچنین برای یادگیری بهتر این مطلب ممکن است آشنایی با [مفاهیم پایه ای داکر](http://elastico.io/blog/docker-basic-concepts.html) به شما کمک کند.*


مطالب این نوشته به بخشهای زیر تقسیم شده است:

- ایجاد یک پروژه جاوایی ساده مبتنی بر Spring Boot
- ساخت یک تصویر (Image) داکر برای این پروژه
- اجرای تصویر (Image) بوسیله موتور داکر


ایجاد پروژه جاوایی مبتنی بر Spring Boot
---
ابتدا یک پوشه به نام ‍`gs-spring-boot-docker` برای این پروژه ایجاد کرده و سپس پوشه های داخلی زیر را درون آن بسازید:

```
src => main => java => hello
```

این کار را در سیستم عاملهای لینوکس یا Mac OS با یک دستور مثل این میتوان انجام داد:

```
mkdir -p src/main/java/hello
```

سپس در پوشه `gs-spring-boot-docker` یک فایل متنی با نام `pom.xml` ایجاد کنید و محتوای آنرا مطابق زیر پر نمایید:
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>org.springframework</groupId>
    <artifactId>gs-spring-boot-docker</artifactId>
    <version>0.1.0</version>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.2.RELEASE</version>
    </parent>
    <properties>
        <java.version>1.8</java.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

سپس یک کلاس با نام Application در فایل `src/main/java/hello/Application.java` ایجاد کرده و محتوای آنرا بصورت زیر قرار دهید:

```
package hello;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class Application {
    @RequestMapping("/")
    public String home() {
        return "Hello Docker World";
    }
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

همانطور که مشاهده میکنید در این کلاس، متدی به نام `home` با استفاده از `RequestMapping` برای دریافت درخواست های سرور روی آدرس `/` یعنی آدرس اصلی سایت قرار داده شده است. در واقع بعد از اجرای این برنامه، آدرس زیر مقدار Hello Docker World را به مرورگر بر میگرداند: http://localhost:8080

حال کافیست این پروژه را با ابزار Maven برای اولین بار بسازید. این کار هم از طریق IDE و هم از خط فرمان امکانپذیر است.

اگر ابزار Maven را روی سیستم خود دارید کافیست در خط فرمان به پوشه‌‌ اصلی پروژه یعنی `gs-spring-boot-docker` بروید و دستور زیر را اجرا کنید:

 ```
mvn package
```

ولی اگر ابزار Maven را تابحال روی سیستم خود نصب نکرده اید، داکر میتواند به راحتی و با یک دستور برای شما آن را دانلود و اجرا کند:

```
docker run --rm -ti \
  --net host \
  --volume "${HOME}"/.m2:/root/.m2 \
  --volume "${PWD}":/usr/src/mymaven \
  --workdir /usr/src/mymaven \
  hub.elastico.io/library/maven:3-jdk-8 \
  mvn package
```

اگر به تازگی با داکر آشنا شده اید ممکن است این دستور به نظر شما کمی پیچیده برسد ولی مطالعه مقاله [دستورات پرکاربرد داکر](http://elastico.io/blog/useful-docker-commands.html) به شما در فهم آن کمک میکند.

پس از اجرای موفق این دستور تمام کتابخانه های مورد نیاز چارچوب Spring Boot دانلود و فایل نهایی این پروژه نیز ساخته شده است.

اگر جاوا روی سیستم شما نصب شده است برای اجرای برنامه  دستور زیر را وارد کنید:

```
java -jar target/gs-spring-boot-docker-0.1.0.jar
```

ولی اگر جاوا را تابحال نصب نکرده اید میتوانید مجدد از داکر برای این کار براحتی کمک بگیرید:

```
docker run --rm -ti \
  --publish 8080:8080 \
  --volume "${PWD}":/usr/src/myapp \
  --workdir /usr/src/myapp \
  hub.elastico.io/library/openjdk:8-jdk \
  java -jar target/gs-spring-boot-docker-0.1.0.jar
```

با این کار برنامه اجرا شده و در مسیر http://localhost:8080 میتوانید خروجی آنرا مشاهده کنید.


در مرحله بعدی از فایل ساخته شده در این مرحله که `target/gs-spring-boot-docker-0.1.0.jar` نام دارد برای ایجاد یک تصویر داکر استفاده خواهیم کرد تا امکان انتشار این برنامه فراهم شده و اجرای آن توسط کاربران آسانتر شود.

ساخت یک تصویر (Image) داکر برای این پروژه
---
در پوشه اصلی پروژه فایلی با نام `Dockerfile` بسازید و محتوای انرا بصورت زیر پر کنید:
```
FROM hub.elastico.io/library/openjdk:8

VOLUME /tmp

COPY target/gs-spring-boot-docker-0.1.0.jar /app.jar
RUN sh -c 'touch /app.jar'

EXPOSE 8080

ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]
```
در دستورات بالا از یک تصویر داکر که در کتابخانه هاب الستیکو موجود است به عنوان تصویر پایه استفاده کرده ایم که این کار نیاز به نصب jdk را کاملا برطرف میکند. سپس یک volume با نام tmp ایجاد کرده ایم که به عنوان پوشه کاری (working directory) برای سرور tomcat واقع در spring boot در نظر گرفته میشود.

در خط سوم jar فایل ساخته شده را با نام `app.jar` به داخل کانتینر کپی میکنیم. در قسمت بعدی بوسیله اجرای دستور touch به فایل خود زمان تغییرات اضافه میکنیم زیرا نداشتن زمان آخرین تغییر (modification time) در برخی موارد باعث جلوگیری از اجرای فایل ها توسط tomcat میشود. سپس بوسیله دستور Expose، پورت 8080 را برای ارتباط با بیرون کانتینر در نظر میگیریم.
در انتها نیز فرمان اجرایی کانتینر را مشخص میکنیم.

برای آشنایی بیشتر با این ساختار میتوانید مقاله [روش نوشتن یک Dockerfile](http://elastico.io/blog/how-to-write-dockerfile.html) را مطالعه کنید.  

حال با اجرای دستور زیر از این فایل برای ایجاد تصویر داکر استفاده میکنیم:

```
docker build -f Dockerfile -t spring-boot-docker .
```

دستور `docker build`  برای ساخت یک تصویر از روی Dockerfile استفاده میشود. در دستور فوق پارامتر `t` برای تعیین tag که در واقع نام تصویر ساخته شده است بکار گرفته میشود. دقت کنید که نقطه در انتهای خط برای آدرس دهی در مسیر جاری جهت یافتن داکرفایل است.

بعد از اجرای موفق دستور بالا میتوانید تصویر ساخته شده را در لیست خروجی فرمان زیر به عنوان یک تصویر داکر که آماده اجراست مشاهده کنید:

```
docker images
```

اجرای تصویر (Image) بوسیله موتور داکر
---
سپس با دستور زیر میتوانید کانتینر خود را بر روی پورت 8080 اجرا کنید:

```
docker run -ti -p 8080:8080 spring-boot-docker
```

و از طریق آدرس http://localhost:8080 صفحه وب این کانتینر اجرایی خود را مشاهده کنید.

به دلیل استفاد از پارامترهای `ti` این کانتینر در پیش زمینه (foreground) اجرا میشود که باعث میشود با فشردن دکمه های Ctrl+C بتوانید اجرای آنرا متوقف کنید.


اگر قصد دارید این کانتینر در پس زمینه (background) به اجرای خود ادامه دهد میتوانید به جای آن از پارامتر `d` استفاده کنید:

```
docker run -d -p 8080:8080 --name my-app spring-boot-docker
```

در این حالت برای دیدن لاگهای برنامه میتوانید از دستور زیر کمک بگیرید:

```
docker logs my-app
```

و در نهایت با اجرای دستورات زیر این کانتینر را متوقف و سپس حذف کنید:

```
docker stop my-app
docker rm my-app
```

حال اگر به صورت جدی تر قصد استفاده از فنآوری داکر را دارید میتوانید با ابزارهای [داکر کامپوز](http://elastico.io/blog/docker-compose-intro-part1.html) و [کوبرنتیس](http://elastico.io/blog/what-is-kubernetes-why-need-it.html) آشنا شده و به [گروه داکر در تلگرام](https://telegram.me/joinchat/DBSHvj6Jmd0FYWfhyvrnvw) ملحق شوید.
