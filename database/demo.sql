INSERT INTO Things (name) VALUES ('THING_TEST #1 (Hub)'); --id 1
INSERT INTO Things (name) VALUES ('THING_TEST #2 (Sensor)'); --id 2
INSERT INTO Things (name, isrelay) VALUES ('THING_TEST #3 (Relay)', True); --id 3

INSERT INTO ThingsSensors (id_thing, id_sensor)
VALUES (1, (SELECT id FROM Sensors WHERE name = 'Tempo')),
       (1, (SELECT id FROM Sensors WHERE name = 'Armazenamento')),
       (1, (SELECT id FROM Sensors WHERE name = 'Mensagem')),
       (2, (SELECT id FROM Sensors WHERE name = 'Temperatura')),
       (2, (SELECT id FROM Sensors WHERE name = 'Humidade')),
       (3, (SELECT id FROM Sensors WHERE name = 'Estado'));
 
INSERT INTO Accounts (username, city, state, country) VALUES ('demo1', 'Ribeirao Preto', 'SP', 'BR');
INSERT INTO Accounts (username, city, state, country) VALUES ('demo2', 'Sao Paulo', 'SP', 'BR');
INSERT INTO Accounts (username, city, state, country) VALUES ('demo3', 'Nova York', 'NY', 'US');

INSERT INTO AccountsThings (id_account, id_thing) VALUES (1, 1);
INSERT INTO AccountsThings (id_account, id_thing) VALUES (2, 2);
INSERT INTO AccountsThings (id_account, id_thing) VALUES (3, 3);

