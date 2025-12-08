-- Query 

SELECT a.nome AS azienda, 
       s.nome AS servizio, 
       as.nome AS asset, 
       as.criticita,
       f.nome AS fornitore
FROM Azienda a
JOIN Asset as ON a.id_azienda = as.id_azienda
JOIN Servizio s ON s.id_servizio = as.id_asset
LEFT JOIN Dipendenza d ON s.id_servizio = d.id_servizio
LEFT JOIN Fornitore f ON d.id_fornitore = f.id_fornitore
WHERE as.criticita >= 4;
View per export automatico
CREATE VIEW view_csv_export AS
SELECT a.codice_acn, a.nome AS azienda, 
       s.nome AS servizio, 
       as.nome AS asset, 
       as.categoria, 
       as.criticita, 
       f.nome AS fornitore, 
       c.nome AS contatto, 
       c.email
FROM Azienda a
JOIN Asset as ON a.id_azienda = as.id_azienda
JOIN Servizio s ON s.id_servizio = as.id_asset
LEFT JOIN Dipendenza d ON s.id_servizio = d.id_servizio
LEFT JOIN Fornitore f ON d.id_fornitore = f.id_fornitore
LEFT JOIN Contatto c ON a.id_azienda = c.id_azienda;

Esempio di esportazione CSV
COPY (SELECT * FROM view_csv_export) 
TO '/var/lib/postgresql/export/profilo_acn.csv' 
WITH (FORMAT CSV, HEADER, DELIMITER ';');
