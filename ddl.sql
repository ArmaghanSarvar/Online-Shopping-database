-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 20, 2019 at 02:39 PM
-- Server version: 10.1.26-MariaDB
-- PHP Version: 7.1.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `finalproject`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addAddress` (IN `inaddress` VARCHAR(500), IN `InpostalCode` VARCHAR(100))  begin
   call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
   insert into customer_address(Address,customerID,postalCode)
   values(inaddress, @userid, InpostalCode);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addPhoneNumber` (IN `inphoneNum` VARCHAR(30))  begin
    call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
    insert into customer_phone(phoneNum,customerID)
    values (inphoneNum, @userid);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addPrivilege` (IN `newfunction` VARCHAR(50), IN `usenamee` VARCHAR(200))  begin
    SET @n := 'grant execute on procedure finalproject.';
	SET @procname := newfunction;
	SET @th := ' to ';
	SET @sql := CONCAT(@n, @procname, @th, usenamee , "@", 'localhost');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	deallocate prepare stmt;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addProduct` (IN `inorderID` INT, IN `inproductID` INT, IN `inAmount` INT)  begin
	insert into orderproduct(orderID,productID,Amount)
	values(inorderID,inproductID,inAmount);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addUser` (IN `iloginPass` VARCHAR(50), IN `userName` VARCHAR(200))  begin
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

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `changeEmail` (IN `inEmail` VARCHAR(200))  begin
	call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
    update customer
    set Email = inEmail
    where
    customerID = @userid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `changeLoginPass` (IN `inlogpass` VARCHAR(50))  begin
	call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
    update customer
    set loginPass = sha(inlogpass)
    where
    customerID = @userid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `charge` (IN `money` INT)  begin
	update customer
    set accountBalance = money + accountBalance
    where customerName = SUBSTRING_INDEX(user(),"@",1);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `customerAddOrder` (IN `inshopID` INT, IN `inpayment` VARCHAR(100), IN `inaddress` VARCHAR(500))  begin
	SET @sub := SUBSTRING_INDEX(user(),"@",1);
	call getCustomerId(@sub , @userid);
	insert into orders(shopID,customerID,orderStatus,payment,orderDate,orderAddress)
	values(inshopID,@userid,'registered',inpayment,CURDATE(),inaddress);
    call listorders();
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `doneOrdering` (IN `inorderid` INT)  begin
	SET @curstat := (select orderstatus from orders where orderid = inorderid);
    if @curstat = 'registered' then
		update orders set orderstatus = 'done' where orderid = inorderid;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCustomerId` (IN `newusername` VARCHAR(255), OUT `userid` INT)  begin
    select customerID into userid
    from customer
    where customerName = newusername
    limit 1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `guestAddOrder` (IN `inshopID` INT, IN `inaddress` VARCHAR(500))  begin
	insert into orders(shopID,customerID,orderStatus,payment,orderDate,orderAddress, TOTALPRICE)
	values(inshopID, null ,'registered','bank portal',CURDATE(),inaddress, 0);
    call listorders();
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listorders` ()  begin
	select * from orders;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerAsCustomer` (IN `iloginPass` VARCHAR(50), IN `iEmail` VARCHAR(200), IN `userName` VARCHAR(200), IN `userLastName` VARCHAR(200), IN `gender` VARCHAR(30), IN `credit` INT)  begin
	insert into customer(loginPass,Email,customerName,customerLastName,sex,accountBalance)
    values (sha(iloginPass),iEmail,userName,userLastName,gender,credit);
    call addUser(iloginPass, userName);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `seeCustomerOrderLogs` ()  begin
	call getCustomerId(SUBSTRING_INDEX(user(),"@",1), @userid);
	select ol.orderID , ol.oldStatus, ol.newStatus , ol.changetime
    from orderstatus_logs ol, orders o
    where o.orderID = ol.orderID and o.customerID = @userid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `seeGuestOrderLogs` ()  begin
	select ol.orderID , ol.oldStatus, ol.newStatus , ol.changetime
    from orderstatus_logs ol, orders o
    where o.orderID = ol.orderID and o.customerID is null;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `couriers`
--

CREATE TABLE `couriers` (
  `CoID` int(11) NOT NULL,
  `CoName` varchar(200) DEFAULT NULL,
  `CoLastName` varchar(200) DEFAULT NULL,
  `PhoneNum` varchar(30) DEFAULT NULL,
  `credit` float DEFAULT NULL,
  `Status` varchar(100) DEFAULT NULL,
  `ShopID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `couriers`
--

INSERT INTO `couriers` (`CoID`, `CoName`, `CoLastName`, `PhoneNum`, `credit`, `Status`, `ShopID`) VALUES
(1, 'Asghar', 'Asghari', '09176654887', 68, 'busy', 2),
(2, 'Akbar', 'Akbari', '09187766543', 3055, 'busy', 1),
(3, 'Javad', 'Javadi', '09143377898', NULL, 'free', 5),
(4, 'Karim', 'Karimi', '09123344890', 5700, 'busy', 3),
(5, 'Rahman', 'Rahmani', '09176655456', 98888, 'busy', 4),
(6, 'Bagher', 'Bagheri', '09138877678', 23008, 'free', 5);

--
-- Triggers `couriers`
--
DELIMITER $$
CREATE TRIGGER `after_courier_update` AFTER UPDATE ON `couriers` FOR EACH ROW begin
		if old.status != new.status then
			insert into courierstatus_logs(coID , oldStatus , newStatus, changetime)
			values(new.CoID , old.Status ,new.Status , NOW());
		end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `courierstatus_logs`
--

CREATE TABLE `courierstatus_logs` (
  `CoID` int(11) NOT NULL,
  `oldStatus` varchar(100) DEFAULT NULL,
  `newStatus` varchar(100) DEFAULT NULL,
  `changetime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `courierstatus_logs`
--

INSERT INTO `courierstatus_logs` (`CoID`, `oldStatus`, `newStatus`, `changetime`) VALUES
(1, 'free', 'busy', '2019-01-18 19:51:37'),
(3, 'free', 'busy', '2019-01-18 19:56:34'),
(1, 'busy', 'free', '2019-01-18 20:01:40'),
(1, 'free', 'busy', '2019-01-18 20:03:08'),
(6, 'free', 'busy', '2019-01-18 20:10:56'),
(1, 'busy', 'free', '2019-01-18 20:11:14'),
(1, 'free', 'busy', '2019-01-18 20:11:41'),
(1, 'busy', 'free', '2019-01-19 21:07:58'),
(6, 'busy', 'free', '2019-01-20 10:54:23'),
(3, 'busy', 'free', '2019-01-20 10:54:26'),
(2, 'busy', 'free', '2019-01-20 11:03:42'),
(4, 'busy', 'free', '2019-01-20 11:03:45'),
(1, 'free', 'busy', '2019-01-20 11:29:29'),
(2, 'free', 'busy', '2019-01-20 12:33:49'),
(4, 'free', 'busy', '2019-01-20 15:56:23');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customerID` int(11) NOT NULL,
  `loginPass` varchar(50) DEFAULT NULL,
  `Email` varchar(200) DEFAULT NULL,
  `customerName` varchar(200) DEFAULT NULL,
  `customerLastName` varchar(200) DEFAULT NULL,
  `sex` varchar(30) DEFAULT NULL,
  `accountBalance` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customerID`, `loginPass`, `Email`, `customerName`, `customerLastName`, `sex`, `accountBalance`) VALUES
(1, 'iijuy7', 'akbar@gmail.com', 'akbar', 'javadi', 'male', 90000),
(2, 'gdufysg67676', 'haghani@yahoo.com', 'mohammad', 'haghani', 'male', 7866666),
(3, 'sbkufygdj44', 'javadaghdam@gmail.com', 'mozhgan', 'javadiaghdam', 'female', 33333444),
(4, '7766yhj', 'ghahremani32@gmail.com', 'Marjan', 'Ghahremani', '5544565465365female', 6655878),
(5, 'shaghi77yy', 'akbarim7@yahoo.com', 'shaghayegh', 'akbari', 'female', 90000),
(6, 'jhjh4343', 'taherfahim@gmail.com', 'taher', 'fahim', 'male', 100005),
(7, '40bd001563085fc35165329ea1ff5c5ecbdbbeef', 'mahi@gmail.com', 'armaghan', 'sarvar', 'female', 10000),
(8, '7b52009b64fd0a2a49e6d8a939753077792b0554', 'mm@gmail.com', 'armi', 'srv', 'female', 2000),
(9, '7110eda4d09e062aa5e4a390b0a572ac0d2c0220', 'mm@gmail.com', 'whatisit', 'srv', 'female', 2000),
(14, 'f66b7dcd21696a4242e1ff93608c405741802c92', 'mmyii@gmail.com', 'tatania', 'srv', 'female', 2700),
(15, 'fc7a734dba518f032608dfeb04f4eeb79f025aa7', 'mmyii@gmail.com', 'kimiaa', 'srv', 'female', 2000),
(16, 'e3cbba8883fe746c6e35783c9404b4bc0c7ee9eb', 'mmyii@gmail.com', 'zeinab', 'kamrani', 'female', 2900),
(17, '7507d41ecbd162a0d6dfdaaa9988a91184351735', 'mmyii@gmail.com', 'kiarash', 'kamrani', 'male', 2200),
(18, 'bd307a3ec329e10a2cff8fb87480823da114f8f4', 'comeon@gmail.com', 'kurosh', 'madani', 'male', 5000),
(19, '40bd001563085fc35165329ea1ff5c5ecbdbbeef', 'moll@gmail.com', 'i am sepehr', 'asghari', 'male', 20000),
(20, '1c6637a8f2e1f75e06ff9984894d6bd16a3a36a9', 'moliiil@gmail.com', 'sepehr', 'ahsani', 'male', 20000),
(21, '43814346e21444aaf4f70841bf7ed5ae93f55a9d', 'oiiii@gmail.com', 'karim', 'ahsani', 'male', 20000),
(22, '9a3e61b6bcc8abec08f195526c3132d5a4a98cc0', 'oiiii@gmail.com', 'jamshid', 'ahsani', 'male', 20000),
(26, '8bd7954c40c1e59a900f71ea3a266732609915b1', 'karimi@gmail.com', 'mahtb', 'mozafari', 'female', 50000),
(27, '8bd7954c40c1e59a900f71ea3a266732609915b1', 'karimikhk@gmail.com', 'mhtbi', 'mozafari', 'female', 48900),
(29, '8aefb06c426e07a0a671a1e2488b4858d694a730', 'afzalik@gmail.com', 'ahmad', 'khosravi', 'male', 10000),
(30, '8aefb06c426e07a0a671a1e2488b4858d694a730', 'afzalik@gmail.com', 'asghar', 'khosravi', 'male', -14000),
(31, 'b6589fc6ab0dc82cf12099d1c2d40ab994e8410c', 'afzooolik@gmail.com', 'ao', 'kj', 'male', 10000);

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `after_customer_update` AFTER UPDATE ON `customer` FOR EACH ROW begin
		if old.accountBalance != new.accountBalance then
			insert into customerCredit_logs(customerID , oldCredit  , newCredit , changeTime)
			values(new.customerID , old.accountBalance , new.accountBalance , NOW());
		end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customercredit_logs`
--

CREATE TABLE `customercredit_logs` (
  `customerID` int(11) DEFAULT NULL,
  `oldCredit` int(11) DEFAULT NULL,
  `newCredit` int(11) DEFAULT NULL,
  `changeTime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customercredit_logs`
--

INSERT INTO `customercredit_logs` (`customerID`, `oldCredit`, `newCredit`, `changeTime`) VALUES
(27, 50000, 48900, '2019-01-20 12:33:49'),
(30, 10000, -14000, '2019-01-20 15:56:23');

-- --------------------------------------------------------

--
-- Table structure for table `customer_address`
--

CREATE TABLE `customer_address` (
  `Address` varchar(500) DEFAULT NULL,
  `customerID` int(11) DEFAULT NULL,
  `postalCode` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer_address`
--

INSERT INTO `customer_address` (`Address`, `customerID`, `postalCode`) VALUES
('kaj avenue', 1, '22337654'),
('usef abad', 2, '66778543'),
('ghaem magham', 3, '98341288'),
('vanak', 2, '88996620'),
('first street', 4, '66349812'),
('kalami square', 5, '98348712'),
('ahangari street', 5, '09784432'),
('fourth avenue,maryam alley', 6, '23875549'),
('shahrak gharb', NULL, '33440987'),
('zafaranie', 17, '33337777'),
('mynewadd', 26, '12339987'),
('kkk', 27, '88774436'),
('kamranie', 30, '22885544'),
('lalezar', 31, '33775544');

-- --------------------------------------------------------

--
-- Table structure for table `customer_phone`
--

CREATE TABLE `customer_phone` (
  `phoneNum` varchar(30) DEFAULT NULL,
  `customerID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer_phone`
--

INSERT INTO `customer_phone` (`phoneNum`, `customerID`) VALUES
('88657789', 1),
('77665876', 2),
('55449842', 3),
('88991243', 4),
('88040357', 5),
('44338762', 6),
('09147766543', 1),
('09176654998', 2),
('09138899234', 3),
('88994432', 20),
('88332765', 21),
('4459823', 22);

-- --------------------------------------------------------

--
-- Table structure for table `deliveries`
--

CREATE TABLE `deliveries` (
  `courierID` int(11) DEFAULT NULL,
  `orderID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `deliveries`
--

INSERT INTO `deliveries` (`courierID`, `orderID`) VALUES
(1, 3),
(2, 39),
(3, 37),
(1, 45),
(2, 47),
(4, 48);

-- --------------------------------------------------------

--
-- Table structure for table `operators`
--

CREATE TABLE `operators` (
  `OpID` int(11) NOT NULL,
  `OpName` varchar(200) DEFAULT NULL,
  `OpLastName` varchar(200) DEFAULT NULL,
  `ShopID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `operators`
--

INSERT INTO `operators` (`OpID`, `OpName`, `OpLastName`, `ShopID`) VALUES
(1, 'Ahmad', 'Ahmadi', 1),
(2, 'Zahra', 'kashani', 1),
(3, 'Sheida', 'fazeli', 2),
(4, 'Amir', 'Rostami', 5),
(5, 'Leila', 'Ahari', 4),
(6, 'Shadi', 'Hoseini', 3),
(7, 'Mona', 'Asadi', 5);

-- --------------------------------------------------------

--
-- Table structure for table `orderdescription_logs`
--

CREATE TABLE `orderdescription_logs` (
  `description` varchar(255) DEFAULT NULL,
  `orderID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orderdescription_logs`
--

INSERT INTO `orderdescription_logs` (`description`, `orderID`) VALUES
('ready to send!', 45),
('ready to send!', 47),
('ready to send!', 48),
('not enough credit!', 49),
('no couriers found!', 49),
('not enough product!', 50);

-- --------------------------------------------------------

--
-- Table structure for table `orderproduct`
--

CREATE TABLE `orderproduct` (
  `orderID` int(11) DEFAULT NULL,
  `productID` int(11) DEFAULT NULL,
  `Amount` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orderproduct`
--

INSERT INTO `orderproduct` (`orderID`, `productID`, `Amount`) VALUES
(40, 5, 3),
(41, 7, 3),
(41, 2, 1),
(42, 5, 3),
(43, 1, 3),
(44, 4, 3),
(45, 2, 3),
(46, 4, 2),
(47, 4, 2),
(48, 5, 2),
(49, 5, 2),
(50, 5, 10);

--
-- Triggers `orderproduct`
--
DELIMITER $$
CREATE TRIGGER `afterproductadd` BEFORE INSERT ON `orderproduct` FOR EACH ROW begin
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
	end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `orderID` int(11) NOT NULL,
  `shopID` int(11) DEFAULT NULL,
  `customerID` int(11) DEFAULT NULL,
  `orderStatus` varchar(100) DEFAULT NULL,
  `payment` varchar(100) DEFAULT NULL,
  `orderDate` date DEFAULT NULL,
  `orderAddress` varchar(500) DEFAULT NULL,
  `totalprice` float DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`orderID`, `shopID`, `customerID`, `orderStatus`, `payment`, `orderDate`, `orderAddress`, `totalprice`) VALUES
(3, 2, 1, 'finished', 'bank portal', '2018-09-17', 'yusef abad', 3000),
(36, 2, 20, 'rejected', 'credit card', '2019-01-19', 'mofatteh', 0),
(37, 4, 21, 'rejected', 'credit card', '2019-01-19', 'velenjak', 0),
(38, 1, 22, 'rejected', 'credit card', '2019-01-19', 'jamshidieee', 0),
(39, 1, NULL, 'finished', 'bank portal', '2019-01-19', 'mohammadi avenue', 0),
(40, 4, NULL, 'rejected', 'bank portal', '2019-01-20', 'felestin', 14400),
(41, 1, NULL, 'rejected', 'bank portal', '2019-01-20', 'mohammadi avenue', 476),
(42, 2, NULL, 'rejected', 'bank portal', '2019-01-20', 'lasttest', 14400),
(43, 5, NULL, 'rejected', 'bank portal', '2019-01-20', 'ghaem', 15000),
(44, 2, NULL, 'registered', 'bank portal', '2019-01-20', 'lasttest', 1650),
(45, 2, NULL, 'finished', 'bank portal', '2019-01-20', 'zafar', 960),
(46, 3, 26, 'rejected', 'credit card', '2019-01-20', 'motahari st', 1100),
(47, 1, 27, 'finished', 'credir card', '2019-01-20', 'kkk', 1100),
(48, 3, 30, 'finished', 'credit card', '2019-01-20', 'kamranie', 24000),
(49, 3, 31, 'rejected', 'credit card', '2019-01-20', 'lalezar', 24000),
(50, 4, 31, 'rejected', 'credit card', '2019-01-20', 'lalezar', 120000);

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `afterAddOrder` BEFORE INSERT ON `orders` FOR EACH ROW begin
		if new.customerID is not null then   -- is registered
        if new.orderAddress not in (
            select ca.address from customer_address ca
            where ca.customerID = new.customerID ) then
			set new.orderStatus = 'rejected';
			insert into orderDescription_logs (description,orderID) values ('not a valid address!', new.orderID);
            end if;
		end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `beforesubmitting` BEFORE UPDATE ON `orders` FOR EACH ROW begin
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
            update customer set accountBalance = accountBalance - @ordermoney
            where customerID = new.customerID;
		end if;        
	end if;	
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orderstatus_logs`
--

CREATE TABLE `orderstatus_logs` (
  `orderID` int(11) DEFAULT NULL,
  `oldStatus` varchar(100) DEFAULT NULL,
  `newStatus` varchar(100) DEFAULT NULL,
  `changetime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orderstatus_logs`
--

INSERT INTO `orderstatus_logs` (`orderID`, `oldStatus`, `newStatus`, `changetime`) VALUES
(40, 'registered', 'rejected', '2019-01-20 10:39:52'),
(41, 'registered', 'rejected', '2019-01-20 10:45:00'),
(42, 'registered', 'rejected', '2019-01-20 10:48:46'),
(43, 'registered', 'rejected', '2019-01-20 11:04:50'),
(43, 'registered', 'done', '2019-01-20 11:04:50'),
(45, 'registered', 'delivering', '2019-01-20 11:29:29'),
(45, 'delivering', 'finished', '2019-01-20 11:29:29'),
(45, 'registered', 'done', '2019-01-20 11:29:29'),
(47, 'registered', 'delivering', '2019-01-20 12:33:49'),
(47, 'delivering', 'finished', '2019-01-20 12:33:49'),
(48, 'registered', 'delivering', '2019-01-20 15:56:23'),
(48, 'delivering', 'finished', '2019-01-20 15:56:23'),
(49, 'registered', 'rejected', '2019-01-20 17:05:50'),
(49, 'registered', 'rejected', '2019-01-20 17:05:50'),
(50, 'registered', 'rejected', '2019-01-20 17:07:13');

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `productID` int(11) NOT NULL,
  `productName` varchar(200) DEFAULT NULL,
  `shopID` int(11) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `productAmount` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`productID`, `productName`, `shopID`, `price`, `discount`, `productAmount`) VALUES
(1, 'apple iphone', 1, 5000, 0, 20),
(2, 'adidas shoes', 4, 400, 0.2, 100),
(3, 'purple sofa', 2, 600, 0.1, 20),
(4, 'wooden table', 4, 550, 0, 5),
(5, 'yamaha piano', 3, 20000, 0.4, 7),
(6, 'dior perfume', 5, 180, 0.1, 10),
(7, 'europen box', 4, 80, 0.35, 20);

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule` (
  `shopID` int(11) DEFAULT NULL,
  `openTime` time DEFAULT NULL,
  `closeTime` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `schedule`
--

INSERT INTO `schedule` (`shopID`, `openTime`, `closeTime`) VALUES
(1, '07:00:00', '21:00:00'),
(2, '09:15:00', '22:30:00'),
(3, '12:00:00', '19:00:00'),
(4, '15:30:00', '23:00:00'),
(5, '09:30:00', '20:30:00');

-- --------------------------------------------------------

--
-- Table structure for table `shops`
--

CREATE TABLE `shops` (
  `ShopID` int(11) NOT NULL,
  `ShopName` varchar(200) DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL,
  `Address` varchar(500) DEFAULT NULL,
  `PhoneNum` varchar(30) DEFAULT NULL,
  `Manager` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shops`
--

INSERT INTO `shops` (`ShopID`, `ShopName`, `City`, `Address`, `PhoneNum`, `Manager`) VALUES
(1, 'bestmarket', 'mashhad', 'first Ave.', '22345589', 'karimi'),
(2, 'elecmarket', 'tehran', 'valiasr st.', '88765567', 'aghayi'),
(3, 'beheshtmall', 'Isfahan', 'chaharbagh', '66569987', 'rasuli'),
(4, 'tehranmall', 'tehran', 'vanak', '88679908', 'mohammadi'),
(5, 'shahrakmarket', 'tabriz', 'main Ave. second alley', '55458899', 'ahmadi');

-- --------------------------------------------------------

--
-- Table structure for table `supporters`
--

CREATE TABLE `supporters` (
  `SupID` int(11) NOT NULL,
  `SupName` varchar(200) DEFAULT NULL,
  `SupLastName` varchar(200) DEFAULT NULL,
  `Address` varchar(500) DEFAULT NULL,
  `PhoneNum` varchar(30) DEFAULT NULL,
  `ShopID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `supporters`
--

INSERT INTO `supporters` (`SupID`, `SupName`, `SupLastName`, `Address`, `PhoneNum`, `ShopID`) VALUES
(1, 'Mohsen', 'Ebadi', 'fifth Avenue', '09123345667', 1),
(2, 'Reza', 'Ahadi', '4th alley', '09123378669', 3),
(3, 'Mahsa', 'Keshvari', 'khashani street', '09156677843', 3),
(4, 'Maryam', 'Moghadam', 'jahani street', '09165567889', 4),
(5, 'Kosar', 'Kashi', 'ebad street', '88776545', 5),
(6, 'Sharare', 'nouri', 'ok town', '09165544987', 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `couriers`
--
ALTER TABLE `couriers`
  ADD PRIMARY KEY (`CoID`),
  ADD KEY `ShopID` (`ShopID`);

--
-- Indexes for table `courierstatus_logs`
--
ALTER TABLE `courierstatus_logs`
  ADD KEY `CoID` (`CoID`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customerID`);

--
-- Indexes for table `customercredit_logs`
--
ALTER TABLE `customercredit_logs`
  ADD KEY `customerID` (`customerID`);

--
-- Indexes for table `customer_address`
--
ALTER TABLE `customer_address`
  ADD KEY `customerID` (`customerID`);

--
-- Indexes for table `customer_phone`
--
ALTER TABLE `customer_phone`
  ADD KEY `customerID` (`customerID`);

--
-- Indexes for table `operators`
--
ALTER TABLE `operators`
  ADD PRIMARY KEY (`OpID`),
  ADD KEY `ShopID` (`ShopID`);

--
-- Indexes for table `orderproduct`
--
ALTER TABLE `orderproduct`
  ADD KEY `orderID` (`orderID`),
  ADD KEY `productID` (`productID`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`orderID`),
  ADD KEY `shopID` (`shopID`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`productID`),
  ADD KEY `shopID` (`shopID`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
  ADD KEY `shID` (`shopID`);

--
-- Indexes for table `shops`
--
ALTER TABLE `shops`
  ADD PRIMARY KEY (`ShopID`);

--
-- Indexes for table `supporters`
--
ALTER TABLE `supporters`
  ADD PRIMARY KEY (`SupID`),
  ADD KEY `ShopID` (`ShopID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `couriers`
--
ALTER TABLE `couriers`
  MODIFY `CoID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `operators`
--
ALTER TABLE `operators`
  MODIFY `OpID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `orderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `productID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `shops`
--
ALTER TABLE `shops`
  MODIFY `ShopID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `supporters`
--
ALTER TABLE `supporters`
  MODIFY `SupID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `couriers`
--
ALTER TABLE `couriers`
  ADD CONSTRAINT `couriers_ibfk_1` FOREIGN KEY (`ShopID`) REFERENCES `shops` (`ShopID`);

--
-- Constraints for table `courierstatus_logs`
--
ALTER TABLE `courierstatus_logs`
  ADD CONSTRAINT `courierstatus_logs_ibfk_1` FOREIGN KEY (`CoID`) REFERENCES `couriers` (`CoID`);

--
-- Constraints for table `customercredit_logs`
--
ALTER TABLE `customercredit_logs`
  ADD CONSTRAINT `customercredit_logs_ibfk_1` FOREIGN KEY (`customerID`) REFERENCES `customer` (`customerID`);

--
-- Constraints for table `customer_address`
--
ALTER TABLE `customer_address`
  ADD CONSTRAINT `customer_address_ibfk_1` FOREIGN KEY (`customerID`) REFERENCES `customer` (`customerID`);

--
-- Constraints for table `customer_phone`
--
ALTER TABLE `customer_phone`
  ADD CONSTRAINT `customer_phone_ibfk_1` FOREIGN KEY (`customerID`) REFERENCES `customer` (`customerID`);

--
-- Constraints for table `operators`
--
ALTER TABLE `operators`
  ADD CONSTRAINT `operators_ibfk_1` FOREIGN KEY (`ShopID`) REFERENCES `shops` (`ShopID`);

--
-- Constraints for table `orderproduct`
--
ALTER TABLE `orderproduct`
  ADD CONSTRAINT `orderproduct_ibfk_1` FOREIGN KEY (`orderID`) REFERENCES `orders` (`orderID`),
  ADD CONSTRAINT `orderproduct_ibfk_2` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`shopID`) REFERENCES `shops` (`ShopID`);

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`shopID`) REFERENCES `shops` (`ShopID`);

--
-- Constraints for table `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `schedule_ibfk_1` FOREIGN KEY (`shopID`) REFERENCES `shops` (`ShopID`) ON DELETE CASCADE;

--
-- Constraints for table `supporters`
--
ALTER TABLE `supporters`
  ADD CONSTRAINT `supporters_ibfk_1` FOREIGN KEY (`ShopID`) REFERENCES `shops` (`ShopID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
