-- dataset simulato 
-- Per la verifica funzionale sono stati creati script di popolamento (INSERT INTO) con dati fittizi ma coerenti, utilizzati per testare query e vincoli.

INSERT INTO Azienda (nome, codice_acn, settore, sede_legale)
VALUES ('Alfa Systems', 'ACN001', 'ICT', 'Milano'),
       ('Beta Digital', 'ACN002', 'Servizi Cloud', 'Torino');
INSERT INTO Asset (nome, categoria, criticita, id_azienda)
VALUES ('Router Edge X3200', 'Networking', 5, 1),
       ('SAN QNAP-45T', 'Storage', 4, 1),
       ('MailServer-EX200', 'Server Mail', 3, 2);
