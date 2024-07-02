DROP TRIGGER IF EXISTS aiPayloads ON Payloads;
CREATE TRIGGER aiPayloads AFTER INSERT ON Payloads
FOR EACH ROW
    EXECUTE FUNCTION ThingsSensorsDataCreate();
 
DROP TRIGGER IF EXISTS aiDailyAverageData ON DailyAverageData;  
CREATE TRIGGER aiDailyAverageData AFTER INSERT ON DailyAverageData
FOR EACH ROW
    EXECUTE FUNCTION ThingsSensorsDataClear();
