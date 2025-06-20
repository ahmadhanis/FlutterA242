-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 20, 2025 at 06:24 AM
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
(1, '7', 'Rare Tshirt Metalica', 'Use but rarely wear', 'New', 1, 250, 'Pickup', '2025-05-19 14:11:21.367790'),
(2, '5', 'Used TV', '1 year old 32 inch tv', 'Used', 1, 350, 'Pickup', '2025-05-22 11:12:45.571700'),
(3, '2', '2 person sofa', '2 years old stil good condition', 'Used', 1, 150, 'Pickup', '2025-05-22 11:13:35.569325'),
(5, '6', 'Shoe Rack', 'Used like new', 'Used', 1, 25, 'Pickup', '2025-05-22 11:34:27.565580'),
(6, '4', 'Used Stove', 'Used but stil in working condition', 'Used', 1, 550, 'Pickup', '2025-05-22 11:45:32.364157'),
(7, '9', 'Dining Set', 'Old Dining set to letgo', 'Used', 1, 250, 'Pickup', '2025-05-22 11:49:43.379840'),
(8, '2', '2 Door fridge', '5 years old fridge', 'Used', 1, 300, 'Pickup', '2025-05-22 11:56:29.381489'),
(9, '8', 'Hood', 'Used', 'Damaged', 1, 100, 'Postage', '2025-05-22 14:11:50.738612'),
(10, '6', 'Dog statue', 'very ancient', 'Used', 1, 500, 'Postage', '2025-05-22 14:16:01.031471'),
(11, '1', 'Bluetooth Speaker', 'High quality wireless speaker with bass boost.', 'New', 10, 89.9, 'Postage', '2025-06-20 09:35:08.716711'),
(12, '9', 'Office Chair', 'Ergonomic mesh back office chair.', 'Used', 2, 120, 'Pickup', '2025-06-20 09:35:08.716711'),
(13, '3', 'Smartphone Case', 'Shockproof silicone case for Android.', 'New', 15, 19.9, 'Postage', '2025-06-20 09:35:08.716711'),
(14, '10', 'LED Monitor 24 inch', 'Full HD LED monitor with HDMI input.', 'Refurbishe', 3, 299, 'Pickup', '2025-06-20 09:35:08.716711'),
(15, '7', 'Headphones', 'Wired over-ear noise-cancelling headphones.', 'Damaged', 1, 35, 'Postage', '2025-06-20 09:35:08.716711'),
(16, '5', 'Study Desk', 'Wooden desk with drawers and cable management.', 'Used', 1, 150, 'Pickup', '2025-06-20 09:35:08.716711'),
(17, '4', 'Wireless Mouse', '2.4GHz optical mouse with USB dongle.', 'New', 20, 29, 'Postage', '2025-06-20 09:35:08.716711'),
(18, '8', 'Keyboard', 'Mechanical RGB keyboard.', 'New', 5, 150, 'Postage', '2025-06-20 09:35:08.716711'),
(19, '10', 'Printer', 'Inkjet printer with wireless printing feature.', 'Refurbishe', 2, 230, 'Pickup', '2025-06-20 09:35:08.716711'),
(20, '3', 'Lamp', 'Adjustable LED study lamp.', 'New', 8, 45, 'Postage', '2025-06-20 09:35:08.716711'),
(21, '5', 'Bookshelf', '5-tier wooden bookshelf.', 'Used', 1, 80, 'Pickup', '2025-06-20 09:35:08.716711'),
(22, '9', 'USB Flash Drive', '32GB USB 3.0 drive.', 'New', 25, 25, 'Postage', '2025-06-20 09:35:08.716711'),
(23, '1', 'Laptop Bag', 'Water-resistant backpack for laptops up to 15.6”.', 'New', 12, 65, 'Postage', '2025-06-20 09:35:08.716711'),
(24, '4', 'Router', 'Dual band Wi-Fi router.', 'Refurbishe', 3, 99, 'Postage', '2025-06-20 09:35:08.716711'),
(25, '6', 'Gaming Chair', 'Reclining chair with lumbar support.', 'Used', 1, 250, 'Pickup', '2025-06-20 09:35:08.716711'),
(26, '8', 'Fan', 'Portable USB-powered fan.', 'New', 10, 15, 'Postage', '2025-06-20 09:35:08.716711'),
(27, '7', 'Whiteboard', 'Magnetic dry-erase whiteboard.', 'Damaged', 1, 40, 'Pickup', '2025-06-20 09:35:08.716711'),
(28, '2', 'Projector', 'Mini portable projector for presentations.', 'Refurbishe', 2, 320, 'Pickup', '2025-06-20 09:35:08.716711'),
(29, '5', 'Extension Cord', '4-socket surge protector.', 'New', 10, 18, 'Postage', '2025-06-20 09:35:08.716711'),
(30, '10', 'Table Clock', 'Analog clock with alarm.', 'Used', 4, 22, 'Postage', '2025-06-20 09:35:08.716711');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_messages`
--

CREATE TABLE `tbl_messages` (
  `message_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `reply_to` int(11) DEFAULT NULL,
  `sent_time` datetime DEFAULT current_timestamp(),
  `is_read` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_messages`
--

INSERT INTO `tbl_messages` (`message_id`, `sender_id`, `receiver_id`, `message`, `attachment_url`, `reply_to`, `sent_time`, `is_read`) VALUES
(1, 2, 10, 'Enquiry for product: LED Monitor 24 inch\n\nThis item still available?', NULL, NULL, '2025-06-20 10:44:49', 1),
(2, 10, 2, 'Enquiry for product: \n\nyes still available', NULL, NULL, '2025-06-20 10:52:10', 0),
(3, 10, 2, '\n\nmeetup?', NULL, NULL, '2025-06-20 10:53:38', 1),
(4, 2, 10, 'Printer\n\nHi is this new?', NULL, NULL, '2025-06-20 11:44:05', 1),
(5, 2, 3, 'Lamp\n\nNew or old', NULL, NULL, '2025-06-20 11:44:27', 1);

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
(2, 'Ahmad Hanis', 'slumberjer@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0195929107', 'UUM', 'Sintok', '2025-05-15 13:11:34.296275'),
(3, 'Ali', 'ali@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '01947554443', 'UMS', 'Samarahan', '2025-05-15 13:12:24.530083'),
(4, 'Abu', 'abu@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0194755555', 'UTM', 'Skudai', '2025-05-15 13:16:12.234566'),
(5, 'Ahmad Faiz', 'faiz.ahmad@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0123456789', 'UUM', 'No 12, Taman Maju, Jitra, Kedah', '2025-06-20 09:49:34.043598'),
(6, 'Nur Aisyah', 'aisyah.nur@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0112345678', 'USM', '45 Jalan Sentosa, Georgetown, Pulau Pinang', '2025-06-20 09:49:34.043598'),
(7, 'Muhammad Amir', 'amir.muhd@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0198765432', 'UM', '89 Taman Bukit, Bangsar, Kuala Lumpur', '2025-06-20 09:49:34.043598'),
(8, 'Siti Zulaikha', 'zulaikha.siti@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0173332211', 'UPM', '21 Lorong Angsana, Serdang, Selangor', '2025-06-20 09:49:34.043598'),
(9, 'Muhammad Hafiz', 'hafiz.mhd@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0139988776', 'UITM', '7 Jalan Kemboja, Seksyen 7, Shah Alam', '2025-06-20 09:49:34.043598'),
(10, 'Ainul Mardhiah', 'ainul.m@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0162323232', 'UKM', '33 Taman Impian, Bangi, Selangor', '2025-06-20 09:49:34.043598'),
(11, 'Mohd Danish', 'danish.mohd@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0187878787', 'UIA', '56 Jalan Damai, Gombak, Selangor', '2025-06-20 09:49:34.043598'),
(12, 'Nurul Huda', 'huda.nurul@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0141212121', 'UTM', '99 Taman Skudai, Johor Bahru, Johor', '2025-06-20 09:49:34.043598'),
(13, 'Adam Harith', 'adam.harith@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0191010101', 'UNIMAS', '65 Jalan Matang, Kuching, Sarawak', '2025-06-20 09:49:34.043598'),
(14, 'Alya Batrisyia', 'alya.batrisyia@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0129898989', 'UNIMAP', '13 Taman Perlis Indah, Arau, Perlis', '2025-06-20 09:49:34.043598'),
(15, 'Mohamad Iqbal', 'iqbal.m@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0177774444', 'UTHM', '23 Jalan Universiti, Batu Pahat, Johor', '2025-06-20 09:49:34.043598'),
(16, 'Amirah Sofea', 'amirah.s@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0181818181', 'UCSI', '31 Jalan Cheras, Kuala Lumpur', '2025-06-20 09:49:34.043598'),
(17, 'Mohd Zikri', 'zikri.m@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0131313131', 'MMU', '52 Jalan Cyber 5, Cyberjaya, Selangor', '2025-06-20 09:49:34.043598'),
(18, 'Fatimah Zahra', 'fatimah.z@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0192929292', 'MSU', '66 Jalan Kristal, Seksyen 7, Shah Alam', '2025-06-20 09:49:34.043598'),
(19, 'Mohd Arif', 'arif.m@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0122323232', 'INTI', '40 Taman Bukit, Nilai, Negeri Sembilan', '2025-06-20 09:49:34.043598'),
(20, 'Balqis Imani', 'balqis.i@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0171234567', 'HELP', '55 Jalan Damansara, Kuala Lumpur', '2025-06-20 09:49:34.043598'),
(21, 'Aiman Syahmi', 'aiman.syahmi@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0193232323', 'TAYLORS', '71 Persiaran Subang, Subang Jaya, Selangor', '2025-06-20 09:49:34.043598'),
(22, 'Nurin Afiqah', 'nurin.afiqah@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0185656565', 'SEGI', '88 Jalan Teknologi, Kota Damansara, Selangor', '2025-06-20 09:49:34.043598'),
(23, 'Hakim Azhar', 'hakim.azhar@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0147878787', 'KDU', '18 Lorong Gurney, George Town, Pulau Pinang', '2025-06-20 09:49:34.043598'),
(24, 'Sabrina Alia', 'sabrina.alia@email.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0166767676', 'UM', '91 Taman Tun Dr Ismail, Kuala Lumpur', '2025-06-20 09:49:34.043598');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_items`
--
ALTER TABLE `tbl_items`
  ADD PRIMARY KEY (`item_id`);

--
-- Indexes for table `tbl_messages`
--
ALTER TABLE `tbl_messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `receiver_id` (`receiver_id`),
  ADD KEY `reply_to` (`reply_to`);

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
  MODIFY `item_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `tbl_messages`
--
ALTER TABLE `tbl_messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_messages`
--
ALTER TABLE `tbl_messages`
  ADD CONSTRAINT `tbl_messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `tbl_users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tbl_messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `tbl_users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tbl_messages_ibfk_3` FOREIGN KEY (`reply_to`) REFERENCES `tbl_messages` (`message_id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
