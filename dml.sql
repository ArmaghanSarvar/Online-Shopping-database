create user if not exists Guest@localhost identified by 'Guest';
grant execute on procedure finalproject.registerAsCustomer to Guest@localhost;
grant execute on procedure finalproject.guestAddOrder to Guest@localhost;
grant execute on procedure finalproject.addProduct to Guest@localhost;
grant execute on procedure finalproject.seeGuestOrderLogs to Guest@localhost;
grant execute on procedure finalproject.doneOrdering to Guest@localhost;

flush privileges;
SET SQL_SAFE_UPDATES=0;
