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

-- View: export del profilo (CURRENT/TARGET) con controlli/subcategory e asset associati
CREATE VIEW view_csv_profilo_framework AS
SELECT
    a.codice_acn,
    a.nome AS azienda,
    p.tipo AS tipo_profilo,
    p.data_riferimento,
    cf.codice AS categoria_codice,
    sc.codice AS subcategory_codice,
    sc.descrizione AS subcategory_descrizione,
    pv.stato,
    pv.livello_maturita,
    STRING_AGG(DISTINCT ass.nome, ', ') AS asset_associati
FROM Profilo p
JOIN Azienda a ON a.id_azienda = p.id_azienda
JOIN ProfiloVoce pv ON pv.id_profilo = p.id_profilo
JOIN Subcategory sc ON sc.id_subcategory = pv.id_subcategory
JOIN CategoriaFramework cf ON cf.id_categoria = sc.id_categoria
LEFT JOIN AssetSubcategory asub ON asub.id_subcategory = sc.id_subcategory
LEFT JOIN Asset ass ON ass.id_asset = asub.id_asset
GROUP BY
    a.codice_acn, a.nome,
    p.tipo, p.data_riferimento,
    cf.codice, sc.codice, sc.descrizione,
    pv.stato, pv.livello_maturita;


-- Esempio di esportazione CSV
COPY (SELECT * FROM view_csv_export) 
TO '/var/lib/postgresql/export/profilo_acn.csv' 
WITH (FORMAT CSV, HEADER, DELIMITER ';');;
