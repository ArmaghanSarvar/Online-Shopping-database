-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 16, 2019 at 03:50 PM
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

-- --------------------------------------------------------

--
-- Table structure for table `couriers`
--

CREATE TABLE `couriers` (
  `CoID` int(11) NOT NULL,
  `CoName` varchar(200) DEFAULT NULL,
  `CoLastName` varchar(200) DEFAULT NULL,
  `PhoneNum` varchar(30) DEFAULT NULL,
  `Credit` int(11) DEFAULT NULL,
  `Status` varchar(100) DEFAULT NULL,
  `ShopID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `couriers`
--

INSERT INTO `couriers` (`CoID`, `CoName`, `CoLastName`, `PhoneNum`, `Credit`, `Status`, `ShopID`) VALUES
(1, 'Asghar', 'Asghari', '09176654887', 5000, 'free', 2),
(2, 'Akbar', 'Akbari', '09187766543', 3000, 'busy', 1),
(3, 'Javad', 'Javadi', '09143377898', 9000, 'free', 5),
(4, 'Karim', 'Karimi', '09123344890', 4500, 'busy', 3),
(5, 'Rahman', 'Rahmani', '09176655456', 98888, 'busy', 4),
(6, 'Bagher', 'Bagheri', '09138877678', 22998, 'free', 5);

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
  `postalCode` varchar(100) DEFAULT NULL,
  `sex` varchar(30) DEFAULT NULL,
  `accountBalance` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customerID`, `loginPass`, `Email`, `customerName`, `customerLastName`, `postalCode`, `sex`, `accountBalance`) VALUES
(1, 'iijuy7', 'akbar@gmail.com', 'akbar', 'javadi', '99887766778899', 'male', 90000),
(2, 'gdufysg67676', 'haghani@yahoo.com', 'mohammad', 'haghani', '55445654653655', 'male', 7866666),
(3, 'sbkufygdj44', 'javadaghdam@gmail.com', 'mozhgan', 'javadiaghdam', '88685463998809', 'female', 33333444),
(4, '7766yhj', 'ghahremani32@gmail.com', 'Marjan', 'Ghahremani', '	', '5544565465365female', 6655878),
(5, 'shaghi77yy', 'akbarim7@yahoo.com', 'shaghayegh', 'akbari', '9998887776783', 'female', 90000),
(6, 'jhjh4343', 'taherfahim@gmail.com', 'taher', 'fahim', '98674522331189', 'male', 100005);

-- --------------------------------------------------------

--
-- Table structure for table `customer_address`
--

CREATE TABLE `customer_address` (
  `Address` varchar(500) DEFAULT NULL,
  `customerID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer_address`
--

INSERT INTO `customer_address` (`Address`, `customerID`) VALUES
('ahangari street', 1),
('kaj avenue', 2),
('kalami square', 3),
('fourth avenue,second alley', 4),
('usef abad', 5),
('vanak', 6),
('ghaem magham', 1),
('karaj first street', 3);

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
('09138899234', 3);

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
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `orderID` int(11) NOT NULL,
  `shopID` int(11) DEFAULT NULL,
  `numOfProduct` int(11) DEFAULT NULL,
  `customerID` int(11) DEFAULT NULL,
  `orderStatus` varchar(100) DEFAULT NULL,
  `payment` varchar(100) DEFAULT NULL,
  `orderDate` date DEFAULT NULL,
  `orderAddress` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`orderID`, `shopID`, `numOfProduct`, `customerID`, `orderStatus`, `payment`, `orderDate`, `orderAddress`) VALUES
(1, 1, 2, 1, 'sent', 'credit card', '2018-10-27', 'ahangari street'),
(2, 4, 1, 2, 'finished', 'bank portal', '2017-04-14', 'kaj avenue'),
(3, 2, 4, 6, 'registered', 'credit card', '2018-09-17', 'vanak'),
(4, 2, 6, 3, 'rejected', 'bank portal', '2018-12-25', 'karaj first street'),
(5, 5, 1, 4, 'finished', 'bank portal', '2018-05-18', 'elahie');

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `productID` int(11) NOT NULL,
  `productName` varchar(200) DEFAULT NULL,
  `shopID` int(11) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `Discount` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`productID`, `productName`, `shopID`, `price`, `Discount`) VALUES
(1, 'apple iphone', 1, 5000, '0.00'),
(2, 'adidas shoes', 2, 400, '0.20'),
(3, 'purple sofa', 2, 600, '0.10'),
(4, 'wooden table', 4, 550, '0.00'),
(5, 'yamaha piano', 3, 8000, '0.40'),
(6, 'dior perfume', 5, 180, '0.10'),
(7, 'europen box', 4, 80, '0.35');

-- --------------------------------------------------------

--
-- Table structure for table `schedules`
--

CREATE TABLE `schedules` (
  `shopID` int(11) DEFAULT NULL,
  `openTime` time DEFAULT NULL,
  `closeTime` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `schedules`
--

INSERT INTO `schedules` (`shopID`, `openTime`, `closeTime`) VALUES
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
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customerID`);

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
-- Indexes for table `schedules`
--
ALTER TABLE `schedules`
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
  MODIFY `customerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `operators`
--
ALTER TABLE `operators`
  MODIFY `OpID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `orderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
-- Constraints for table `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`shopID`) REFERENCES `shops` (`ShopID`) ON DELETE CASCADE;

--
-- Constraints for table `supporters`
--
ALTER TABLE `supporters`
  ADD CONSTRAINT `supporters_ibfk_1` FOREIGN KEY (`ShopID`) REFERENCES `shops` (`ShopID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
