CREATE OR REPLACE FUNCTION ThingsSensorsDataCreate() RETURNS TRIGGER AS
$BODY$
BEGIN
    CALL DatumFromJson(NEW.id);
    RETURN NEW;      
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ThingsSensorsDataClear() RETURNS TRIGGER AS 
$BODY$
DECLARE
    dtTarget DATE;
BEGIN
    dtTarget := MAKE_DATE(
        NEW.year,
        NEW.month,
        NEW.day
    );

    DELETE FROM ThingsSensorsData tsd
    WHERE tsd.dtread::date = dtTarget;

    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

