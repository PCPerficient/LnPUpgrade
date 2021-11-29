General Steps
1. Run the DuplicateRecordsReport_3x.sql to find any duplicates that are not going to be automatically removed
2. Fix the duplicates so that the unique indexes will succeed
3. Get your database up to 3.7.1
	a. Point an up to date 3.7.1 codebase at your database and start the site
	b. This may involve some failing scripts. Our 3.7.1 code doesn't hard fail when a script fails. It logs it and continues. Consult the application log to determine if a sql script failed. If it did
		1. Find the 1st script that failed. Address this one first. Other failures may have happened because of this
		2. After addressing a script failing, restore back to the original database, restart the site, etc
	We may want to modify 3.7.1 to have a mode for "HardFailOnScriptFailure" to help us with tracking down failing scripts.
	This would need to wrap the scripts running in transactions. Committing after each successful script. If one fails, rollback the transaction. And make sure the exception bubbles up. Right now there are a couple catches in that startuptask.
4. Fix Default Constraints
	a. If any default constraints were created above without names, they get weird auto generated names. Run RenameConstraints.sql before doing the step below. This will ensure this process becomes repeatable.
5. Compare your 3.7.1 against a database created using standard371database.sql
	a. use sql compare to compaer the standard against your database. If your database contains some extra tables/sprocs/etc they can probably be ignored.
	b. generate a script that you can use to get your 3.7.1 db up to the "standard"
6. run the 3 scripts here in order