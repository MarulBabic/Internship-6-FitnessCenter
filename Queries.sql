--Ime, prezime, spol (ispisati ‘MUŠKI’, ‘ŽENSKI’, ‘NEPOZNATO’, ‘OSTALO’), ime države i prosječna plaća u toj državi za svakog trenera.
SELECT 
    c.name AS coach_name,
    c.gender,
    co.name AS country_name,
    co.avg_salary AS country_avg_salary
FROM 
    Coaches c
JOIN 
    Countries co ON c.country = co.id;

--Naziv i termin održavanja svake sportske igre zajedno s imenima glavnih trenera (u formatu Prezime, I.; npr. Horvat, M.; Petrović, T.).
SELECT 
    a.type AS activity_name, 
    s.time_of_activity AS activity_time, 
    CONCAT(c.name, ', ', LEFT(c.name, 1), '.') AS main_trainer
FROM 
    Schedules s
JOIN 
    ActivitiesInFC aif ON s.activityCode = aif.id
JOIN 
    Activities a ON a.id = aif.activity
JOIN 
    FitnessCenterCoaches fcc ON fcc.fitness_center_id = aif.fitness_center
JOIN 
    Coaches c ON c.id = fcc.coach_id
WHERE 
    fcc.coach_type = 'glavni trener'
ORDER BY 
    s.time_of_activity;

--Top 3 fitness centra s najvećim brojem aktivnosti u rasporedu
SELECT 
    fc.name AS fitness_center_name,
    COUNT(aif.id) AS activity_count
FROM 
    FitnessCenters fc
JOIN 
    ActivitiesInFC aif ON fc.id = aif.fitness_center
GROUP BY 
    fc.id
ORDER BY 
    activity_count DESC
LIMIT 3;


--Po svakom terneru koliko trenutno aktivnosti vodi; ako nema aktivnosti, ispiši “DOSTUPAN”, ako ima do 3 ispiši “AKTIVAN”, a ako je na više ispiši “POTPUNO ZAUZET”.
SELECT 
    c.name AS coach_name,
    COUNT(aif.id) AS activity_count,
    CASE 
        WHEN COUNT(aif.id) = 0 THEN 'DOSTUPAN'
        WHEN COUNT(aif.id) <= 3 THEN 'AKTIVAN'
        ELSE 'POTPUNO ZAUZET'
    END AS status
FROM 
    Coaches c
LEFT JOIN 
    ActivitiesInFC aif ON c.id = aif.coach
GROUP BY 
    c.id
ORDER BY 
    activity_count DESC;


--Imena svih članova koji trenutno sudjeluju na nekoj aktivnosti.
SELECT 
    s.uniqueCode AS activity_code,  
    a.type AS activity_type,  
    STRING_AGG(u.name, ', ') AS participant_names  
FROM 
    Schedules s
JOIN 
    UserActivities ua ON s.id = ua.schedule_id
JOIN 
    Users u ON ua.user_id = u.id
JOIN 
    ActivitiesInFC aif ON s.activityCode = aif.id  
JOIN 
    Activities a ON aif.activity = a.id  
GROUP BY 
    s.id, s.uniqueCode, a.type  
ORDER BY 
    activity_type;  


--Sve trenere koji su vodili barem jednu aktivnost između 2019. i 2022.
SELECT DISTINCT c.id AS coach_id, c.name AS coach_name
FROM Coaches c
JOIN ActivitiesInFC aif ON c.id = aif.coach
JOIN Schedules s ON aif.id = s.activityCode
WHERE s.time_of_activity BETWEEN '2019-01-01' AND '2022-12-31';


--Prosječan broj sudjelovanja po tipu aktivnosti po svakoj državi.
SELECT 
    c.name AS country_name,
    a.type AS activity_type,
    ROUND(AVG(s.occupancy), 2) AS average_participation
FROM 
    Countries c
JOIN 
    FitnessCenters fc ON c.id = fc.country
JOIN 
    ActivitiesInFC aif ON fc.id = aif.fitness_center
JOIN 
    Activities a ON aif.activity = a.id
JOIN 
    Schedules s ON aif.id = s.activityCode
JOIN 
    UserActivities ua ON s.id = ua.schedule_id
JOIN 
    Users u ON ua.user_id = u.id
GROUP BY 
    c.name, a.type
ORDER BY 
    country_name, activity_type;


--Top 10 država s najvećim brojem sudjelovanja u injury rehabilitation tipu aktivnosti
SELECT 
    c.name AS country_name,
    SUM(s.occupancy) AS total_participation
FROM 
    Countries c
JOIN 
    FitnessCenters fc ON c.id = fc.country
JOIN 
    ActivitiesInFC aif ON fc.id = aif.fitness_center
JOIN 
    Activities a ON aif.activity = a.id
JOIN 
    Schedules s ON aif.id = s.activityCode
WHERE 
    a.type = 'injury rehabilitation'
GROUP BY 
    c.name
ORDER BY 
    total_participation DESC
LIMIT 10;

--Ako aktivnost nije popunjena, ispiši uz nju “IMA MJESTA”, a ako je popunjena ispiši “POPUNJENO”
SELECT 
    s.uniqueCode,
    a.type AS activity_type,
    CASE
        WHEN s.occupancy < s.max_occupancy THEN 'IMA MJESTA'
        ELSE 'POPUNJENO'
    END AS availability_status
FROM 
    Schedules s
JOIN 
    ActivitiesInFC aif ON s.activityCode = aif.id
JOIN 
    Activities a ON aif.activity = a.id
ORDER BY 
    s.time_of_activity;

--10 najplaćenijih trenera, ako po svakoj aktivnosti dobije prihod kao brojSudionika * cijenaPoTerminu
SELECT 
    c.name AS trainer_name, 
    SUM(s.occupancy * s.price_per_session) AS total_income
FROM 
    Coaches c
JOIN 
    FitnessCenterCoaches fcc ON c.id = fcc.coach_id
JOIN 
    ActivitiesInFC aif ON fcc.fitness_center_id = aif.fitness_center
JOIN 
    Schedules s ON aif.id = s.activityCode
GROUP BY 
    c.id
ORDER BY 
    total_income DESC
LIMIT 10;

















