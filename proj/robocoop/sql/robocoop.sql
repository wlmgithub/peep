
CREATE DATABASE  if not exists robocoop;

USE robocoop;

CREATE TABLE `events` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `release_id` varchar(100) NOT NULL,
      `meta_data` varchar(20480) DEFAULT NULL,
      PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;


