+++
date = "2016-07-23T14:55:02+04:30"
draft = false
title = "توسعه و دیپلوی یک برنامه Nodejs در کیوب"

+++


مقدمه
---

در این پست هدف ما توضیح چگونگی ساخت یک برنامه کوچک بصورت کانتینری و اجرای آن بصورت چند instance بر روی kubernetes می باشد.

مراحل کار به ترتیب زیر است:

1. نوشتن یک برنامه ساده به زبان NodeJS

2. نوشتن داکر فایل برنامه

3. ساخت image و push آن به رجیستری

4. تعریف deployment برای kube و اجرای آن

5. تعریف service برای kube و اجرای آن

6. تعریف ingress برای kube و اجرای آن

7. تست اجرای برنامه




### نوشتن یک برنامه ساده به زبان NodeJS ###

در این قسمت ما یک برنامه ساده وب برای nodejs که صرفا عبارت Hello NodeJs را نمایش می دهد می نویسیم. این برنامه بر روی پورت 8080 بصورت مستقیم بعد از آدرس دامین اجرا خواهد شد. یک فایل متنی خالی با نام hellonode.js ایجاد کرده و محتوای کد زیر را داخل آن قرار دهید و فایل را ذخیره نمایید. 


    //requiring the HTTP interfaces in node 
    var http = require('http'); 

    // create an http server to handle requests and response 
    http.createServer(function (req, res){ 

    // sending a response header of 200 OK 
    res.writeHead(200, {'Content-Type': 'text/plain'});   

    // print out Hello NodeJs
    res.end('Hello NodeJs');  

    // use port 8080  
    }).listen(8080);  

    console.log('Server running on port 8080.'); 
        

بعد از نوشتن برنامه بالا آنرا بصورت local اجرا کرده تا از اجرای درست آن اطمینان حاصل کنید. برای اجرا نیاز خواهید داشت تا nodejs برروی سیستم شما نصب باشد. می توانید آنرا از https://nodejs.org دانلود و نصب نمایید. برای اجرای برنامه بالا کافیست در یک صفحه وب، آدرس localhost:8080 را وارد نمایید.


### نوشتن داکر فایل برنامه ###
یک فایل متنی خالی با نام Dockerfile ایجاد کرده و محتوای زیر را داخل آن کپی و آنرا ذخیره نمایید. این فایل برای ساخت image برنامه بالا استفاده شده است. 

    FROM node:slim

    COPY hellonode.js app.js

    EXPOSE 8080

    CMD node app.js

در خط ابتدایی در واقع image پایه جهت ساخت این image مشخص شده است که ما از node که تصویر رسمی خود nodejs است استفاده کرده ایم. در خط بعدی فایل برنامه را بوسیله دستور copy از مسیر جاری در داخل تصویر خود با نام جدید app.js کپی میکنیم. در ادامه شماره پورتی که کانتینر روی آن برنامه را سرویس خواهد داد مشخص کرده و در انتها با دستور CMD دستور اجرا شدن برنامه را تعیین کرده ایم.


### ساخت image و push آن به رجیستری ###
بعد از نوشتن فایل نوبت به build آن به عنوان image و push کردن آن به image registry مد نظرمان می رسد.
ما از رجیستری خود داکر (Docker Hub) برای ارسال image های خودمان استفاده می کنیم. 
 برای build داکر فایل، کنسول فرمان را اجرا کرده و به مسیری که داکر فایل تان در آنجا قرار دارد بروید. سپس با استفاده از دستور زیر داکر فایل را build کرده و به آن تگ مربوط را اضافه کنید.

        docker build -t your_docker_hub_account/nodejs_hello:v1.3  .


در خط فوق، با پارامتر -t مقدار تگ های مد نظرمان را مشخص می کنیم. باید توجه داشت که در قسمت your_docker_hub_account نام کاربری حساب  خود در داکر هاب را قرار دهید. و بعد از آن نام image خود به همراه ورژن را قید کرده و سپس با قرار دادن نقطه اشاره میکنید که داکر فایل در مسیر جاری با نام dockerfile قرار دارد.

بعد از اجرای دستور فوق بوسیله دستور docker images میتوانید image ساخته شده خود را مشاهده کرده و سپس با استفاده از دستور زیر image را در registry پوش نمایید. 


        docker push your_docker_hub_account/nodejs_hello:v1.3


### تعریف deployment برای kube و اجرای آن ###

حال برای دیپلوی کردن برنامه در kubernetes لازم است به CLI کلاستر دسترسی داشته باشید. ازینرو login کرده و در مسیر مورد نظرتان یک فایل خالی با نام deployment.yaml ایجاد نمایید. 

برای deploy کردن برنامه ما ابتدا نیاز به نوشتن deployment مورد نیاز برنامه، جهت تعیین مشخصات برنامه در کلاستر kubernetes داریم. در واقع با تعریف deployment میتوانیم مشخص نماییم چند instance از برنامه به همراه چه کانتینر هایی و با چه ارتباطی با هم اجرا شوند.

ازینرو دستورات زیر را داخل آن کپی نمایید. باید توجه داشت که محتوای فایل بر اساس فرمت YAML نوشته می شود و تو رفتگی ها در فایل حتما بدون Tab ایجاد شود.


    # deployment.yml
    apiVersion: apps/v1beta1
    kind: Deployment
    metadata:
      name: hello-nodejs-deployment
    spec:
      replicas: 2
      template:
        metadata:
          labels:
            app: hellonodejs
        spec:
          containers:
          - name: nodejs
            image: my_docker_hub_account/nodejs_hello:v1
            ports:
            - containerPort: 8080

در فایل بالا ابتدا ورژن API استفاده شده را مشخص می کنیم. برای ورژن کیوب های 1.7 به پایین از v1beta استفاده میکنیم. در قسمت kind نوع فایل نوشته شده را مشخص می کنیم که در این مرحله از نوع deployment می باشد. در قسمت meta-data میتوانیم اطلاعاتی در مورد deployment مد نظر برای اجرا را مشخص نمایید. مواردی از قبیل name، lable و namespace و غیره. در قسمت spec اطلاعات و مشخصات اصلی برای deployment تعریف می شود. مثلا می توانیم مشخصات مورد نظر برای Pod ها و Replication Controller  را مشخص می نماییم.

در خط بعدی با کلید replicas، تعداد Pod های مورد نظر برنامه برای اجرا را مشخص می نماییم. ( هر Pod یک instance از اجرای Application در نظر گرفته شود). 

مقدار template یک مقدار ضروری برای قسمت spec می باشد که برای توصیف Pod ها در کیوب استفاده می شود. مقدار metadata برای افزودن lable (که بعدا در service ها اشاره خواهد شد) به این deployment اضافه شده است. 

مقدار بعدی یعنی spec.template.spec برای اعلام مشخصات دقیق Pod ها مورد استفاده قرار گرفته که در اینجا مشخصات کانتینر که شامل نام، آدرس Image و شماره پورتی که Pod روی آن سرویس ارائه می دهد مشخص شده است. 


### تعریف service برای kube و اجرای آن ###
یک فایل با نام service.yaml ساخته و محتوای زیر را درون آن کپی و ذخیره نمایید.

    # service.yml
    apiVersion: v1
    kind: Service
    metadata:
      name: hellonodejs-service
    spec:
      selector:
        app: hellonodejs
      ports:
        - name: http
          protocol: TCP
          port: 8080
          targetPort: 8080

به دلیل آنکه Pod ها مانا نیستند ازینرو در کیوب، بوسیله تعریف لایه ای انتزاعی بر روی آنها که Service نام دارد، میتوان آنها را برای دسترسی ممکن ساخت. این امکان با تعریف سیاست دسترسی مشخصی کامل تر می شود. در فایل مذکور ما یک service را با نام hellonodejs-service تعریف می کنیم. این سرویس به همه Pod هایی که دارای lable با شناسه app و مقدار  hellonodejs می باشند اعمال می شود و آنها را در بر میگیرد. در قسمت ports مشخصات دسترسی service تعیین می گردد. همانطور که مشاهده می شود این سرویس بر روی پروتکل TCP و شماره پورت 8080 سرویس خود را ارائه می کند. قایب ذکر است که این service از شماره پورت 8080 Pod ها برای فرخوانی استفاده می کند.




### تعریف ingress برای kube و اجرای آن ###

یک فایل متنی با نام ingress.yaml ساختهت و محتوای زیر را درون آن قرار دهید و فایل را ذخیره نمایید. بوسیله تعریف ingress میتوان قسمت مد نظر از کلاستر را که به بیرون از کلاستر ارائه می شود را مشخص کرد. در واقع در این قسمت ما با تعریف ingress تعیین می کنیم که در کدام آدرس ما میتوان ترافیک مورد نظر را برای مسیر دهی به service تعریف شده برنامه خود جهت دهیم.

    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: hello-nodejs-ingress
    spec:
      rules:
      - host: [your domain in cluster]
        http:
          paths:
          - path: /hellonodejs
            backend:
              serviceName: hellonodejs-service
              servicePort: 8080

در فایل فوق ابتدا نام ingress resource با مقدار hello-nodejs-ingress مشخص شده است. سپس در قسمت host آدرس کلاستر که از بیرون میتوان به برنامه ما هدایت شود را مشخص می کنیم. یعنی در قسمت [your domain in cluster] آدرس ارائه شده به خود برای کلاستر را قرار دهید. سپس در قسمت paths آدرس مد نظر و در قسمت backend نام service تعریف کرده در قسمت قبلی و شماره پورت سرویس دهی آنرا مشخص می کنیم. 

حال می توانید با استفاده از دستورات زیر اقدام به ساخت resource ها در کلاستر نمایید :

    kubectl create  -f deployment.yaml 
    kubectl create  -f service.yaml 
    kubectl create  -f ingress.yaml 

حال با فراخوانی آدرس your domain in cluster/hellonodejs قادر خواهید بود محتوای Hello NodeJs را مشاهده نمایید.

 
 


