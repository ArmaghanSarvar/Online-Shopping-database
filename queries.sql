-- 1
(SELECT sum(op.Amount) as allsum,p.productName, o.shopID
from orderproduct op INNER JOIN product p INNER JOIN orders o ON o.orderID = op.orderID AND p.productID = op.productID WHERE o.shopID = 1
GROUP By p.productName , o.shopID
ORDER BY o.shopID,SUM(op.Amount) DESC	
LIMIT 5)
UNION ALL
(SELECT sum(op.Amount) as allsum,p.productName , o.shopID
from orderproduct op INNER JOIN product p INNER JOIN orders o ON o.orderID = op.orderID AND p.productID = op.productID WHERE o.shopID = 2
GROUP By p.productName , o.shopID
ORDER BY o.shopID,SUM(op.Amount) DESC	
LIMIT 5)
UNION ALL
(SELECT sum(op.Amount) as allsum,p.productName, o.shopID
from orderproduct op INNER JOIN product p INNER JOIN orders o ON o.orderID = op.orderID AND p.productID = op.productID WHERE o.shopID = 3
GROUP By p.productName , o.shopID
ORDER BY o.shopID,SUM(op.Amount) DESC	
LIMIT 5)
UNION ALL
(SELECT sum(op.Amount) as tsum,p.productName, o.shopID
from orderproduct op INNER JOIN product p INNER JOIN orders o ON o.orderID = op.orderID AND p.productID = op.productID WHERE o.shopID = 4
GROUP By p.productName , o.shopID
ORDER BY o.shopID,SUM(op.Amount) DESC	
LIMIT 5)
UNION ALL
(SELECT sum(op.Amount) as allsum,p.productName, o.shopID
from orderproduct op INNER JOIN product p INNER JOIN orders o ON o.orderID = op.orderID AND p.productID = op.productID WHERE o.shopID = 5
GROUP By p.productName , o.shopID
ORDER BY o.shopID,SUM(op.Amount) DESC	
LIMIT 5);
-- 2
select phonenum, customer_phone.customerID from customer_phone inner join orders on
orders.customerID = customer_phone.customerID
where
orders.orderStatus = 'rejected';
-- 3
select (
(select avg(totalprice) from orders where customerid is not null and orderstatus = 'finished')
-
(select avg(totalprice) from orders where customerid is null and orderstatus = 'finished')
) as diff;
-- 4
select d.courierID, AVG(o.totalprice) as averagep
from
orders o inner join deliveries d inner join couriers c	
on
d.orderID = o.orderID and c.CoID = d.courierID
group by d.courierID
ORDER BY averagep DESC
LIMIT 1;
-- 5
select shopID , timediff(closetime,opentime) as working_hours
from schedule 
where (timediff(closetime,opentime)) = (
	select MAX(timediff(closetime,opentime))
    from schedule
    )
