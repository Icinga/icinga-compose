<?php

require_once '/usr/share/icingaweb2/library/Icinga/Application/Cli.php';

use Icinga\Application\Cli;
use Icinga\Data\Db\DbConnection;

Cli::start('/usr/share/icingaweb2');

$db = DbConnection::fromResourceName(getenv('icingaweb_modules_x509_config_backend_resource'))->getDbAdapter();
for ($attempt = 1; ; ++$attempt) {
    try {
        $db->query('SELECT 1');
        break;
    } catch (PDOException | Zend_Db_Adapter_Exception $e) {
        if ($attempt >= 30) {
            throw $e;
        }

        sleep(1);
    }
}

try {
    $db->fetchOne('SELECT 1 FROM x509_schema');
} catch (Exception $e) {
    $dbType = getenv('icingaweb_resources_x509_db');
    $sql = file_get_contents("/usr/share/icingaweb2/modules/x509/schema/$dbType.schema.sql");

    if ($dbType === 'pgsql') {
        $db->getConnection()->exec($sql);
    } else {
        foreach (explode(';', $sql) as $stmt) {
            if (trim($stmt) !== '') {
                $db->query($stmt);
            }
        }
    }
}
