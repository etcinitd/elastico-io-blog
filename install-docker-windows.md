# طریقه نصب داکر روی ویندوز

کاربران ویندوز میتوانند از Docker Toolbox برای نصب داکر استفاده کنند. Docker Toolbox ابزارهای زیر را در اختیار شما قرار میدهد:

  - ابزار خط فرمان داکر (Docker CLI) برای تعامل با موتور داکر (Docker Engine) جهت ایجاد و تعامل با کانتینرها
  - ابزار ماشین داکر (Docker Machine) برای ایجاد ماشینهای مجازی که امکان اجرای کانتینرها را روی ویندوز دارند
  - ابزار داکر کامپوز (Docker Compose) برای اجرای دستورات docker-compose
  - محیط واسط گرافیکی Kitematic
  - پوسته شروع سریع داکر (Docker QuickStart) برای ایجاد سریع یک خط فرمان آماده برای اجرای دستورات داکر
  - نرم افزار متن باز Oracle VM VirtualBox

به خاطر اینکه موتور داکر (Docker Engine)‌ از ویژگیهای خاص هسته لینوکس استفاده میکند شما نمیتوانید آن را مستقیم روی ویندوز اجرا کنید. به همین دلیل نیاز است که ابتدا با استفاده از دستور ماشین داکر (`docker-machine`) یک ماشین مجازی کوچک لینوکس درست کنید و سپس از طریق آن داکر را اجرا کنید.

## قدم ۱: نسخه ویندوز خود را چک کنید

 برای اینکه بتوانید داکر را اجرا کنید، ماشین شما باید نسخه ۶۴ بیتی ویندوز ۷ یا بالاتر را داشته باشد. همچنین باید مطمئن شوید که امکان virtualization برای سیستم شما فعال شده است.

برای اطمینان از داشتن این پیش نیازها، میتوانید کارهای زیر را انجام دهید:

1.  به Control Panel در قسمت System and Security و بعد System بروید و نسخه ویندوز خود را چک کنید.
1. ابزار مایکروسافت برای تشخیص امکان virtualization را از [اینجا](https://www.microsoft.com/en-au/download/details.aspx?id=592) دانلود و نصب کنید. همچنین در ویندوز ۸ میتوانید این تنظیم را از طریق Start > Task Manager > Performance tab و در قسمت CPU مشاهده کنید.
1. با استفاده از راهنمایی [این مقاله](https://support.microsoft.com/en-us/kb/827218) میتوانید مطمئن شوید که نسخه ویندوز شما ۶۴ بیتی است.

## قدم ۲: جعبه ابزار داکر (Docker Toolbox) را نصب کنید

اگر در حال حاضر نسخه ای از نرم افزار VirtualBox را نصب شده دارید نیازی نیست آن را دوباره نصب کنید، فقط لازم است هنگام نصب جعبه ابزار داکر آن را ببندید.

1. به صفحه [Docker Toolbox](https://www.docker.com/toolbox) بروید و آن را دانلود کنید.
2. برنامه Installer را اجرا کنید. اگر ویندوز از شما خواست که اجازه تغییر سیستم را به این برنامه بدهید، گزینه Yes را انتخاب کنید.
3. برای حالت پیش فرض، در مراحل بعدی گزینه Next را انتخاب کنید و در نهایت گزینه Install.
4. پس از نصب موفقیت آمیز، صفحه ای ظاهر میشود که در آن دکمه Finish وجود دارد و میتوانید آن را بفشارید.

## قدم ۳: نرم افزارهای نصب شده را بررسی کنید
تمامی ابزارهای نصب شده، در پوشه Applications قرار میگیرند. در این مرحله آنها را یک به یک تست میکنیم:

1. روی Desktop و یا در پوشه Applications ابزار Docker Toolbox را پیدا کنید و آن را اجرا کنید.
1. این ابزار برای شما یک خط فرمان آماده برای اجرای دستورات داکر باز میکند. اگر سیستم از شما خواست که به VirtualBox اجازه تغییرات در سیستم را بدهید گزینه Yes را انتخاب کنید. این خط فرمان یک محیط `bash` که خاص لینوکس است را در ویندوز برای شما فراهم میکند چون مورد نیاز داکر است.
1. دستور `docker run hello-world` را تایپ و اجرا کنید.

اجرای کامل این دستور مدتی طول میکشد و اگر همه چیز به خوبی پیش برود خروجی زیر را مشاهده میکنید:

	$ docker run hello-world
	Unable to find image 'hello-world:latest' locally
	Pulling repository hello-world
	91c95931e552: Download complete
	a8219747be10: Download complete
	Status: Downloaded newer image for hello-world:latest
	Hello from Docker.
	This message shows that your installation appears to be working correctly.

	To generate this message, Docker took the following steps:
	 1. The Docker Engine CLI client contacted the Docker Engine daemon.
	 2. The Docker Engine daemon pulled the "hello-world" image from the Docker Hub.
	    (Assuming it was not already locally available.)
	 3. The Docker Engine daemon created a new container from that image which runs the executable that produces the output you are currently reading.
	 4. The Docker Engine daemon streamed that output to the Docker Engine CLI client, which sent it to your terminal.

	To try something more ambitious, you can run an Ubuntu container with:
	 $ docker run -it ubuntu bash

	For more examples and ideas, visit:
	 https://docs.docker.com/userguide/

با دیدن این خروجی میتوانید مطمئن شوید که عمل نصب به درستی انجام شده و جعبه ابزار داکر شما قابل استفاده است.

اگر به هنگام اجرای کانتینرها با مشکلاتی برای دانلود image ها از Docker Hub مواجه شدید، میتوانید با تنظیم یک mirror به صورتی که در [این گروه](https://groups.google.com/forum/#!topic/software-taak/xRmFWrozRoo) گفته شده، دوباره این کار را امتحان کنید.
اگر فکر میکنید برای کار با داکر نیاز به کمک بیشتری دارید و یا علاقه مند هستید که در آینده به یک سرور مجازی برای یادگیری داکر دسترسی داشته باشید میتوانید [این فرم کوتاه](https://docs.google.com/forms/d/1fIYtXM6UaV5pFRBAkNKVNHzBnUg157Sedxds5xYPWDI/viewform?usp=send_form) را پر کنید تا به یک گروه Slack به نام **elastico-users** که برای همین کار ایجاد شده است دعوت شوید. در آنجا میتوانید از اعضای با تجربه تر گروه هم کمک بگیرید.
