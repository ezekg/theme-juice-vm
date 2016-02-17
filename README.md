# Theme Juice VM

## Getting Started

### What is Vagrant?
[Vagrant](http://www.vagrantup.com) is a "tool for building and distributing development
environments". It works with [virtualization](http://en.wikipedia.org/wiki/X86_virtualization)
software such as [VirtualBox](https://www.virtualbox.org/) to provide a virtual machine
that is sandboxed away from your local environment.

### What do you get?
| Thing                                                            | Version                     |
| :--------------------------------------------------------------- | :-------------------------- |
| [Ubuntu](http://www.ubuntu.com/)                                 | `14.04.3 LTS` (Trusty Tahr) |
| [WP-CLI](http://wp-cli.org/)                                     | `stable`                    |
| [Apache](http://httpd.apache.org/)                               | `2.4.x`                     |
| [PHP](http://php.net/)                                           | `5.5.x`                     |
| [phpbrew](https://github.com/phpbrew/phpbrew)                    | `stable`                    |
| [mysql](http://www.mysql.com/)                                   | `5.5.x`                     |
| [memcached](http://memcached.org/)                               | `1.4.x`                     |
| [xdebug](http://xdebug.org/)                                     | `2.2.x`                     |
| [PHPUnit](http://pear.phpunit.de/)                               | `3.7.x`                     |
| [ack-grep](http://beyondgrep.com/)                               | `2.04.x`                    |
| [git](http://git-scm.com/)                                       | `1.8.x`                     |
| [subversion](http://subversion.apache.org/)                      | `1.7.x`                     |
| [ngrep](http://ngrep.sourceforge.net/usage.html)                 | `1.45.x`                    |
| [dos2unix](http://dos2unix.sourceforge.net/)                     | `6.0.x`                     |
| [Composer](https://github.com/composer/composer)                 | `stable`                    |
| [phpMemcachedAdmin](https://code.google.com/p/phpmemcacheadmin/) | `1.2.x`                     |
| [phpMyAdmin](http://www.phpmyadmin.net/)                         | `4.0.x` (multi-language)    |
| [Webgrind](https://github.com/jokkedk/webgrind)                  | `stable`                    |
| [NodeJs](http://nodejs.org/)                                     | `stable`                    |
| [grunt-cli](https://github.com/gruntjs/grunt-cli)                | `stable`                    |

### Switching PHP versions
Create a new file called `provision/provision-post.sh` and add the PHP version
you would like to use, making sure it contains all 3 parts (i.e. `x.x.x`). See
the following example:

```bash
#!/bin/bash
php-switch 5.6.18 -y # -y skips all prompts
```

After that, provision the VM with `vagrant provision`. Bam! That easy!

Alternatively, you can `vagrant ssh` into the VM and run, for example,
```bash
php-switch 5.6.18
```

Using `php-switch` over SSH doesn't require you to provision the VM, so in the
end it is a lot faster. If you'd like to permanently use a specific PHP version,
you should use the `provision-post.sh` method, as that will persist even if
the VM is destroyed and re-created.

_Currently, this feature is limited to **only** PHP `5.x`. I haven't been able
to find a way to consistently configure other versions with Apache/MySQL. If
you have the chops, I'd love the help._

### Credentials and Such
| Program | User   | Pass   |
| :------ | :----- | :----- |
| MySQL   | `root` | `root` |

### Need Help?
* Let us have it! Don't hesitate to open a new issue on GitHub if you run into
  trouble or have any tips that we need to know.
