drop trigger if exists after_courier_update;
drop trigger if exists afterproductadd;
drop trigger if exists after_order_update;
drop trigger if exists beforesubmitting;
drop trigger if exists after_customer_update;
drop trigger if exists afterAddOrder;

delimiter $$
create trigger if not exists after_courier_update
after update on couriers 
	for each row begin
		if old.status != new.status then
			insert into courierstatus_logs(coID , oldStatus , newStatus, changetime)
			values(new.CoID , old.Status ,new.Status , NOW());
		end if;
end $$
delimiter ;

delimiter $$
create trigger if not exists afterproductadd
before insert on orderproduct 
	for each row begin
        SET @curamount := (select p.productAmount from product p
			where p.productID = new.productID);
		SET @orderprice := (select p.price * (1 - p.discount) from product p
			where p.productID = new.productID);
        
        SET @totalorderproductprice := @orderprice * new.amount;
	
		SET @totalprice := (select o.totalprice from orders o where o.orderid = new.orderid limit 1);

        update orders set totalprice = @totalprice +  @totalorderproductprice where orderid = new.orderid; 
	    if new.amount > @curamount then 
			update orders
            set orderstatus = 'rejected'
            where orderID= new.orderID;
            insert into orderstatus_logs(orderid , oldStatus , newStatus, changetime)
			values(new.orderID,'registered','rejected' ,NOW());
			insert into orderDescription_logs (description,orderID) 
            values ('not enough product!', new.orderID);		
		end if;
	end $$
delimiter ;

delimiter $$
create trigger if not exists after_customer_update
after update on customer 
	for each row begin
		if old.accountBalance != new.accountBalance then
			insert into customerCredit_logs(customerID , oldCredit  , newCredit , changeTime)
			values(new.customerID , old.accountBalance , new.accountBalance , NOW());
		end if;
end $$
delimiter ;

delimiter $$
create trigger if not exists beforesubmitting
before update on orders
for each row begin
	if new.orderstatus = 'done' then
		SET @totprice := (select o.totalprice from orders o where o.orderid = new.orderid limit 1);

		SET @curcredit := (select c.accountBalance from customer c , orders o 
			where o.orderID = new.orderID and o.customerID = c.customerID);
		if @curcredit < @totprice then
            set new.orderstatus = 'rejected';
            insert into orderstatus_logs(orderid , oldStatus , newStatus, changetime)
			values(new.orderID,'registered','rejected' ,NOW());	
			insert into orderdescription_logs (description,orderID) values ('not enough credit!', new.orderID);	
				
		end if;
            
		SET @var := (SELECT coID FROM couriers c WHERE c.Status = 'free' and c.shopID = new.shopID limit 1);
		SET @s1 := (SELECT openTime FROM schedule WHERE shopID = new.shopID limit 1);
		SET @s2 := (SELECT closeTime FROM schedule WHERE shopID = new.shopID limit 1);
		if HOUR(NOW()) < @s1 or HOUR(NOW()) > @s2 then
			set new.orderstatus = 'rejected';
            insert into orderstatus_logs(orderid , oldStatus , newStatus, changetime)
			values(new.orderID,'registered','rejected' ,NOW());
			insert into orderDescription_logs (description,orderID) values ('shop is closed!', new.orderID);

        elseif @var is null then
			set new.orderstatus = 'rejected';
            insert into orderstatus_logs(orderid , oldStatus , newStatus, changetime)
			values(new.orderID,'registered','rejected' ,NOW());
            insert into orderDescription_logs (description,orderID) values ('no couriers found!', new.orderID);
            
		else
			insert into orderDescription_logs (description,orderID) values ('ready to send!',new.orderID);
			update couriers 
			set status = 'busy'
			where coID = @var;
			set @ordermoney := (select o.totalprice from orders o 
            where new.orderID = o.orderID);
			update couriers 
			set credit = credit + 0.05 * @ordermoney
			where coID = @var;
			insert into deliveries(courierID, orderID)
			values(@var , new.orderID);
            
            insert into orderstatus_logs(orderid , oldStatus , newStatus, changetime)
			values(new.orderID,'registered','delivering' ,NOW());
			set new.orderstatus = 'finished';
			insert into orderstatus_logs(orderid , oldStatus , newStatus, changetime)
			values(new.orderID,'delivering','finished' ,NOW());
            call updateProducts(new.orderID);
            update customer set accountBalance = accountBalance - @ordermoney
            where customerID = new.customerID;
		end if;        
	end if;	
end $$
delimiter ;

delimiter $$
create trigger if not exists afterAddOrder
before insert on orders 
	for each row begin
		if new.customerID is not null then   -- is registered
        if new.orderAddress not in (
            select ca.address from customer_address ca
            where ca.customerID = new.customerID ) then
			set new.orderStatus = 'rejected';
			insert into orderDescription_logs (description,orderID) values ('not a valid address!', new.orderID);
            end if;
		end if;
end $$
delimiter ;
