<?php
declare(strict_types=1);

http_response_code(200);
header('Content-Type: text/html; charset=UTF-8');
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Drupal PHP Nginx</title>
</head>
<body>
  <h1>Drupal PHP Nginx is running</h1>
  <p>Mount your Drupal application at <code>/var/www/html</code>.</p>
  <p>The container health endpoint is available at <code>/healthz</code>.</p>
</body>
</html>
