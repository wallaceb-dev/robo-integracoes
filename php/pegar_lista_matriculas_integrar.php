<?php

$xml = simplexml_load_file('./xml/lista_matriculas_integraveis.xml');
$matriculas = [];

foreach ($xml as $key => $row) {
    $matriculas[] = strval($row->field[0]);
}

echo implode(',', $matriculas);