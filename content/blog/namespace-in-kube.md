+++
date = "2017-11-25T14:55:02+04:30"
draft = false
title = "Namespaces in Kubernetes"

+++

### استفاده از namespace ها برای مدیریت Environment های مختلف در کوبرنتیز

یکی از امکاناتی که کوبرنتیز مهیا کرده امکان مدیریت environment ها می باشد که آسان تر و بهتر از استراتژی های دیپلوی سنتی است. برای اکثر پروژه های سازمانی و بزرگ، environment هایی مانند test، stage و production وجود دارد. این امکان وجود دارد که برای هر کدام، کلاستر جداگانه ای از منابع مثلا بوسیله VMها با تنظیمات مشابه در همه environment ها ایجاد کرد، اما مدیریت آن زمانبر و هزینه آن قابل توجه خواهد بود.
کوبرنتیز دارای امکان مناسبی با نام namespace است که شما را قادر می سازد تا بتوانید environment های مختلفی را در داخل یک کلاستر داشته و مدیریت کنید. 


### namespace پیش فرض

تعیین namespace در کوبرنتیز اختیاری است زیرا کوبرنتیز، بطور پیش فرض از namespace با مقدار default استفاده می کند. بوسیله دستور زیر میتوانید در کلاستر خود، namespace های موجود را مشاهده کنید.

```
kubectl get namespace
```




### ساخت namespace جدید

برای ساخت یک namespace جدید میتواند از همان روشی که سایر منابع را میتوان ساخت استفاده کرد. فایلی با نام my-namespace.yaml ایجاد کرده و مقادیر زیر را در آن کپی کنید:

```
kind: Namespace
apiVersion: v1
metadata:
  name: my-namespace
  labels:
    name: my-namespace
```


فایل را ذخیره کرده و از دستور زیر برای ساخت namespace استفاده کنید:

```
kubectl create -f my-namespace.yaml
```


### نام سرویس ها

با استفاده از namespace ها، برنامه های دیگر میتوانند به یک سرویس با آدرس ثابت اشاره کنند که نیازی به تغییر آن با تغییر environment نیست. بطور مثال سرویس پایگاه داده MySql شما میتواند با نام یکسان mysql در production و staging باشد حتی اگر روی یک زیرساخت قرار داشته باشند. 

این امکان به دلیل آنست که هر یک از منابع در کلاستر بطور پیش فرض تنها منابع دیگری که دارای namespace یکسان با آن منبع هستند را می بینند. این بدان معناست که می توان بدون بروز مشکل در نامگذاری یکسان، pod، service و replication controller هایی را تنها با namespace متفاوت ایجاد کرد.

 درون یک namespace، نام های کوتاه (آدرس های) DNS سرویس ها، به IP سرویس ها در درون یک namespace ترجمه و اشاره خواهند شد. بطور مثال یک سرویس Elasticsearch با نام (آدرس) DNS مانند elasticsearch از طریق سایر کانتینر هایی که دارای namespace مشابه هستند قابل دسترس خواهد بود. البته همچنان امکان دسترسی به سرویس ها در namespace های دیگر با استفاده از نام کامل (آدرس کامل) DNS که دارای فرمت SERVICE-NAME.NAMESPACE-NAME است خواهد بود. بطور مثال elasticsearch.prod و یا elasticsearch.canary در محیط های production  و canary قابل دسترسی خواهند بود.


### مثال

در اینجا مثالی برای درک بهتر موضوع آورده شده است. ما میخواهیم سرویس فروشگاه موزیک با نام MyTunes را در کوبرنتیز دیپلوی کنیم. برای اینکار میتوانیم environment های متفاوت مانند production و staging و تعدادی برنامه های دیگر را در یک کلاستر یکسان اجرا کنیم. با اجرای دستور زیر میتوانید این موضوع را بهتر متوجه شوید:

```
kubectl get namespaces
NAME               LABELS    STATUS
default            <none>    Active
mytunes-prod       <none>    Active
mytunes-staging    <none>    Active
my-other-app       <none>    Active
```


در اینجا می توانید تعدادی namespace  که در حال اجرا هستند را مشاهده کنید. سپس با اجرای دستور زیر لیست سرویس ها در staging را مشاهده خواهید کرد :

```
kubectl get services --namespace=mytunes-staging
NAME     LABELS        SELECTOR      IP(S)            PORT(S)
mytunes  name=mytunes  name=mytunes  10.43.250.14     80/TCP
                                     104.185.824.125  
mysql    name=mysql    name=mysql    10.43.250.63     3306/TCP
```


سپس لیست سرویس های در production را بررسی می کنیم: 

```
kubectl get services --namespace=mytunes-prod
NAME     LABELS        SELECTOR      IP(S)            PORT(S)
mytunes  name=mytunes  name=mytunes  10.43.241.145    80/TCP
                                     104.199.132.213  
mysql    name=mysql    name=mysql    10.43.245.77     3306/TCP
```

توجه شود که آدرس های آی پی به دلیل آنکه در namespace متفاوتی قرار دارند، متفاوت از هم هستند حتی با اینکه دارای نام سرویس یکسان می باشند. این قابلیت، پیکربندی برنامه شما را بطور چشمگیری ساده می کند - ازینرو شما کافیست تا در برنامه خود تنها به نام سرویس خود اشاره کنید - و این پتانسیل را داراست که بتوان نرم افزار را بطور یکسان برای تمامی environment ها پیکربندی کرد.


### سخن آخر

بهرحال اگر production و staing در یک کلاستر اجرا شوند یا نشوند، در هر صورت namespace ها یک روش عالی برای تقسیم برنامه های متفاوت درون یک کلاستر می باشند. همینطور namespace ها به عنوان تراز در جایی که می تواند محدودیت منابع را اعمال کرد استفاده می شوند که می توانید در پست های بعدی ما با آن آشنا شوید…

