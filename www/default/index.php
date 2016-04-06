<!DOCTYPE html>
<html>
<head>
  <title>Theme Juice Dashboard</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/normalize/3.0.3/normalize.css">
  <style>
    @import url("http://fonts.googleapis.com/css?family=Inconsolata:400,700");
    html {
      box-sizing: border-box;
    }
    *, *:before, *:after {
      box-sizing: inherit;
    }
    body {
      color: #393;
      font: 400 16px/1.875 "Inconsolata", "Consolas", "Courier New", "Courier", monospace;
      background-color: #1C2227;
    }
    a {
      color: #3c3;
      font-weight: 700;
      text-decoration: none;
    }
    .nav {
      display: block;
      width: 100%;
      max-width: 90rem;
      margin: 0 auto;
    }
    .nav__list {
      display: block;
      width: 100%;
      list-style: none;
      margin: 0;
      padding: 0;
    }
    .nav__item {
      float: left;
      width: 100%;
      padding: 1rem;
    }
    .nav__link {
      display: block;
      text-align: center;
      padding: 2rem 0;
      background-color: #262d32;
      border-radius: 0.5rem;
    }
    .icon-stack {
      display: block;
      margin: 0 auto;
      font-size: 2rem;
    }
    .icon-stack--large {
      font-size: 4rem;
    }
    .icon-stack__shape {
      transition: color 350ms;
      color: #262d32;
    }
    .nav__link:hover .icon-stack__shape {
      color: #1C2227;
    }
    .icon-stack__icon {
      color: #E68A00;
    }
    .status {
      display: block;
      text-align: center;
      margin: 2rem 0;
    }
    .status__message {
      display: none;
      font-weight: 700;
      font-size: 1rem;
      margin: 0;
    }
    .status--loading .status__message--loading,
    .status--ok .status__message--ok,
    .status--err .status__message--err {
      display: block;
    }
    .status--loading .status__message,
    .status--loading .icon-stack__icon {
      color: #FFD743;
    }
    .status--ok .status__message,
    .status--ok .icon-stack__icon {
      color: #3c3;
    }
    .status--err .status__message,
    .status--err .icon-stack__icon {
      color: #E84E3E;
    }
    @media (min-width: 30rem) {
      .nav__item {
        width: 50%;
      }
    }
    @media (min-width: 60rem) {
      .nav__item {
        width: 20%;
      }
      .status {
        margin: 15vh 0;
      }
    }
    @media (min-width: 80rem) {
      .nav__link {
        font-size: 1.15rem;
      }
    }
  </style>
</head>
<body>
<aside class="status status--loading">
  <p class="status__message status__message--loading">
    <span class="icon-stack fa-stack">
      <i class="icon-stack__shape fa fa-circle fa-stack-2x"></i>
      <i class="icon-stack__icon fa fa-circle-o-notch fa-spin fa-stack-1x fa-inverse"></i>
    </span>
    Loading...
  </p>
  <p class="status__message status__message--ok">
    <span class="icon-stack fa-stack">
      <i class="icon-stack__shape fa fa-circle fa-stack-2x"></i>
      <i class="icon-stack__icon fa fa-check fa-stack-1x fa-inverse"></i>
    </span>
    OK
  </p>
  <p class="status__message status__message--err">
    <span class="icon-stack fa-stack">
      <i class="icon-stack__shape fa fa-circle fa-stack-2x"></i>
      <i class="icon-stack__icon fa fa-times fa-stack-1x fa-inverse"></i>
    </span>
    Error
  </p>
</aside>
<nav class="nav">
  <ul class="nav__list">
    <li class="nav__item">
      <a class="nav__link" href="https://github.com/ezekg/theme-juice-vvv">
        <span class="icon-stack icon-stack--large fa-stack">
          <i class="icon-stack__shape fa fa-circle fa-stack-2x"></i>
          <i class="icon-stack__icon fa fa-github fa-stack-1x fa-inverse"></i>
        </span>
        Repository
      </a>
    </li>
    <li class="nav__item">
      <a class="nav__link" href="/database-admin">
        <span class="icon-stack icon-stack--large fa-stack">
          <i class="icon-stack__shape fa fa-circle fa-stack-2x"></i>
          <i class="icon-stack__icon fa fa-database fa-stack-1x"></i>
        </span>
        phpMyAdmin
      </a>
    </li>
    <li class="nav__item">
      <a class="nav__link" href="/memcached-admin">
        <span class="icon-stack icon-stack--large fa-stack">
          <i class="icon-stack__shape fa fa-circle fa-stack-2x"></i>
          <i class="icon-stack__icon fa fa-server fa-stack-1x"></i>
        </span>
        phpMemcachedAdmin
      </a>
    </li>
    <li class="nav__item">
      <a class="nav__link" href="/webgrind">
        <span class="icon-stack icon-stack--large fa-stack">
          <i class="icon-stack__shape fa fa-circle fa-stack-2x"></i>
          <i class="icon-stack__icon fa fa-gear fa-stack-1x"></i>
        </span>
        Webgrind
      </a>
    </li>
    <li class="nav__item">
      <a class="nav__link" href="/phpinfo">
        <span class="icon-stack icon-stack--large fa-stack">
          <i class="icon-stack__shape fa fa-circle fa-stack-2x"></i>
          <i class="icon-stack__icon fa fa-info-circle fa-stack-1x"></i>
        </span>
        PHP Info
      </a>
    </li>
  </ul>
</nav>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
<script>
  jQuery(document).ready(function($) {
    $status = $(".status");
    setInterval(function() {
      $.ajax("//vvv.dev").done(function() {
        $status.addClass("status--ok");
      }).fail(function() {
        $status.addClass("status--err");
      }).always(function() {
        $status.removeClass("status--loading");
      });
    }, 2500);
  });
</script>
</body>
</html>
