<?php

$dsn = 'pgsql:dbname=sistemas;host=127.0.0.1';
$user = 'usermd5';
$password = 's1sadm1n';

$pdo = new DBO($dsn, $user, $password);
$result = $pdo->query('select "nome" from esic.lda_solicitante where "idsolicitante" = 3 limit 1')->fetch(DBO::FETCH_NUM);
//statement: DEALLOCATE pdo_stmt_00000001
// $st = $pdo->prepare('select "nome" from esic.lda_solicitante where "idsolicitante" = ? limit 1');
// $st->execute([3]);
// $result = $st->fetch(DBO::FETCH_NUM);

 print_r($result);