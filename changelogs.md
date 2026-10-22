**2026 / 10 / 22:**  
updated php to version 8.4.27 (fixes the critical RCE vulnerabilities CVE-2026-109618 and CVE-2026-109619)  
updated nginx to version 1.30.6  
updated igbinary extension to the latest stable version 3.2.16 (PHP 8.4 support)  
re-enabled opcache with --enable-opcache, built as a shared extension and loaded via zend_extension=opcache.so (opcache is only built in by default since PHP 8.5)  
removed php-pear and the `pecl channel-update` step: PEAR is no longer maintained, and PEAR 1.10 cannot parse the chunked HTTP response pecl.php.net now returns, which broke the build  
xdebug is now built from source in extfile/xdebug.sh instead of with `pecl install`  

**2026 / 09 / 10:**  
upgraded base image to rockylinux 10.2 (20260525)  
updated php to version 8.5.10  
updated nginx to version 1.30.4 (stable)  
updated phpredis extension to version 6.3.0  
updated php-memcached extension to version 3.4.0  
updated igbinary extension to version 3.2.17RC1 (first release with PHP 8.5 support)  
updated drush to version 13  
built oniguruma 6.9.10 from source (mbstring mbregex; not packaged in EPEL 10)  
built libzip 1.11.4 from source (ext-zip; libzip-devel not packaged in EL 10)  
removed mcrypt extension (abandoned, incompatible with PHP 8.5 and libmcrypt missing in EPEL 10)  
switched supervisor install from pip to the EPEL package  
switched GD from the system libgd to the libgd bundled with PHP, enabling AVIF support  
dropped obsolete configure flags --enable-opcache (always built in since PHP 8.5) and --with-mhash (deprecated since PHP 8.1)  

**2016 / 12 / 04:**  
updated php to version 7.1.0
updated nginx to version 1.11.6

**2016 / 10 / 14:**  
updated php to version 7.0.12
updated nginx to version 1.11.5

**2016 / 08 / 21:**  
updated php to version 7.0.10  

**2016 / 08 / 03:**     
added diy extension support
added mongodb support
clean the cache files, the mirror less 500M now.

**2016 / 08 / 02:**     
updated nginx to version 1.11.3

**2016 / 07 / 22:**     
updated php to version 7.0.9  

**2016 / 07 / 05:**     
updated nginx to version 1.11.2   

**2016 / 06 / 23:**     
updated php to version 7.0.8   

**2016 / 06 / 02:**     
updated nginx to version 1.11.1   

**2016 / 05 / 26:**     
removed xdebug port   
updated php to version 7.0.7   
updated nginx to version 1.11.0   

**2016 / 05 / 06:**   
fixbug php-fpm repeated start   
updated xdebug port to 9001

**2016 / 04 / 28:**      
updated php to version 7.0.6   

**2016 / 04 / 27:**      
updated nginx to version 1.10.0  
updated xdebug port to 9999

**2016 / 04 / 20:**      
updated nginx to version 1.9.15  

**2016 / 04 / 06:**      
updated nginx to version 1.9.14   

**2016 / 04 / 01:**     
updated php to version 7.0.5   
updated nginx to version 1.9.13   
updated xdebug info   

**2016 / 03 / 04:**     
updated php to version 7.0.4   

**2016 / 02 / 29:**     
updated nginx to version 1.9.12   

**2016 / 02 / 13:**     
updated nginx to version 1.9.11   

**2016 / 02 / 04:**      
updated php to version 7.0.3   

**2016 / 01 / 29:**     
add fileinfo support   
add ipv6 support   

**2016 / 01 / 27:**     
updated nginx to version 1.9.10   

**2016 / 01 / 25:**    
add xdebug support   
