# ⚠️ Deprecated ⚠️
**Attention!** This virtual machine has been deprecated in favor of our brand new, more stable virtual machine, [Graft](https://github.com/ezekg/graft). It uses Chef as a provisioner, and allows for much, much more customization and stablility than this flimsy Bash-provisioned virtual machine. Please upgrade your [`tj`](https://github.com/ezekg/theme-juice-cli) installation and take advantage of the newest features! See [`tj`'s changelog](https://github.com/ezekg/theme-juice-cli/blob/master/CHANGELOG.md) for additional information.

\- Theme Juice Team

# Graft VM
![image](https://cloud.githubusercontent.com/assets/6979737/13116898/58565d42-d563-11e5-93c5-619f5991564d.png)

## Getting Started

### What is Graft?
Graft is the official virtual machine for [Theme Juice](https://www.themejuice.it),
a powerful way to develop WordPress sites locally on your machine. Theme Juice is
a cross-platform desktop application built on top of our open source command line
utility, [`tj`](https://github.com/themejuice/cli), that enables you to
create, manage and deploy local WordPress development projects at the
click of a button.

### What is Vagrant?
[Vagrant](http://www.vagrantup.com) is a "tool for building and distributing development
environments". It works with [virtualization](http://en.wikipedia.org/wiki/X86_virtualization)
software such as [VirtualBox](https://www.virtualbox.org/) to provide a virtual machine
that is sandboxed away from your local environment. It can be shutdown, destroyed
and recreated at anytime, so feel free to break things!

### Installation
You can either use [`tj`](https://github.com/themejuice/cli) to set up your
development environment, or run the commands below from whatever directory you
want the VM installed:

```bash
# First, cd to where you want to install the VM, then run...
git clone https://github.com/themejuice/graft .
vagrant up
```

## What do you get?
| Name                                                             | Version   | Description                                                                                                                                                                                                            |
| :--------------------------------------------------------------- | :-------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Ubuntu](http://www.ubuntu.com/)                                 | `14.04.3` | Ubuntu is a Debian-based Linux operating system and distribution for personal computers, smartphones and network servers.                                                                                              |
| [Apache](http://httpd.apache.org/)                               | `2.4.x`   | The Apache HTTP Server, colloquially called Apache, is the world's most used web server software.                                                                                                                      |
| [PHP](http://php.net/)                                           | `5.5.x`   | PHP (recursive acronym for PHP: Hypertext Preprocessor) is a widely-used open source general-purpose scripting language that is especially suited for web development and can be embedded into HTML.                   |
| [PHPBrew](https://github.com/phpbrew/phpbrew)                    | `stable`  | PHPBrew allows you to easily switch PHP versions.                                                                                                                                                                      |
| [MySQL](http://www.mysql.com/)                                   | `5.5.x`   | MySQL is an open-source relational database management system.                                                                                                                                                         |
| [WP-CLI](http://wp-cli.org/)                                     | `stable`  | WP-CLI is a set of command-line tools for managing WordPress installations.                                                                                                                                            |
| [Composer](https://getcomposer.org/)                             | `stable`  | Composer is a dependency manager for PHP.                                                                                                                                                                              |
| [NVM](https://github.com/creationix/nvm)                         | `stable`  | NVM allows you to easily switch Node.js versions.                                                                                                                                                                      |
| [Node.js](https://nodejs.org/)                                   | `stable`  | Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient.                                                  |
| [npm](https://www.npmjs.com/)                                    | `stable`  | npm is a dependency manager for Node.js.                                                                                                                                                                               |
| [sympm](https://github.com/ezekg/sympm)                          | `stable`  | sympm allows you to run `npm install` from inside of a Vagrant virtual machine without hitting symlink issues.                                                                                                         |
| [Grunt](http://gruntjs.com/)                                     | `stable`  | Grunt is a task runner for JavaScript.                                                                                                                                                                                 |
| [RVM](https://rvm.io/)                                           | `stable`  | RVM allows you to easily switch Ruby versions.                                                                                                                                                                         |
| [Ruby](https://www.ruby-lang.org/en/)                            | `stable`  | Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.                                                   |
| [Ruby Gems](https://rubygems.org/)                               | `stable`  | RubyGems.org is the Ruby community’s gem hosting service.                                                                                                                                                              |
| [Bundler](http://bundler.io/)                                    | `stable`  | Bundler provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed.                                                                                    |
| [Xdebug](http://xdebug.org/)                                     | `2.2.x`   | Xdebug is a PHP extension which provides debugging and profiling capabilities.                                                                                                                                         |
| [Webgrind](https://github.com/jokkedk/webgrind)                  | `stable`  | Webgrind is an Xdebug profiling web frontend in PHP.                                                                                                                                                                   |
| [Memcached](http://memcached.org/)                               | `1.4.x`   | Memcached (pronunciation: mem-cash-dee) is a general-purpose distributed memory caching system.                                                                                                                        |
| [phpMemcachedAdmin](https://code.google.com/p/phpmemcacheadmin/) | `1.2.x`   | phpMemcachedAdmin is an administration panel for Memcached for monitoring and debugging purposes.                                                                                                                      |
| [phpMyAdmin](http://www.phpmyadmin.net/)                         | `4.0.x`   | phpMyAdmin is a tool written in PHP, intended to handle the administration of MySQL over the Web.                                                                                                                      |
| [ack](http://beyondgrep.com/)                                    | `2.14.x`  | ack is a tool like grep, optimized for programmers.                                                                                                                                                                    |
| [xo](https://github.com/ezekg/xo)                                | `stable`  | xo is a command line utility that composes regex match groups.                                                                                                                     |
| [git](http://git-scm.com/)                                       | `1.8.x`   | Git is a widely used source code management system for software development. It is a distributed revision control system with an emphasis on speed, data integrity, and support for distributed, non-linear workflows. |
| [ngrep](http://ngrep.sourceforge.net/usage.html)                 | `1.45.x`  | ngrep (network grep) is a network packet analyzer.                                                                                                                                                                     |
| [dos2unix](http://dos2unix.sourceforge.net/)                     | `6.0.x`   | dos2unix converts text files with DOS or Mac line endings to Unix line endings and vice versa.                                                                                                                         |                                                                                                                                                                              |

## Dashboard
You can view things such as a PHP `phpinfo()` dump, phpMemcachedAdmin, phpMyAdmin,
Webgrind and more through the [main dashboard](http://graft.dev/).

## Switching PHP versions
Create a new file called `scripts/custom/php.sh` and add the PHP version you
would like to use, making sure it contains all 3 parts (i.e. `x.x.x`). See
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

## Automatically generated self-signed SSL certs
When a `conf` file within `config/apache-config/sites/` contains a virtual host with
a `*:443` port number, a self-signed SSL certificate will automatically be generated
on the next provision. For example, a virtual host that looks like this,

```apache
<VirtualHost *:80>
  DocumentRoot /srv/www/tj-example
  ServerName example.dev
</VirtualHost>

<VirtualHost *:443>
  DocumentRoot /srv/www/tj-example
  ServerName example.dev
  SSLEngine on
  SSLCertificateFile "/etc/ssl/certs/example.dev.pem"
  SSLCertificateKeyFile "/etc/ssl/private/example.dev.key"
</VirtualHost>
```

will automatically get a generated certificate when provisioned. Once a site has a
certificate, another one will not be generated until the old one is removed.

### Accepting a self-signed SSL cert

#### OS X Instructions
Since it's a little unintuitive, I'll link you off [to this great tutorial on
accepting a self-signed cert](https://www.accuweaver.com/2014/09/19/make-chrome-accept-a-self-signed-certificate-on-osx/).

You may need to restart your browser to see this change take effect.

#### Windows Instructions
Know how? Create a pull request!

#### Linux Instructions
Know how? Create a pull request!

## Credentials and Such
| Program | User   | Pass   | Dashboard                                                            |
| :------ | :----- | :----- | :------------------------------------------------------------------- |
| MySQL   | `root` | `root` | [http://graft.dev/database-admin/](http://graft.dev/database-admin/) |

## Need Help?
* Let us have it! Don't hesitate to open a new issue on GitHub if you run into
  trouble or have any tips that we need to know.
