DROP DATABASE if exists mushroomon;

CREATE DATABASE  if not exists mushroomon;

USE mushroomon;

CREATE TABLE `checklists` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `checklist` varchar(1000) NOT NULL,
      PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;

-- CREATE TABLE `results` (
--       `id` int(11) NOT NULL AUTO_INCREMENT,
--       `hostname` varchar(100) NOT NULL,
--       `checklist_id` int(11) NOT NULL,
--       `time_checked` datetime DEFAULT NULL,
--       `phase` ENUM('1','2') NOT NULL,
--       `result` int(11) DEFAULT NULL,
--       PRIMARY KEY (`id`),
--       FOREIGN KEY (`checklist_id`) REFERENCES checklists(`id`)
-- ) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;

CREATE TABLE `loony_info` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `hostname` varchar(100) NOT NULL,
      `time_checked` datetime DEFAULT NULL,
      `managed` varchar(50) DEFAULT NULL,
      `other_info` varchar(1000) DEFAULT NULL,
      PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;

CREATE TABLE `runs` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `time_checked` datetime DEFAULT NULL,
      `checklist_id` int(11) NOT NULL,
      `phase` ENUM('1','2') NOT NULL,
      PRIMARY KEY (`id`),
      FOREIGN KEY (`checklist_id`) REFERENCES checklists(`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;

CREATE TABLE `good_hosts` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `hostname` varchar(100) NOT NULL,
      `run_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      FOREIGN KEY (`run_id`) REFERENCES runs(`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;

CREATE TABLE `bad_hosts` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `hostname` varchar(100) NOT NULL,
      `run_id` int(11) NOT NULL,
      `check` varchar(50) NOT NULL,
      `result` ENUM('OK','FAIL'),
      PRIMARY KEY (`id`),
      FOREIGN KEY (`run_id`) REFERENCES runs(`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;


-- new design
--
--  3 talbles needed:  checklists, hosts, check_results
--
CREATE TABLE `hosts` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `hostname` varchar(100) NOT NULL,
      PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;

CREATE TABLE `check_results` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `host_id` int(11) NOT NULL,
      `checklist_id` int(11) NOT NULL,
      `result` int(11) NOT NULL,
      `time_checked` datetime  NOT NULL,
      `phase` ENUM('1','2') NOT NULL,
      PRIMARY KEY (`id`),
      FOREIGN KEY (`host_id`) REFERENCES hosts(`id`),
      FOREIGN KEY (`checklist_id`) REFERENCES checklists(`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1582 DEFAULT CHARSET=latin1;


-- test_table for testing, of course

CREATE TABLE `test_table` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `col1` varchar(100) NOT NULL,
      `col2` datetime DEFAULT NULL,
      `col3` ENUM('OK','FAIL'),
      PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1583 DEFAULT CHARSET=latin1;

INSERT INTO `test_table`(`col1`, `col2`, `col3`) VALUES
    ('testing, !@#53451%%^', '2012-02-22 22:21:19', 'FOOO'),
    ('this is a testy ', '2012-02-22 22:21:22', ''),
    ('foobarbaz', '2012-02-22 22:21:30', ''),
    ('foobarbaz', '2012-02-22 22:21:50', ''),
    ('test enum ok', '2012-02-23 20:04:45', 'OK'),
    ('test enum fail', '2012-02-23 20:05:56', 'FAIL');


