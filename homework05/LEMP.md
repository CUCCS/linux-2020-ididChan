- 安装LEMP(**L**inux-**E**ngine/Nginx-**M**ySQL-**P**HP)堆栈

  1. 安装MySQL以管理站点数据

     （1）安装软件包

     ```cmd
     idchannov@id-srv:~$ sudo apt-get install mysql-server
     ```

     （2）完善MySQL相关配置 

     ```cmd
     idchannov@id-srv:~$ sudo mysql_secure_installation
     ```

     【配置选择】使用`auth_socket`身份验证插件(n)、删除匿名用户(y)、禁用远程root登录(y)、删除测试数据库并重新加载配置(y)

     （3）将root的身份验证方法从`auth_socket`切换为`mysql_native_password`

     ```cmd
     # 从终端打开MySQL提示符
     idchannov@id-srv:~$ sudo mysql
     # 检查每个MySQL用户帐户使用的身份验证方法
     mysql> SELECT user,authentication_string,plugin,host FROM mysql.user;
     # 将root帐户配置为使用密码进行身份验证
     mysql> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
     # 重新加载授权表并使新的更改生效
     mysql> FLUSH PRIVILEGES;
     ```

     ![alter](C:/Users/95123/Documents/Academic/Linux/linux-2020-ididChan/homework05/img/alter.PNG)

     （4）试运行数据库系统    `sudo mysql -u root -p`并键入root用户密码

     ![mysql](C:/Users/95123/Documents/Academic/Linux/linux-2020-ididChan/homework05/img/mysql.PNG)

     （5）退出	`mysql> exit;`

  2. 安装PHP并配置Nginx以使用PHP处理器

     （1）安装fastCGI进程管理器(php-fpm)以及一个附加的帮助程序包

     ```cmd
     idchannov@id-srv:~$ sudo apt install php-fpm php-mysql
     ```

     （2）编辑一个新的服务器块配置文件

     ```cmd
     # 编辑配置文件
     idchannov@id-srv:~$ sudo vim /etc/nginx/sites-available/wp.sec.cuc.edu.cn
     # 创建软连接
     idchannov@id-srv:~$ sudo ln -s /etc/nginx/sites-available/wp.sec.cuc.edu.cn /etc/nginx/sites-enabled/
     ```

     配置文件内容：

     ```shell
      server {
             listen localhost:8080;
      		root /var/www/wordpress;
             index index.html index.htm index.nginx-debian.html;
             server_name wp.sec.cuc.edu.cn;
             location / {
                     try_files $uri $uri/ =404;
             }
             location ~ \.php$ {
                     include snippets/fastcgi-php.conf;
                     fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
             }
     }
```
     
（3）从`/sites-enabled/`目录取消链接默认配置文件
     
     ```cmd
     idchannov@id-srv:~$ sudo unlink /etc/nginx/sites-enabled/default
```
     
（4）测试新配置文件的语法错误
     
     ```cmd
     idchannov@id-srv:~$ sudo nginx -t
```
     
（5）重新加载Nginx进行必要的更改
     
     ```cmd
     idchannov@id-srv:~$ sudo systemctl reload nginx
     ```