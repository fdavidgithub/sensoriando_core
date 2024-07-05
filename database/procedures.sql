CREATE OR REPLACE PROCEDURE PayloadInsert(connPayload JSONb, connQos INTEGER, connRetained BOOLEAN, connTopic VARCHAR) AS
$$
DECLARE
    connId INTEGER;
BEGIN
    SELECT c.id INTO connId
    FROM Connections c
    WHERE c.qos = connQos
    AND   c.retained = connRetained
    AND   c.topic = connTopic;

    IF connId IS NULL THEN
        INSERT INTO Connections (qos, retained, topic)
        VALUES (connQos, connRetained, connTopic) 
        RETURNING id INTO connId;
    END IF;

    INSERT INTO Payloads (id_connection, payload)
    VALUES (connId, connPayload);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE DailyAverageDataInsert(
    day_param   INTEGER,
    month_param INTEGER,
    year_param  INTEGER 
) AS
$$
DECLARE
    dtTarget DATE;
BEGIN
    dtTarget := MAKE_DATE(year_param, month_param, day_param);

    INSERT INTO DailyAverageData (id_thingsensor, year, month, day, value)
    SELECT  tsd.id_thingsensor,    
            EXTRACT(YEAR FROM tsd.dtread),
            EXTRACT(MONTH FROM tsd.dtread),
            EXTRACT(DAY FROM tsd.dtread),
            AVG(tsd.value)
    FROM ThingsSensorsData tsd
    WHERE tsd.dtread::date = dtTarget 
    GROUP BY    tsd.id_thingsensor,
                EXTRACT(YEAR FROM tsd.dtread),
                EXTRACT(MONTH FROM tsd.dtread),
                EXTRACT(DAY FROM tsd.dtread);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE MonthlyAverageDataInsert(
    month_param INTEGER,
    year_param  INTEGER 
) AS
$$
BEGIN
    INSERT INTO MonthlyAverageData (id_thingsensor, year, month, value)
    SELECT  dad.id_thingsensor,    
            dad.year,
            dad.month,
            AVG(dad.value)
    FROM DailyAverageData dad
    WHERE   dad.month = month_param
    AND     dad.year = year_param
    GROUP BY    dad.id_thingsensor,
                dad.year, 
                dad.month; 

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE YearlyAverageDataInsert(
    year_param INTEGER
) AS
$$
BEGIN
    INSERT INTO YearlyAverageData (id_thingsensor, year, value)
    SELECT  mad.id_thingsensor,    
            mad.year,
            AVG(mad.value)
    FROM MonthlyAverageData mad
    WHERE mad.year = year_param
    GROUP BY    mad.id_thingsensor,
                mad.year;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE DatumFromJson(id_payload INTEGER) AS
$$
BEGIN
    INSERT INTO ThingsSensorsData (id_payload, id_thingsensor, dtread, value, message)
    SELECT  p.id,
            ts.id, 

            CASE 
                WHEN p.payload->>'dt' IS NOT NULL 
                    THEN TIMEZONE('UTC', CAST(TO_TIMESTAMP(p.payload->>'dt', 'YYYYMMDDHH24MISS') AS VARCHAR)::TIMESTAMP)
                ELSE p.dt
            END,

            CASE 
                WHEN p.payload->>'value'::varchar ~ '^[0-9\.]+$' = True
                    THEN CAST(p.payload->>'value' AS FLOAT)
                ELSE NULL
            END,
 
            CASE 
                WHEN p.payload->>'value'::varchar ~ '^[0-9\.]+$' = False
                    THEN CAST(p.payload->>'value' AS VARCHAR)
                ELSE NULL
            END
    FROM Payloads p
      INNER JOIN Connections c ON c.id = p.id_connection
      INNER JOIN Things t ON t.uuid = SUBSTRING(c.topic, 1, STRPOS(c.topic, '/')-1)::uuid
      INNER JOIN Sensors s ON s.id = SUBSTRING(c.topic, STRPOS(c.topic, '/')+1, LENGTH(c.topic))::INTEGER 
      INNER JOIN ThingsSensors ts ON ts.id_thing = t.id 
                                 AND ts.id_sensor = s.id     
    WHERE p.id = id_payload;
      
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE jobDailyAverageData() AS
$$
DECLARE
    dt      DATE;
    day     INTEGER;
    month   INTEGER;
    year    INTEGER;
    command VARCHAR(50);
BEGIN
    dt := CURRENT_DATE - INTERVAL '1 day';
    day := EXTRACT(DAY FROM dt);
    month := EXTRACT(MONTH FROM dt);
    year := EXTRACT(YEAR FROM dt);
    command := 'DailyAverageDataInsert(' || day || ',' || month || ',' || year || ')';   
    CALL DailyAverageDataInsert(day, month, year);
    
    INSERT INTO logCrons (command)
    VALUES (command);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE jobMonthlyAverageData() AS
$$
DECLARE
    dt      DATE;
    month   INTEGER;
    year    INTEGER;
    command VARCHAR(50);
BEGIN
    dt := CURRENT_DATE - INTERVAL '1 month';
    month := EXTRACT(MONTH FROM dt);
    year := EXTRACT(YEAR FROM dt);
    command := 'MonthlyAverageDataInsert(' || month || ',' || year || ')'; 

    CALL MonthlyAverageDataInsert(month, year);

    INSERT INTO logCrons (command)
    VALUES (command);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE jobYearlyAverageData() AS
$$
DECLARE
    dt      DATE;
    year    INTEGER;
    command VARCHAR(50);
BEGIN
    dt := CURRENT_DATE - INTERVAL '1 year';
    year := EXTRACT(YEAR FROM dt);
    command := 'YearlyAverageDataInsert(' || year || ')'; 

    CALL YearlyAverageDataInsert(year);

    INSERT INTO logCrons (command)
    VALUES (command);

END;
$$ LANGUAGE plpgsql;

