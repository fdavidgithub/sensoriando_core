--All days at 00h
SELECT cron.schedule('0 0 * * *', $$CALL jobDailyAverageData();$$);

--All months at 00h30
SELECT cron.schedule('30 0 1 * *', $$CALL jobMonthlyAverageData();$$);

--All years at 01h
SELECT cron.schedule('0 1 1 1 *', $$CALL jobYearlyAverageData();$$);

