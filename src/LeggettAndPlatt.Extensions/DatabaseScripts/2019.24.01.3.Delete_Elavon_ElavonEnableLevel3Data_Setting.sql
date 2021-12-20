IF((SELECT COUNT(1) FROM SystemSetting WHERE name = 'Elavon_ElavonEnableLevel3Data')=1)
BEGIN
DELETE FROM SystemSetting WHERE name = 'Elavon_ElavonEnableLevel3Data';
END
