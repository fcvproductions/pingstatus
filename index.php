<!DOCTYPE html>
<html>

<head>
    <title>VPN Status Page</title>
    <meta http-equiv="refresh" content="300">
</head>

<body>

<h1>VPN Status Page</h1>

<p>Current VPN Status:</p>

<br>
<?php
$directory_to_read_from = './pingstatus';
if ($handle = opendir($directory_to_read_from))
{
    while (false !== ($entry = readdir($handle)))
    {
        if ($entry != "." && $entry != "..")
        {
            $name = explode('-', $entry);
            echo '<h1>' . $name[0] . "</h1><img src='$directory_to_read_from/$entry' /><br>";
        }
    }
    closedir($handle);
}

?>
<!-- STATUS -->

</body>
</html>

