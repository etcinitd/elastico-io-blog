+++
date = "2017-04-16T18:18:41+04:30"
draft = false
title = "روش های ایجاد ترافیک با Kubernetes"

+++


روش های ایجاد ترافیک با (Ubuntu 16.04 LTS)
===

در این مطلب قصد داریم بررسی کنیم که چطور میتوانیم با استفاده از Kubernetes به دنیای بیرون سرویس ارایه کنیم. اگر با مفاهیم اولیه Kubernetes آشنایی ندارید توصیه میکنم ابتدا به این [مقاله](http://elastico.io/blog/what-is-kubernetes-why-need-it.html) که توسط مهندس مقیمی نوشته شده نگاه بندازید.

اگر قبلا یک کلاستر رو با استفاده از کوبرنیتیس راه اندازی کرده باشید و چند سرویس هم بر روی اون اجرا کرده باشید به زودی متوجه میشوید که روش های سنتی Load Balancing مثلا با استفاده از Nginx برای اتصال به این سرویس ها کافی نیست. مهمترین علت این هست که اجزای موجود در یک کلاستر Kubernetes به صورت پیش فر ض از دنیای بیرون ایزوله هستند و فقط تحت شرایط خاصی میتوانند به دنیای خارج یا همان کاربران واقعی سرویس ها ترافیک برسانند. در ادامه به بررسی روش های موجود برای اینکار برروی کلاود و یا سرور های bare-metal میپردازیم. اما قبل از اینکار یک سری مفاهیم ساده را با هم مرور میکنیم.

POD 
==
در ترمینولوژی کوبرنیتیس به مجموعه چند کانتینر که Life-Cycle یکسانی دارند و در واقع با هم دیپلوی میشوند POD میگویند. پاد کوچکترین جزء در سیستم کوبرنیتیس محسوب شده وکانتینرهای موجود در اون به منابع سیستمی یکسانی دسترسی دارند.

SERVICE 
==
سرویس در واقع یک لایه منطقی برروی پاد هاست. در واقع با استفاده از سرویس ها این امکان وجود دارد که چندین پاد رو انتخاب کرده و ترافیک رو به آنها رساند. مثلا شما میتونید برای ۳ پاد موجود تعریف شده برای backend خودتان یک سرویس ایچاد کنید که کامپوننتهای فرانت میتوانند به آن متصل شوند. از دید این کامپوننت ها فقط یک Endpoint وجود دارد و اون سرویس شماست.

هدف ما در این مقاله نحوه رساندن ترافیک از این Service ها به دنیای خارج است. 

روش اول Node Port
==

در این روش سرویس ها یک پورت را  بر روی یکی از سرور های شما که جزءی از کلاستر است باز کرده و شما میتوانید ترافیک را از طریق این پورت به دنیای بیرون برسانید. این پورت از بازه ی ۳۲۷۶۷-۳۲۰۰۰ هست . که تقریبا در اکثر مواقع چیزی نیست که ما به دنبالش هستیم. چون مثلا ترفیک وب برروی پورت ۸۰ و یا ۴۴۳ هست که این روش برای اینکار مناسب نیست.

```
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
      nodePort: 30061
  clusterIP: 10.0.171.239
  type: NodePort
```

روش دوم Load Balancer
==
در این روش کلاود پرووایدر برای سرویس شما یک IP در نظر میگیرد که با استفاده از این IP میتوانید به سرویس متصل شوید. ایراد این روش این هست که شما فقط میتوانید در صورتیکه کلاود پرووایدر این سرویس را ارایه می کند از این روش استفاده کنید.

```

kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
      nodePort: 30061
  clusterIP: 10.0.171.239
  loadBalancerIP: 78.11.24.19
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
      - ip: 146.148.47.155
```

روش سوم Port Proxy
==

از آنجایی که پاد ها بر خلاف سرویس ها میتوانند به پورت های پایه دسترسی داشته باشن در این روش یک پاد بر روی یک نود ایجاد شده که بر روی پورت مورد نظر ترافیک رو دریافت  و به سرویس ها منتقل میکند. برای اینکار از یک ایمیج خاص استفاده میشود که توانایی انتقال ترافیک رو در لایه ۴ شبکه داشته باشه. نمونه این پاد برروی پورت ۵۳ نود سرویس DNS داخلی کوبرنیتیس را سرویس میدهد.

‍‍
```
apiVersion: v1
kind: Pod
metadata:
  name: dns-proxy
spec:
  containers:
  - name: proxy-udp
    image: gcr.io/google_containers/proxy-to-service:v2
    args: [ "udp", "53", "kube-dns.default", "1" ]
    ports:
    - name: udp
      protocol: UDP
      containerPort: 53
      hostPort: 53
  - name: proxy-tcp
    image: gcr.io/google_containers/proxy-to-service:v2
    args: [ "tcp", "53", "kube-dns.default" ]
    ports:
    - name: tcp
      protocol: TCP
      containerPort: 53
      hostPort: 53

```

روش چهارم External IPs ها
==
در حالتی که یک آی پی خاص میتواند به یک سرورموجود در کلاستر ترافیک رو برساند ما میتوانیم با استفاده از این آی پی به سرویس مورد نظر متصل شویم: 

```
kind: Service,
apiVersion: v1,
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - name: http,
      protocol: TCP,
      port: 80,
      targetPort: 9376
  externalIPs: 
    - 80.11.12.10
```

روش پنجم استفاده از Ingress ها
==

میتوان گفت پیشرفته ترین این روش ها روش استفاده از Ingress هاست. اما ابتدا ببینیم که ingress چیست:


Ingress
==
Ingress ها در واقع یک سری rule هستند که با تعریف آنها میتوانیم ترافیک رو از بیرون به سرویس ها مپ کنیم. در واقع Ingress ها یک لایه منطقی هستند که با استفاده از تعریف اونها نحوه فرستادن ترافیک به سرویس ها مشخص میشه.

اما Ingress ها به تنهایی معنی ندارند. در واقع برای اینکه این قوانین اجرایی شوند ما نیازمند Ingress Controller ها هستیم. Ingress Controller ها انواع مختلفی دارند. مثلا کلاود پروایدر ها Ingress Controller های خودشون رو دارند و با استفاده از اونها میشه ترافیک رو به راحتی بر روی سرویس فرستاد. همچنین ما میتوانیم Ingress Controller ها رو از نوع nginx و به صورت چند پاد بر روی کلاستر ایجاد کنیم. مثلا به صورت نمونه اگر بخواهیم ترافیک را روی تمام نودها ایجاد کنیم میتوانیم از daemon set ها ( پاد هایی که بر روی تمام نود ها اجرا میشوند) استفاده کنیم. مثلا برای ایجاد یک Ingress Controller از نوع nginx:


```
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: nginx-ingress-lb
  labels:
    name: nginx-ingress-lb
  namespace: kube-system
spec:
  template:
    metadata:
      labels:
        name: nginx-ingress-lb
      annotations:
        prometheus.io/port: '10254'
        prometheus.io/scrape: 'true'
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - image: gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.3
        name: nginx-ingress-lb
        readinessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          timeoutSeconds: 1
        ports:
        - containerPort: 80
          hostPort: 80
        - containerPort: 443
          hostPort: 443
        env:
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        args:
        - /nginx-ingress-controller
        - --default-backend-service=$(POD_NAMESPACE)/default-http-backend

```

دقت کنید که برای اینکار حتما باید یک بک اند دیفالت وجود داشته باشد تا در صورتیکه کنترلر سرویسی برای ایجاد ترافیک پیدا نکرد از طریق دیفالت بک اند این کار را انجام دهد.


حال که کنترلر ما ایجاد شد با استفاده از Ingress ها میتوانیم ترافیک را بر روی پورت ها مشترک بین سرویس ها تقسیم کنیم. مثلا:

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        backend:
          serviceName: test
          servicePort: 80

```
باعث میشود که با استفاده از `http://elastico.io/testpath` یتوانیم به سرویس مورد نظر متصل شویم.

یا با استفاده از 

‍‍‍
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - backend:
          serviceName: s1
          servicePort: 80
  - host: bar.foo.com
    http:
      paths:
      - backend:
          serviceName: s2
          servicePort: 80

```

به سرویس های مختلف بر اساس نام هاست متفاوت متصل شویم. مثلا با اتصال به `http://foo.bar.com` میتوانیم به سرویس `s1` متصل شویم.


نوشته شده توسط میعاد ابرین
[LinkedIn](https://www.linkedin.com/in/miad-abrin-73718558)
[Github](https://github.com/miadabrin)
[Stackoverflow](http://stackoverflow.com/users/1923516/miad-abrin)