-- MySQL dump 10.16  Distrib 10.1.29-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: lincomp_dev
-- ------------------------------------------------------
-- Server version	10.1.29-MariaDB-6ubuntu2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `firstname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lastname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `postalcode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `index_addresses_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=579 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_addresses`
--

DROP TABLE IF EXISTS `admin_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_orders`
--

DROP TABLE IF EXISTS `admin_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `file` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26673 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `carts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_carts_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22009669 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `lft` int(11) DEFAULT NULL,
  `rgt` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_categories_on_parent_id` (`parent_id`),
  KEY `index_categories_on_lft` (`lft`),
  KEY `index_categories_on_rgt` (`rgt`)
) ENGINE=InnoDB AUTO_INCREMENT=3145 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories_category_dispatchers`
--

DROP TABLE IF EXISTS `categories_category_dispatchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories_category_dispatchers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `category_dispatcher_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=312 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories_products`
--

DROP TABLE IF EXISTS `categories_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories_products` (
  `category_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  KEY `index_categories_products_on_category_id` (`category_id`),
  KEY `index_categories_products_on_product_id` (`product_id`),
  KEY `cp_pid_cid` (`product_id`,`category_id`),
  KEY `cp_cid_pid` (`category_id`,`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `category_dispatchers`
--

DROP TABLE IF EXISTS `category_dispatchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_dispatchers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level_01` text,
  `level_02` text,
  `level_03` text,
  `supplier_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `category_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_category_dispatchers_on_supplier_id` (`supplier_id`),
  KEY `index_category_dispatchers_on_level_01` (`level_01`(10)),
  KEY `index_category_dispatchers_on_level_02` (`level_02`(10)),
  KEY `index_category_dispatchers_on_level_03` (`level_03`(10))
) ENGINE=InnoDB AUTO_INCREMENT=5875 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ckeditor_assets`
--

DROP TABLE IF EXISTS `ckeditor_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ckeditor_assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_file_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `data_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_file_size` int(11) DEFAULT NULL,
  `assetable_id` int(11) DEFAULT NULL,
  `assetable_type` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(25) COLLATE utf8_unicode_ci DEFAULT NULL,
  `guid` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale` tinyint(4) DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_assetable_type` (`assetable_type`,`type`,`assetable_id`),
  KEY `fk_assetable` (`assetable_type`,`assetable_id`),
  KEY `fk_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `configuration_items`
--

DROP TABLE IF EXISTS `configuration_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configuration_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_configuration_items_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sortorder` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delayed_jobs`
--

DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `queue` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_lines`
--

DROP TABLE IF EXISTS `document_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_lines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quantity` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `note` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cart_id` int(11) DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `old_order_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_lines_on_product_id` (`product_id`),
  KEY `index_document_lines_on_cart_id` (`cart_id`),
  KEY `index_document_lines_on_invoice_id` (`invoice_id`),
  KEY `index_document_lines_on_order_id` (`old_order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2383 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feed_entries`
--

DROP TABLE IF EXISTS `feed_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `content` text,
  `url` varchar(255) DEFAULT NULL,
  `guid` varchar(255) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `histories`
--

DROP TABLE IF EXISTS `histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` text COLLATE utf8_unicode_ci,
  `object_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type_const` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24469 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shipping_address_id` int(11) DEFAULT NULL,
  `shipping_address_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_address_id` int(11) DEFAULT NULL,
  `billing_address_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `status_constant` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shipping_cost` decimal(63,30) DEFAULT NULL,
  `old_order_id` int(11) DEFAULT NULL,
  `payment_method_id` int(11) DEFAULT NULL,
  `document_number` int(11) DEFAULT NULL,
  `autobook` tinyint(1) DEFAULT '1',
  `shipping_taxes` decimal(63,30) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `rebate` decimal(63,30) DEFAULT '0.000000000000000000000000000000',
  `replacement_id` int(11) DEFAULT NULL,
  `reminder_count` int(11) DEFAULT '0',
  `last_reminded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invoices_on_user_id` (`user_id`),
  KEY `index_invoices_on_uuid` (`uuid`),
  KEY `index_invoices_on_order_id` (`old_order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=572 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_configuration_templates`
--

DROP TABLE IF EXISTS `job_configuration_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_configuration_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_class` varchar(255) DEFAULT NULL,
  `job_method` varchar(255) DEFAULT NULL,
  `job_arguments` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_configurations`
--

DROP TABLE IF EXISTS `job_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_configuration_template_id` int(11) DEFAULT NULL,
  `job_repetition_id` int(11) DEFAULT NULL,
  `run_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_repetitions`
--

DROP TABLE IF EXISTS `job_repetitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_repetitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dow` int(11) DEFAULT NULL,
  `dom` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `hour` int(11) DEFAULT NULL,
  `minute` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `links`
--

DROP TABLE IF EXISTS `links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4107 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `margin_ranges`
--

DROP TABLE IF EXISTS `margin_ranges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `margin_ranges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_price` float DEFAULT NULL,
  `end_price` float DEFAULT NULL,
  `margin_percentage` float DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `recalculated_at` datetime DEFAULT NULL,
  `band_minimum` float DEFAULT NULL,
  `band_maximum` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_margin_ranges_on_product_id` (`product_id`),
  KEY `index_margin_ranges_on_supplier_id` (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=720 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `remove_hash` varchar(255) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `numerators`
--

DROP TABLE IF EXISTS `numerators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `numerators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `old_orders`
--

DROP TABLE IF EXISTS `old_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `old_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shipping_address_id` int(11) DEFAULT NULL,
  `billing_address_id` int(11) DEFAULT NULL,
  `shipping_address_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_address_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status_constant` int(11) DEFAULT '1',
  `payment_method_id` int(11) DEFAULT NULL,
  `document_number` int(11) DEFAULT NULL,
  `shipping_carrier_id` int(11) DEFAULT NULL,
  `tracking_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_orders_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shipping_address_id` int(11) DEFAULT NULL,
  `shipping_address_type` varchar(255) DEFAULT NULL,
  `billing_address_id` int(11) DEFAULT NULL,
  `billing_address_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `status_constant` int(11) DEFAULT '1',
  `uuid` varchar(255) DEFAULT NULL,
  `shipping_cost` decimal(63,30) DEFAULT NULL,
  `payment_method_id` int(11) DEFAULT NULL,
  `document_number` int(11) DEFAULT NULL,
  `shipping_taxes` decimal(63,30) DEFAULT NULL,
  `shipping_carrier_id` int(11) DEFAULT NULL,
  `tracking_number` varchar(255) DEFAULT NULL,
  `direct_shipping` tinyint(1) DEFAULT '0',
  `rebate` decimal(63,30) DEFAULT '0.000000000000000000000000000000',
  `estimated_delivery_date` date DEFAULT NULL,
  `auto_cancel` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=567 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `allows_direct_shipping` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `default` tinyint(1) DEFAULT NULL,
  `requires_bank_information` tinyint(1) DEFAULT '1',
  `requires_paypal_information` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_methods_users`
--

DROP TABLE IF EXISTS `payment_methods_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_methods_users` (
  `payment_method_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  KEY `pmu_uid_pmid` (`user_id`,`payment_method_id`),
  KEY `pmu_pmid_uid` (`payment_method_id`,`user_id`),
  KEY `index_payment_methods_users_on_payment_method_id` (`payment_method_id`),
  KEY `index_payment_methods_users_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_pictures`
--

DROP TABLE IF EXISTS `product_pictures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_pictures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_file_size` int(11) DEFAULT NULL,
  `file_updated_at` datetime DEFAULT NULL,
  `is_main_picture` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_product_pictures_on_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=64770 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_sets`
--

DROP TABLE IF EXISTS `product_sets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_sets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quantity` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `component_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_product_sets_on_component_id` (`component_id`),
  KEY `index_product_sets_on_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=470 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `tax_class_id` int(11) DEFAULT NULL,
  `purchase_price` decimal(20,2) DEFAULT '0.00',
  `sales_price` decimal(20,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `direct_shipping` tinyint(1) DEFAULT '1',
  `supplier_product_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stock` int(11) DEFAULT '0',
  `is_available` tinyint(1) DEFAULT '1',
  `supply_item_id` int(11) DEFAULT NULL,
  `manufacturer_product_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `absolute_rebate` decimal(63,30) DEFAULT '0.000000000000000000000000000000',
  `percentage_rebate` decimal(63,30) DEFAULT '0.000000000000000000000000000000',
  `rebate_until` datetime DEFAULT NULL,
  `is_loss_leader` tinyint(1) DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `short_description` text COLLATE utf8_unicode_ci,
  `sale_state` tinyint(1) DEFAULT '0',
  `manufacturer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product_link` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cached_price` decimal(63,30) DEFAULT NULL,
  `cached_taxed_price` decimal(63,30) DEFAULT NULL,
  `auto_updated_at` datetime DEFAULT NULL,
  `rounding_component` decimal(63,30) DEFAULT NULL,
  `is_featured` tinyint(1) DEFAULT NULL,
  `ean_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_visible` tinyint(1) DEFAULT '1',
  `is_description_protected` tinyint(1) DEFAULT '0',
  `is_build_to_order` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_products_on_supply_item_id` (`supply_item_id`),
  KEY `index_products_on_supplier_id` (`supplier_id`),
  KEY `index_products_on_supplier_product_code` (`supplier_product_code`),
  KEY `index_products_on_tax_class_id` (`tax_class_id`),
  KEY `index_products_on_is_featured` (`is_featured`),
  KEY `index_products_on_is_available` (`is_available`),
  KEY `index_products_on_sale_state` (`sale_state`),
  KEY `index_products_on_manufacturer_product_code` (`manufacturer_product_code`),
  KEY `index_products_on_ean_code` (`ean_code`(15)),
  KEY `index_products_on_is_visible` (`is_visible`)
) ENGINE=InnoDB AUTO_INCREMENT=83695 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shipping_calculators`
--

DROP TABLE IF EXISTS `shipping_calculators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shipping_calculators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `configuration` text,
  `type` varchar(255) DEFAULT NULL,
  `tax_class_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shipping_carriers`
--

DROP TABLE IF EXISTS `shipping_carriers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shipping_carriers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `tracking_base_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shipping_costs`
--

DROP TABLE IF EXISTS `shipping_costs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shipping_costs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shipping_rate_id` int(11) DEFAULT NULL,
  `weight_min` int(11) DEFAULT NULL,
  `weight_max` int(11) DEFAULT NULL,
  `price` decimal(63,30) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `tax_class_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_shipping_costs_on_shipping_rate_id` (`shipping_rate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shipping_rates`
--

DROP TABLE IF EXISTS `shipping_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shipping_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `tax_class_id` int(11) DEFAULT NULL,
  `direct_shipping_fees` decimal(63,30) DEFAULT '0.000000000000000000000000000000',
  `default` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `static_document_lines`
--

DROP TABLE IF EXISTS `static_document_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `static_document_lines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quantity` int(11) DEFAULT NULL,
  `text` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `taxes` decimal(63,30) DEFAULT NULL,
  `tax_percentage` decimal(8,2) DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `gross_price` decimal(63,30) DEFAULT NULL,
  `taxed_price` decimal(63,30) DEFAULT NULL,
  `single_price` decimal(63,30) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `manufacturer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `manufacturer_product_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `single_untaxed_price` decimal(63,30) DEFAULT NULL,
  `single_rebate` decimal(63,30) DEFAULT '0.000000000000000000000000000000',
  PRIMARY KEY (`id`),
  KEY `index_invoice_lines_on_invoice_id` (`invoice_id`)
) ENGINE=InnoDB AUTO_INCREMENT=790 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_id` int(11) DEFAULT NULL,
  `shipping_rate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `product_base_url` text COLLATE utf8_unicode_ci,
  `utility_class_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_suppliers_on_shipping_rate_id` (`shipping_rate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `supply_items`
--

DROP TABLE IF EXISTS `supply_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supply_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_product_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `purchase_price` decimal(20,2) DEFAULT '0.00',
  `stock` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `manufacturer_product_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `manufacturer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product_link` text COLLATE utf8_unicode_ci,
  `status_constant` int(11) DEFAULT NULL,
  `image_url` text COLLATE utf8_unicode_ci,
  `pdf_url` text COLLATE utf8_unicode_ci,
  `category01` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category02` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category03` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `workflow_status_constant` int(11) DEFAULT '1',
  `notes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category_string` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description_url` text COLLATE utf8_unicode_ci,
  `ean_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_supply_items_on_supplier_id` (`supplier_id`),
  KEY `index_supply_items_on_supplier_product_code` (`supplier_product_code`),
  KEY `index_supply_items_on_status_constant` (`status_constant`),
  KEY `index_supply_items_on_manufacturer_product_code` (`manufacturer_product_code`),
  KEY `index_supply_items_on_ean_code` (`ean_code`(15))
) ENGINE=InnoDB AUTO_INCREMENT=688040 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_classes`
--

DROP TABLE IF EXISTS `tax_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_classes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `percentage` decimal(8,2) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tracking_codes`
--

DROP TABLE IF EXISTS `tracking_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tracking_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shipping_carrier_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `tracking_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=431 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usergroups`
--

DROP TABLE IF EXISTS `usergroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usergroups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_admin` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usergroups_users`
--

DROP TABLE IF EXISTS `usergroups_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usergroups_users` (
  `usergroup_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `authentication_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB AUTO_INCREMENT=230 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-05-03 15:14:30
INSERT INTO schema_migrations (version) VALUES ('20091210180137');

INSERT INTO schema_migrations (version) VALUES ('20091211090347');

INSERT INTO schema_migrations (version) VALUES ('20091211091409');

INSERT INTO schema_migrations (version) VALUES ('20091212171048');

INSERT INTO schema_migrations (version) VALUES ('20091221123545');

INSERT INTO schema_migrations (version) VALUES ('20091221134033');

INSERT INTO schema_migrations (version) VALUES ('20091224144734');

INSERT INTO schema_migrations (version) VALUES ('20091225112827');

INSERT INTO schema_migrations (version) VALUES ('20091225113135');

INSERT INTO schema_migrations (version) VALUES ('20091225113331');

INSERT INTO schema_migrations (version) VALUES ('20091225114616');

INSERT INTO schema_migrations (version) VALUES ('20091226095739');

INSERT INTO schema_migrations (version) VALUES ('20091226101149');

INSERT INTO schema_migrations (version) VALUES ('20091226101720');

INSERT INTO schema_migrations (version) VALUES ('20091226114340');

INSERT INTO schema_migrations (version) VALUES ('20091228133516');

INSERT INTO schema_migrations (version) VALUES ('20091230092320');

INSERT INTO schema_migrations (version) VALUES ('20091230120810');

INSERT INTO schema_migrations (version) VALUES ('20100101091849');

INSERT INTO schema_migrations (version) VALUES ('20100101100826');

INSERT INTO schema_migrations (version) VALUES ('20100123162601');

INSERT INTO schema_migrations (version) VALUES ('20100206114006');

INSERT INTO schema_migrations (version) VALUES ('20100206153351');

INSERT INTO schema_migrations (version) VALUES ('20100208175330');

INSERT INTO schema_migrations (version) VALUES ('20100208192707');

INSERT INTO schema_migrations (version) VALUES ('20100219120038');

INSERT INTO schema_migrations (version) VALUES ('20100220134354');

INSERT INTO schema_migrations (version) VALUES ('20100220161419');

INSERT INTO schema_migrations (version) VALUES ('20100220163423');

INSERT INTO schema_migrations (version) VALUES ('20100227011649');

INSERT INTO schema_migrations (version) VALUES ('20100227124021');

INSERT INTO schema_migrations (version) VALUES ('20100227131652');

INSERT INTO schema_migrations (version) VALUES ('20100305145204');

INSERT INTO schema_migrations (version) VALUES ('20100310172920');

INSERT INTO schema_migrations (version) VALUES ('20100310194943');

INSERT INTO schema_migrations (version) VALUES ('20100312143051');

INSERT INTO schema_migrations (version) VALUES ('20100313124600');

INSERT INTO schema_migrations (version) VALUES ('20100313134425');

INSERT INTO schema_migrations (version) VALUES ('20100316191641');

INSERT INTO schema_migrations (version) VALUES ('20100320114221');

INSERT INTO schema_migrations (version) VALUES ('20100329175947');

INSERT INTO schema_migrations (version) VALUES ('20100402112427');

INSERT INTO schema_migrations (version) VALUES ('20100412182720');

INSERT INTO schema_migrations (version) VALUES ('20100417143530');

INSERT INTO schema_migrations (version) VALUES ('20100516101346');

INSERT INTO schema_migrations (version) VALUES ('20100517183757');

INSERT INTO schema_migrations (version) VALUES ('20100524072319');

INSERT INTO schema_migrations (version) VALUES ('20100605183115');

INSERT INTO schema_migrations (version) VALUES ('20100619072535');

INSERT INTO schema_migrations (version) VALUES ('20100807092041');

INSERT INTO schema_migrations (version) VALUES ('20100807113907');

INSERT INTO schema_migrations (version) VALUES ('20100817051033');

INSERT INTO schema_migrations (version) VALUES ('20100827050428');

INSERT INTO schema_migrations (version) VALUES ('20100921174741');

INSERT INTO schema_migrations (version) VALUES ('20100923070913');

INSERT INTO schema_migrations (version) VALUES ('20101005135850');

INSERT INTO schema_migrations (version) VALUES ('20101005143009');

INSERT INTO schema_migrations (version) VALUES ('20101023150436');

INSERT INTO schema_migrations (version) VALUES ('20101026052607');

INSERT INTO schema_migrations (version) VALUES ('20101028165748');

INSERT INTO schema_migrations (version) VALUES ('20101104060129');

INSERT INTO schema_migrations (version) VALUES ('20101201181111');

INSERT INTO schema_migrations (version) VALUES ('20101204160642');

INSERT INTO schema_migrations (version) VALUES ('20110105121919');

INSERT INTO schema_migrations (version) VALUES ('20110105132250');

INSERT INTO schema_migrations (version) VALUES ('20110105133304');

INSERT INTO schema_migrations (version) VALUES ('20110106144338');

INSERT INTO schema_migrations (version) VALUES ('20110107141946');

INSERT INTO schema_migrations (version) VALUES ('20110108122939');

INSERT INTO schema_migrations (version) VALUES ('20110110073252');

INSERT INTO schema_migrations (version) VALUES ('20110115123626');

INSERT INTO schema_migrations (version) VALUES ('20110119091329');

INSERT INTO schema_migrations (version) VALUES ('20110123143256');

INSERT INTO schema_migrations (version) VALUES ('20110129104710');

INSERT INTO schema_migrations (version) VALUES ('20110209162140');

INSERT INTO schema_migrations (version) VALUES ('20110220085906');

INSERT INTO schema_migrations (version) VALUES ('20110220093054');

INSERT INTO schema_migrations (version) VALUES ('20110222083229');

INSERT INTO schema_migrations (version) VALUES ('20110223184704');

INSERT INTO schema_migrations (version) VALUES ('20110228102936');

INSERT INTO schema_migrations (version) VALUES ('20110311150645');

INSERT INTO schema_migrations (version) VALUES ('20110331085646');

INSERT INTO schema_migrations (version) VALUES ('20110331093859');

INSERT INTO schema_migrations (version) VALUES ('20110331110830');

INSERT INTO schema_migrations (version) VALUES ('20110403082820');

INSERT INTO schema_migrations (version) VALUES ('20110403122139');

INSERT INTO schema_migrations (version) VALUES ('20110403134239');

INSERT INTO schema_migrations (version) VALUES ('20110408080355');

INSERT INTO schema_migrations (version) VALUES ('20110408085008');

INSERT INTO schema_migrations (version) VALUES ('20110408085737');

INSERT INTO schema_migrations (version) VALUES ('20110408152842');

INSERT INTO schema_migrations (version) VALUES ('20110415131644');

INSERT INTO schema_migrations (version) VALUES ('20110421101050');

INSERT INTO schema_migrations (version) VALUES ('20110426141152');

INSERT INTO schema_migrations (version) VALUES ('20110428152839');

INSERT INTO schema_migrations (version) VALUES ('20110429062614');

INSERT INTO schema_migrations (version) VALUES ('20110429123640');

INSERT INTO schema_migrations (version) VALUES ('20110504124626');

INSERT INTO schema_migrations (version) VALUES ('20110505143820');

INSERT INTO schema_migrations (version) VALUES ('20110530100849');

INSERT INTO schema_migrations (version) VALUES ('20110530151330');

INSERT INTO schema_migrations (version) VALUES ('20110601122150');

INSERT INTO schema_migrations (version) VALUES ('20110614104753');

INSERT INTO schema_migrations (version) VALUES ('20110623142453');

INSERT INTO schema_migrations (version) VALUES ('20110629090258');

INSERT INTO schema_migrations (version) VALUES ('20110727080334');

INSERT INTO schema_migrations (version) VALUES ('20111126163755');

INSERT INTO schema_migrations (version) VALUES ('20111212192312');

INSERT INTO schema_migrations (version) VALUES ('20111212200018');

INSERT INTO schema_migrations (version) VALUES ('20120102131744');

INSERT INTO schema_migrations (version) VALUES ('20120219133317');

INSERT INTO schema_migrations (version) VALUES ('20120318074906');

INSERT INTO schema_migrations (version) VALUES ('20120406111438');

INSERT INTO schema_migrations (version) VALUES ('20120428073124');

INSERT INTO schema_migrations (version) VALUES ('20120428120059');

INSERT INTO schema_migrations (version) VALUES ('20120505134420');

INSERT INTO schema_migrations (version) VALUES ('20120506101753');

INSERT INTO schema_migrations (version) VALUES ('20120513102356');

INSERT INTO schema_migrations (version) VALUES ('20120515151043');

INSERT INTO schema_migrations (version) VALUES ('20120517165054');

INSERT INTO schema_migrations (version) VALUES ('20120518120739');

INSERT INTO schema_migrations (version) VALUES ('20120524084134');

INSERT INTO schema_migrations (version) VALUES ('20120601161204');

INSERT INTO schema_migrations (version) VALUES ('20120603095024');

INSERT INTO schema_migrations (version) VALUES ('20120613170227');

INSERT INTO schema_migrations (version) VALUES ('20120613170454');

INSERT INTO schema_migrations (version) VALUES ('20120613170722');

INSERT INTO schema_migrations (version) VALUES ('20120623081316');

INSERT INTO schema_migrations (version) VALUES ('20120824094604');

INSERT INTO schema_migrations (version) VALUES ('20120922210630');

INSERT INTO schema_migrations (version) VALUES ('20120929185807');

INSERT INTO schema_migrations (version) VALUES ('20121001193150');

INSERT INTO schema_migrations (version) VALUES ('20121001193650');

INSERT INTO schema_migrations (version) VALUES ('20121010124827');

INSERT INTO schema_migrations (version) VALUES ('20121010130433');

INSERT INTO schema_migrations (version) VALUES ('20121021104815');

INSERT INTO schema_migrations (version) VALUES ('20121021120804');

INSERT INTO schema_migrations (version) VALUES ('20121021131442');

INSERT INTO schema_migrations (version) VALUES ('20121114184206');

INSERT INTO schema_migrations (version) VALUES ('20121125120119');

INSERT INTO schema_migrations (version) VALUES ('20130216094514');

INSERT INTO schema_migrations (version) VALUES ('20130302112938');

INSERT INTO schema_migrations (version) VALUES ('20130503074843');

INSERT INTO schema_migrations (version) VALUES ('20130503075604');

INSERT INTO schema_migrations (version) VALUES ('20130510100444');

INSERT INTO schema_migrations (version) VALUES ('20140523100537');

INSERT INTO schema_migrations (version) VALUES ('20190210105659');

INSERT INTO schema_migrations (version) VALUES ('20190503124033');

