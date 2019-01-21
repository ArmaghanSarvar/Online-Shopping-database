drop procedure if exists registerAsCustomer;
drop procedure if exists registerAsCustomer;
drop procedure if exists addUser;
drop procedure if exists addPrivilege;
drop procedure if exists addAddress;
drop procedure if exists addPhoneNumber;
drop procedure if exists charge;
drop procedure if exists customerAddOrder;
drop procedure if exists guestAddOrder;
drop procedure if exists addProduct;
drop procedure if exists seeGuestOrderLogs;
drop procedure if exists doneOrdering;
drop procedure if exists seeCustomerOrderLogs;
drop procedure if exists changeLoginPass;
drop procedure if exists changeEmail;
drop procedure if exists updateProducts;

delimiter $$
create procedure if not exists registerAsCustomer(IN iloginPass varchar(50),
IN iEmail varchar(200),IN userName varchar(200), IN userLastName varchar(200),IN gender varchar(30),
IN credit INT)
begin
	insert into customer(loginPass,Email,customerName,customerLastName,sex,accountBalance)
    values (sha(iloginPass),iEmail,userName,userLastName,gender,credit);
    call addUser(iloginPass, userName);
end $$
delimiter ;

delimiter $$
create procedure if not exists addUser(IN iloginPass varchar(50),IN userName varchar(200))
begin
	SET @username := userName;
	SET @hostname := 'localhost';
	SET @passwd := iloginPass;
	SET @sql := CONCAT("CREATE USER ", QUOTE(@username), "@", QUOTE(@hostname), " IDENTIFIED BY ", QUOTE(@passwd));
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	deallocate prepare stmt;
	call addPrivilege('charge', QUOTE(@username));
	call addPrivilege('addAddress', QUOTE(@username));
	call addPrivilege('addPhoneNumber', QUOTE(@username));
	call addPrivilege('customerAddOrder', QUOTE(@username));
	call addPrivilege('addProduct', QUOTE(@username));
	call addPrivilege('doneOrdering', QUOTE(@username));
	call addPrivilege('seeCustomerOrderLogs', QUOTE(@username));
	call addPrivilege('changeLoginPass', QUOTE(@username));
	call addPrivilege('changeEmail', QUOTE(@username));

end $$
delimiter ;

delimiter $$
create procedure if not exists addPrivilege(IN newfunction varchar(50),IN usenamee varchar(200) )
begin
    SET @n := 'grant execute on procedure finalproject.';
	SET @procname := newfunction;
	SET @th := ' to ';
	SET @sql := CONCAT(@n, @procname, @th, usenamee , "@", 'localhost');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	deallocate prepare stmt;
end $$
delimiter ;

delimiter $$
create procedure if not exists getCustomerId(IN newusername VARCHAR(200), OUT userid INT)
begin
    select customerID into userid
    from customer
    where customerName = newusername
    limit 1;
end $$
delimiter ;

delimiter $$
create procedure if not exists addPhoneNumber(IN inphoneNum VARCHAR(30))
begin
    call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
    insert into customer_phone(phoneNum,customerID)
    values (inphoneNum, @userid);
end $$
delimiter ;

delimiter $$
create procedure if not exists addAddress(IN inaddress varchar(500), IN InpostalCode varchar(100))
begin
   call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
   insert into customer_address(Address,customerID,postalCode)
   values(inaddress, @userid, InpostalCode);
end $$
delimiter ;

delimiter $$
create procedure if not exists charge(IN money INT)
begin
	update customer
    set accountBalance = money + accountBalance
    where customerName = SUBSTRING_INDEX(user(),"@",1);
end $$
delimiter ;

delimiter $$
create procedure if not exists guestAddOrder(IN inshopID INT,
IN inaddress varchar(500))
begin
	insert into orders(shopID,customerID,orderStatus,payment,orderDate,orderAddress, TOTALPRICE)
	values(inshopID, null ,'registered','bank portal',CURDATE(),inaddress, 0);
    call listorders();
end $$
delimiter ;

delimiter $$
create procedure if not exists customerAddOrder(IN inshopID INT,
IN inpayment VARCHAR(100),IN inaddress varchar(500))
begin
	SET @sub := SUBSTRING_INDEX(user(),"@",1);
	call getCustomerId(@sub , @userid);
	insert into orders(shopID,customerID,orderStatus,payment,orderDate,orderAddress)
	values(inshopID,@userid,'registered',inpayment,CURDATE(),inaddress);
    call listorders();
end $$
delimiter ;

delimiter $$
create procedure if not exists listorders()
begin
	select * from orders;
end $$
delimiter ;

delimiter $$
create procedure if not exists addProduct(IN inorderID INT,IN inproductID INT,IN inAmount INT)
begin
	insert into orderproduct(orderID,productID,Amount)
	values(inorderID,inproductID,inAmount);
end $$
delimiter ;

delimiter $$
create procedure if not exists seeGuestOrderLogs()
begin
	select ol.orderID , ol.oldStatus, ol.newStatus , ol.changetime
    from orderstatus_logs ol, orders o
    where o.orderID = ol.orderID and o.customerID is null;
end $$
delimiter ;

delimiter $$
create procedure if not exists seeCustomerOrderLogs()
begin
	call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
	select ol.orderID , ol.oldStatus, ol.newStatus , ol.changetime
    from orderstatus_logs ol, orders o
    where o.orderID = ol.orderID and o.customerID = @userid;
end $$
delimiter ;

delimiter $$
create procedure if not exists doneOrdering(in inorderid int)
begin
	SET @curstat := (select orderstatus from orders where orderid = inorderid);
    if @curstat = 'registered' then
		update orders set orderstatus = 'done' where orderid = inorderid;
    end if;
end $$
delimiter ;

delimiter $$
create procedure if not exists changeLoginPass(IN inlogpass varchar(50))
begin
	call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
    update customer
    set loginPass = sha(inlogpass)
    where
    customerID = @userid;
end $$
delimiter ;

delimiter $$
create procedure if not exists changeEmail(IN inEmail varchar(200))
begin
	call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
    update customer
    set Email = inEmail
    where
    customerID = @userid;
end $$
delimiter ;

delimiter $$
create procedure if not exists updateProducts(in inorderid int)
begin
    declare pid int;
    declare done int default false;
	declare cur cursor for select productID from product;
    declare continue handler for not found set done = true;
    open cur;
    read_loop: loop
    fetch cur into pid;
        if done then
      leave read_loop;
    end if;
	  if pid in (select productid from orderproduct where orderid = inorderid) then
      set @amount := (select sum(amount) from orderproduct where orderid = inorderid limit 1);
      set @av := (select productAmount from product where productID = pid limit 1);
      update product set productAmount = @av - @amount where productID = pid;
	end if;
    end loop;
    close cur;
end $$
delimiter ;

