<?php
//phpinfo();
//exit();
error_reporting(E_ALL);

use SAPNWRFC\Connection as SapConnection;
use SAPNWRFC\Exception as SapException;

$config = [
    'ashost' => '192.168.0.10',
    'sysnr'  => '00',
    'client' => '800',
    'user'   => 'DEVELOPER',
    'passwd' => 'abap001',
    'trace'  => SapConnection::TRACE_LEVEL_OFF,
];

try {
    $c = new SapConnection($config);

    $f = $c->getFunction('ZFM_TEST_RFC');
    $result = $f->invoke([
        'ID_PARAM1' => 'teste',
		'IS_SAIRPORT' => [
			"ID" => "AAA"
		],
		'CD_PARAM1' => 1,
		'CS_SAIRPORT' => [
			"ID" => "AAA"
		]
    ]);

	echo "<pre>";
    var_dump($result);
	echo "</pre>";
} catch(SapException $ex) {
    echo 'Exception: ' . $ex->getMessage() . PHP_EOL;
}
?>
