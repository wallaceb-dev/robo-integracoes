<?php

$xml = simplexml_load_file('./xml/parcelas.xml');
$exit_code = 0;

/**
 * 3 - Pago
 */
foreach($xml as $row) {
    if($row->field == 3) {
        $exit_code = 1;
        break;
    }
}
echo $exit_code;