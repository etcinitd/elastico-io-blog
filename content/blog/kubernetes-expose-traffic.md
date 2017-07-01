+++
date = "2017-04-16T18:18:41+04:30"
draft = false
title = "چطور به یک برنامه که تحت Kubernetes اجرا شده است وصل شویم؟"

+++


چطور به یک برنامه که تحت Kubernetes اجرا شده است وصل شویم؟
===

در این مطلب قصد داریم بررسی کنیم که چطور میتوانیم با استفاده از Kubernetes به دنیای بیرون سرویس ارایه کنیم. اگر با مفاهیم اولیه Kubernetes آشنایی ندارید توصیه میکنیم ابتدا به [مقاله کوبرنتیس چیست](http://elastico.io/blog/what-is-kubernetes-why-need-it.html) نگاهی بیندازید.

اگر با یکی از روشهای گفته شده در [این مقاله](https://kubernetes.io/docs/setup/pick-right-solution/) یک کلاستر کوبرنتیس راه اندازی کنید و چند سرویس هم بر روی آن اجرا کنید به زودی متوجه میشوید که روش های معمول ارایه سرویسهای وبی و توزیع بار (Load Balancing) مثلا با استفاده از Nginx برای اتصال به این سرویسها مشابه معمول کار نمیکند. علت این است که اجزای موجود در یک کلاستر Kubernetes به صورت پیش فرض از دنیای بیرون جدا هستند و فقط تحت شرایط خاصی میتوانند به درخواستهای دنیای خارج یا همان کاربران نهایی پاسخ بدهند.

در ادامه به بررسی روش های موجود برای این کار بر روی سرورهای مجازی ابری و همچنین سرورهای سخت افزاری (bare-metal) میپردازیم. اما قبل از این کار یک سری مفاهیم ساده و اولیه را با هم مرور میکنیم.

پاد (Pod)
==
در مجموعه واژگان کوبرنتیس به چند کانتینر که چرخه حیات (Life Cycle) یکسانی دارند و در واقع با هم  و روی یک ماشین در کلاستر اجرا میشوند پاد (Pod) میگویند. پاد کوچکترین جزء در سیستم کوبرنتیس محسوب میشود که کانتینرهای موجود در آن به منابع سیستمی یکسانی دسترسی دارند. در اکثر مواقع پاد تنها از یک کانتینر تشکیل میشود.

سرویس (Service)
==
سرویس در واقع یک لایه منطقی بر روی مجموعه ای از پادهاست. با استفاده از سرویس این امکان داده میشود که چندین پاد را انتخاب کرده و ترافیک ورودی را به یکی از آنها برسانیم. این پادها میتوانند نسخه های یکسانی از یک برنامه (جهت افزایش قابلیت اطمینان) و یا نسخه های متفاوتی از آن (جهت تست A/B) باشند. مثلا شما میتوانید برای تمام پادهای اجرا شده برای یک API خودتان یک سرویس ایجاد کنید که برنامه های دیگر به آن متصل شوند. از دید این برنامه ها فقط یک Endpoint برای این واسط کاربردی وجود دارد و آن سرویس شماست.

سرویسها به طور پیش فرض فقط از داخل کلاستر قابل دسترسی هستند. هدف ما در این مقاله بیان شیوه های رساندن ترافیک به این سرویسها از دنیای خارج است.

روش اول Node Port
==

در این روش یک پورت شبکه (port) بر روی سرورهای شما که جزئی از کلاستر هستند باز شده و شما میتوانید ترافیک را از طریق این پورت به سرویس برسانید. این پورت به صورت پیش فرض از بازه ۳۲۷۶۷-۳۰۰۰۰ انتخاب میشود که تقریبا در اکثر مواقع چیزی نیست که ما به دنبالش هستیم. چون مثلا ترافیک وب باید بر روی پورت ۸۰ یا ۴۴۳ باشد که این روش برای آن مناسب نیست.

متن زیر نمونه ای از تعریف یک سرویس است که به همین روش پورت ۳۰۰۶۱ را به عنوان `nodePort` انتخاب کرده است:

```
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  type: NodePort
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
      nodePort: 30061
  clusterIP: 10.0.171.239
```

روش دوم Load Balancer
==
در این روش کوبرنتیس از طریق اتصال به فراهم کننده بستر ابری برای سرویس شما یک IP در نظر میگیرد که با استفاده از این IP میتوانید از خارج کلاستر به سرویس خود متصل شوید. ایراد این روش این است که شما فقط میتوانید در صورتی از آن استفاده کنید که ارایه دهنده خدمات ابری شما این سرویس را ارایه کند.

متن زیر نمونه ای از تعریف یک سرویس است که به این روش آدرس `78.11.24.19` را به عنوان `loadBalancerIP` پیشنهاد داده است ولی در نهایت بستر ابری آدرس `146.148.47.155` را در قسمت `status.loadBalancer` برای این سرویس انتخاب کرده است:

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

از آنجایی که پادها بر خلاف سرویسها میتوانند به پورت های پایه دسترسی داشته باشند در این روش یک پاد بر روی یک نود (Node) ایجاد میشود که بر روی پورت مورد نظر ترافیک را دریافت و به سرویس مقصد منتقل میکند. برای اینکار از یک تصویر (Image) آماده داکر استفاده میشود که توانایی انتقال ترافیک را در لایه ۴ شبکه (لایه TCP و UDP)‌ داشته باشد.

نمونه این پاد در زیر بر روی پورت ۵۳ سرویس DNS داخلی کوبرنتیس را ارایه میدهد:

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

روش چهارم External IP ها
==
در حالتی که یک آدرس IP خاص از قبل وجود داشته باشد که بتواند به یک سرویس موجود در کلاستر ترافیک را برساند ما میتوانیم با استفاده از آن به سرویس مورد نظر متصل شویم:

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

میتوان گفت پیشرفته ترین روش استفاده از Ingress است. اما ابتدا ببینیم Ingress چیست:


Ingress
==
Ingress ها یک سری قوانین (rule) هستند که با تعریف آنها میتوانیم ترافیک را از بیرون به سرویس ها نگاشت (map) کنیم. در واقع این قوانین یک لایه منطقی تشکیل میدهند که با استفاده از آن نحوه فرستادن ترافیک خارجی به سرویس ها مشخص میشود.

اما Ingress ها به تنهایی کار نمیکنند. در واقع برای اینکه این قوانین اجرایی شوند نیازمند Ingress Controller ها هستیم. Ingress Controller ها انواع مختلفی دارند. مثلا اکثر بسترهای ابری Ingress Controller های خاص خودشان را دارند که با استفاده از آنها میشود ترافیک را به راحتی بر روی سرویس فرستاد. همچنین ما میتوانیم Ingress Controller هایی را با استفاده از nginx و به صورت چند پاد بر روی خود کلاستر اجرا کنیم.

مثلا به طریق زیر میتوانیم با کمک daemon set ها (یعنی پاد هایی که بر روی تمام نود ها اجرا میشوند) یک Ingress Controller از نوع nginx بر روی هر نود کلاستر اجرا کنیم:


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

دقت کنید که برای اینکار حتما باید یک پاسخ دهنده پیش فرض (default backend) وجود داشته باشد تا در صورتیکه کنترلر سرویسی برای پاسخ دادن به ترافیک وروردی پیدا نکرد از آن استفاده کند. البته نیازی نیست که حتما برای اجرای Ingress Controller ها از Daemon Set استفاده شود و میتوان از بقیه مکانیزمها مثل Deployment یا Replication Controller نیز استفاده کرد.

حال که کنترلر ما اجرا شده است با تعریف Ingress ها میتوانیم ترافیک را بر روی پورت های مشترک بین سرویس ها تقسیم کنیم. مثلا:

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
باعث میشود که با استفاده از مسیر `/testpath` بتوانیم به سرویس مورد نظر خود وصل شویم.

یا با تعریف:
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

میتوان به سرویسهای مختلف بر اساس نام هاست (host) وصل شد. مثلا در نمونه بالا با اتصال به آدرس `http://foo.bar.com` میتوان به سرویس `s1` درخواست فرستاد.


برای آشنایی بیشتر با این فنآوری میتوانید [ارایه ضبط شده کوبرنتیس](http://taakestan.com/index.php/2012-09-09-10-30-14/55-2016-08-30-kubernetes-docker-conf-tehran) در همایش داکر تهران  را بر روی سایت تاک مشاهده کنید.

نویسنده: میعاد ابرین
[LinkedIn](https://www.linkedin.com/in/miad-abrin-73718558) -
[Github](https://github.com/miadabrin) -
[Stackoverflow](http://stackoverflow.com/users/1923516/miad-abrin)

ویرایش: امیر مقیمی
