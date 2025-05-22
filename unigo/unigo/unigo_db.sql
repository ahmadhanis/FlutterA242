-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 22, 2025 at 09:11 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `unigo_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_items`
--

CREATE TABLE `tbl_items` (
  `item_id` int(5) NOT NULL,
  `user_id` varchar(5) NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `item_desc` varchar(500) NOT NULL,
  `item_status` varchar(10) NOT NULL,
  `item_qty` int(3) NOT NULL,
  `item_price` float NOT NULL,
  `item_delivery` varchar(20) NOT NULL,
  `item_date` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_items`
--

INSERT INTO `tbl_items` (`item_id`, `user_id`, `item_name`, `item_desc`, `item_status`, `item_qty`, `item_price`, `item_delivery`, `item_date`) VALUES
(1, '2', 'Rare Tshirt Metalica', 'Use but rarely wear', 'New', 1, 250, 'Pickup', '2025-05-19 14:11:21.367790'),
(2, '2', 'Used TV', '1 year old 32 inch tv', 'Used', 1, 350, 'Pickup', '2025-05-22 11:12:45.571700'),
(3, '2', '2 person sofa', '2 years old stil good condition', 'Used', 1, 150, 'Pickup', '2025-05-22 11:13:35.569325'),
(4, '2', 'Coffee Table', 'Used 2 years', 'Used', 1, 25, 'Pickup', '2025-05-22 11:33:12.699932'),
(5, '2', 'Shoe Rack', 'Used like new', 'Used', 1, 25, 'Pickup', '2025-05-22 11:34:27.565580'),
(6, '3', 'Used Stove', 'Used but stil in working condition', 'Used', 1, 550, 'Pickup', '2025-05-22 11:45:32.364157'),
(7, '3', 'Dining Set', 'Old Dining set to letgo', 'Used', 1, 250, 'Pickup', '2025-05-22 11:49:43.379840'),
(8, '4', '2 Door fridge', '5 years old fridge', 'Used', 1, 300, 'Pickup', '2025-05-22 11:56:29.381489'),
(9, '2', 'Hood', 'Used', 'Used', 1, 100, 'Postage', '2025-05-22 14:11:50.738612'),
(10, '2', 'Dog statue', 'very ancient', 'Used', 1, 500, 'Postage', '2025-05-22 14:16:01.031471');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `user_id` int(5) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `user_email` varchar(50) NOT NULL,
  `user_password` varchar(40) NOT NULL,
  `user_phone` varchar(20) NOT NULL,
  `user_university` varchar(50) NOT NULL,
  `user_address` varchar(300) NOT NULL,
  `user_datereg` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_users`
--

INSERT INTO `tbl_users` (`user_id`, `user_name`, `user_email`, `user_password`, `user_phone`, `user_university`, `user_address`, `user_datereg`) VALUES
(2, 'Ahmad Hanis', 'slumberjer@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0194702493', 'UUM', 'Sintok', '2025-05-15 13:11:34.296275'),
(3, 'Ali', 'ali@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '01947554443', 'UMS', 'Samarahan', '2025-05-15 13:12:24.530083'),
(4, 'Abu', 'abu@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0194755555', 'UTM', 'Skudai', '2025-05-15 13:16:12.234566');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_items`
--
ALTER TABLE `tbl_items`
  ADD PRIMARY KEY (`item_id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_items`
--
ALTER TABLE `tbl_items`
  MODIFY `item_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
