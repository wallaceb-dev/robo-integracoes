<?php

$file = file_get_contents('./body.json');

$file = str_replace('N??o', 'Não', $file);

file_put_contents('./body.json', $file);
