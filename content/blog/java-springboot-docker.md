+++
date = "2017-07-01T14:54:29+04:30"
draft = false
title = "تجربه پروژه جاوا SpringBoot با Docker"
description = "Nitro is a simple profiler for your Golang applications"

+++

تجربه پروژه جاوا SpringBoot با Docker
===

## مقدمه
در این نوشته سعی بر ارائه دید کلی بر نحوه استفاده از تلفیق تکنولوژی Spring Boot و Docker برای ایجاد یک برنامه مبتنی بر  جاوا می باشد.
مطالب این نوشته به بخش زیر تقسیم می شود:
ایجاد پروژه جاوا مبتنی بر Spring Boot
ساخت فایل اجرایی تحت جاوا برای پروژه
ساخت Image داکر پروژه
اجرای Image بوسیله داکر
#
ایجاد پروژه جاوا مبتنی بر Spring Boot
---
ابتدا یک پوشه برای پروژه ایجاد کرده و فولدر های زیر را درون آن بسازید
```
--> src --> main --> java --> hello
```

سپس در پوشه برنامه (بیرون پوشه src) یک فایل متنی با نام و پسوند pom.xml ایجاد کنید ومحتوای آنرا طبق زیر پر نمایید:
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


سپس پروژه را با Maven، Build کنید. این کار از طریق IDE یا خط فرمان صورت می پذیرد.
برای اجرا به مسیر فایل pom.xml رفته و دستور Build در خط فرمان را بصورت زیر وارد کنید:
 ```
mvn package
```

حالا کتابخانه های مورد نیاز دانلود شده و کافیست فایل برنامه را ایجاد کنید.
یک کلاس با نام MyApplication ایجاد کرده و محتوای آنرا بصورت زیر قرار دهید:
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


در این فایل، متد home با     @RequestMapping("/")برای دریافت درخواست های سرور از ابتدای آدرس / قرار داده شده است. دروقع بعد از اجرای سرور، آدرس زیر متد home را فراخوانی کرده و مقدار Hello Docker World را بر میگرداند: 
http://localhost:8080/


ساخت فایل اجرایی تحت جاوا برای پروژه
---
پروژه را Build و اجرا کنید. برای اینکار کافیست دستورات زیر را اجرا کنید :
```
mvn package 
java -jar target/gs-spring-boot-docker-0.1.0.jar
```

با این کار پروژه اجرا شده و در مسیر اعلام شده میتوانید خروجی را مشاهده کنید.
همینطور فایل اجرایی برنامه در پوشه target gs-spring-boot-docker-0.1.0.jar با نام قرار گرفته شده است.
ازین فایل برای ایجاد Image داکر استفاده خواهیم کرد.

ساخت Image داکر پروژه
---
در مسیر جاری پروژه فایلی با نام Dockerfile بسازید و محتوای انرا بصورت زیر قرار رهید:
```
FROM java:latest 
VOLUME /tmp
ADD gs-spring-boot-docker-0.1.0.jar app.jar
RUN sh -c 'touch /app.jar'
EXPOSE 8080

ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]
```
بوسیله دستورات بالا از یک image جاوا که در داکر هاب موجود است به عنوان ایمیج پایه استفاده می کنیم . سپس یک volume با نام tmp ایجاد کرده که به عنوان working directory برای tomcat واقع در spring boot در نظر گرفته می شود.
در خط سوم jar فایل ساخته شده را به داخل کانتینر با نام app.jar کپی می کنیم. در قسمت بعدی بوسیله اجرای دستور touch به فایل خود زمان تغییرات اضافه میکنیم. (نداشتن modification time در برخی موارد باعث جلوگیری از اجرای فایل های استاتیک می شود.) سپس بوسیله دستور Expose، پورت 8080 را برای ارتباط با بیرون کانتینر در نظر میگیریم.
در سطر آخر برنامه app.jar را با دستور java اجرا می کنیم.
سپس بایستی از این فایل برای ایجاد image استفاده کنیم.
```
docker build -f Dockerfile -t spring-boot-docker .
```

دستور docker build  برای ساخت image از روی dockerfile استفاده می شود. در دستور فوق پارامتر -t برای تعیین tag و -برای مشخص کردن نام داکر فایل می باشد. توجه شود که نقطه انتهای خط برای آدرس دهی در مسیر جاری جهت یافتن داکر فایل می باشد.
بعد از اجرای دستور فوق میتوانید image ساخته شده را در لیست خروجی دستور زیر مشاهده کنید:
```
docker images
```
اجرا کانتینر
---
سپس با دستور زیر میتوانید کانتینر خود را بر روی پورت 8080 اجرا کنید:
```
docker run -p 8080:8080 spring-boot-docker
```

در نهایت از طریق آدرس http://localhost:8080/ میتوانید صفحه وب کانتینر اجرایی خود را مشاهده کنید.
