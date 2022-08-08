## linux系统上自动搭建lamp环境  

``` 
1)克隆该项目
git clone https://github.com/Richard-hk/lamp-auto-config.git
cd lamp-auto-config
2)下载mysql5.7（文件太大暂未上传）
wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
chmod -R 777 lamp_auto_config,sh
./lamp_auto_config.sh #执行shell脚本
```

> 注释：
> lamp环境会自动安装配置完成，  
> 自动运行php文件，输出success则安装配置完成  
> test_apache_success.php文件验证apache是否正确加载php模块  
> test_mysql_con_success.php文件验证php访问mysql是否成功  
