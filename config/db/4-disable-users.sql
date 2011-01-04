ALTER TABLE  `users` ADD  `enabled` BOOLEAN NOT NULL;

UPDATE users SET enabled =1;
