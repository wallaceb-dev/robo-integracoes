<?php

$xml = simplexml_load_file('./xml/pacote.xml');
$parts = [];

foreach ($xml as $key => $row) {
    $parts[] = strval($row->field[0]);
}

$dadosAluno = $parts[0];
$dadosAluno = str_replace('N??o', 'Não', $dadosAluno);
$disciplinas = $parts[1];
$parcelas = $parts[2];

$jsonContent = "$dadosAluno\"lsDisciplinas\":[$disciplinas], \"lsParcelas\":[$parcelas]}";

file_put_contents('./body.json', $jsonContent);
