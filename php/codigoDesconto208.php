<?php

$file = file_get_contents('./body.json');

$file = str_replace('"cdDesconto":"208"', '"cdDesconto":"226"', $file);

file_put_contents('./body.json', $file);