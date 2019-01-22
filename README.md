# Online-Shopping-database
the project includes tables of database such as shops, couriers, customer,etc.    ( all in ddl.sql )
+
the triggers needed for several checks on each action and saving logs.
changes such as 
* reduction of customer accountBalance
* reduction of products count
* change in the status of couriers(busy or free) 
* change in orderstatus (registered, delivering, done, finished) 

are all implemented in the triggers.sql file.

procedures.sql file includes procedures available(granted) to different users (guest or registered customers) such as
* updating the login information(like password)
* ordering
* adding different products
* charging the credit
* adding address and other table information
