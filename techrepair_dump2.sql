-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: techrepair_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

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
-- Table structure for table `caja_diaria`
--

DROP TABLE IF EXISTS `caja_diaria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_diaria` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha_apertura` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_cierre` timestamp NULL DEFAULT NULL,
  `monto_inicial` decimal(10,2) DEFAULT 0.00,
  `estado` enum('abierta','cerrada') DEFAULT 'abierta',
  `abierta_por` int(11) DEFAULT NULL,
  `cerrada_por` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_diaria`
--

LOCK TABLES `caja_diaria` WRITE;
/*!40000 ALTER TABLE `caja_diaria` DISABLE KEYS */;
INSERT INTO `caja_diaria` VALUES (1,'2026-04-23 23:28:31','2026-04-23 23:51:32',10000.00,'cerrada',13,14),(2,'2026-04-23 23:52:01',NULL,20000.00,'abierta',13,NULL);
/*!40000 ALTER TABLE `caja_diaria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalogo_equipos`
--

DROP TABLE IF EXISTS `catalogo_equipos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalogo_equipos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(50) DEFAULT NULL,
  `marca` varchar(50) DEFAULT NULL,
  `modelo` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `equipo_unico` (`tipo`,`marca`,`modelo`)
) ENGINE=InnoDB AUTO_INCREMENT=221 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalogo_equipos`
--

LOCK TABLES `catalogo_equipos` WRITE;
/*!40000 ALTER TABLE `catalogo_equipos` DISABLE KEYS */;
INSERT INTO `catalogo_equipos` VALUES (167,'Notebook','Acer','Aspire 5'),(184,'Notebook','Acer','Iphone 14'),(168,'Notebook','Acer','Nitro 5 (Gamer)'),(164,'Notebook','Apple','MacBook Air M1'),(165,'Notebook','Apple','MacBook Air M2'),(166,'Notebook','Apple','MacBook Pro M3'),(169,'Notebook','ASUS','VivoBook 15'),(160,'Notebook','Dell','Inspiration 3500'),(161,'Notebook','Dell','Latitude 5420'),(158,'Notebook','HP','Laptop 15-dw'),(159,'Notebook','HP','Pavilion x360'),(162,'Notebook','Lenovo','IdeaPad 3'),(163,'Notebook','Lenovo','ThinkPad E14'),(149,'Tablet','Apple','iPad 10th Gen'),(148,'Tablet','Apple','iPad 9th Gen'),(150,'Tablet','Apple','iPad Air 5'),(151,'Tablet','Apple','iPad Pro M2'),(157,'Tablet','Huawei','MatePad 11'),(156,'Tablet','Lenovo','Tab P11 Gen 2'),(152,'Tablet','Samsung','Galaxy Tab A7 Lite'),(153,'Tablet','Samsung','Galaxy Tab A8'),(154,'Tablet','Samsung','Galaxy Tab S8'),(155,'Tablet','Samsung','Galaxy Tab S9 FE'),(92,'Teléfono','Apple','iPhone 11'),(93,'Teléfono','Apple','iPhone 11 Pro Max'),(94,'Teléfono','Apple','iPhone 12'),(95,'Teléfono','Apple','iPhone 12 Pro Max'),(96,'Teléfono','Apple','iPhone 13'),(97,'Teléfono','Apple','iPhone 13 Pro Max'),(98,'Teléfono','Apple','iPhone 14'),(99,'Teléfono','Apple','iPhone 14 Pro Max'),(100,'Teléfono','Apple','iPhone 15'),(101,'Teléfono','Apple','iPhone 15 Pro Max'),(102,'Teléfono','Apple','iPhone SE (2022)'),(140,'Teléfono','Huawei','Nova 11i'),(139,'Teléfono','Huawei','Nova 9'),(137,'Teléfono','Huawei','P30 Lite'),(138,'Teléfono','Huawei','P40 Pro'),(141,'Teléfono','Huawei','Y9 Prime'),(125,'Teléfono','Motorola','Edge 30 Pro'),(126,'Teléfono','Motorola','Edge 40 Neo'),(123,'Teléfono','Motorola','Moto E20'),(124,'Teléfono','Motorola','Moto E40'),(118,'Teléfono','Motorola','Moto G22'),(119,'Teléfono','Motorola','Moto G31'),(120,'Teléfono','Motorola','Moto G42'),(121,'Teléfono','Motorola','Moto G52'),(122,'Teléfono','Motorola','Moto G82'),(146,'Teléfono','OPPO','A17'),(147,'Teléfono','OPPO','A57'),(145,'Teléfono','OPPO','Reno 10'),(144,'Teléfono','OPPO','Reno 7'),(103,'Teléfono','Samsung','Galaxy A03'),(104,'Teléfono','Samsung','Galaxy A13 4G'),(105,'Teléfono','Samsung','Galaxy A13 5G'),(106,'Teléfono','Samsung','Galaxy A21s'),(107,'Teléfono','Samsung','Galaxy A32'),(108,'Teléfono','Samsung','Galaxy A52'),(109,'Teléfono','Samsung','Galaxy A54 5G'),(115,'Teléfono','Samsung','Galaxy M12'),(116,'Teléfono','Samsung','Galaxy M23 5G'),(117,'Teléfono','Samsung','Galaxy Note 20 Ultra'),(110,'Teléfono','Samsung','Galaxy S20 FE'),(111,'Teléfono','Samsung','Galaxy S21 Ultra'),(112,'Teléfono','Samsung','Galaxy S22'),(113,'Teléfono','Samsung','Galaxy S23 Ultra'),(114,'Teléfono','Samsung','Galaxy S24 Ultra'),(135,'Teléfono','Xiaomi','Poco F5'),(133,'Teléfono','Xiaomi','Poco X3 Pro'),(134,'Teléfono','Xiaomi','Poco X5 5G'),(131,'Teléfono','Xiaomi','Redmi 10C'),(132,'Teléfono','Xiaomi','Redmi 12'),(127,'Teléfono','Xiaomi','Redmi Note 10'),(128,'Teléfono','Xiaomi','Redmi Note 11'),(129,'Teléfono','Xiaomi','Redmi Note 12 Pro'),(130,'Teléfono','Xiaomi','Redmi Note 13 Pro+'),(136,'Teléfono','Xiaomi','Xiaomi 13T'),(143,'Teléfono','ZTE','Blade A52'),(142,'Teléfono','ZTE','Blade V40'),(178,'TV','Hisense','U6 Series'),(171,'TV','LG','OLED C2 55'),(170,'TV','LG','UHD 4K 50 pulgadas'),(172,'TV','Samsung','Crystal UHD AU7000'),(174,'TV','Samsung','Neo QLED'),(173,'TV','Samsung','QLED Q60B'),(175,'TV','Sony','Bravia XR'),(177,'TV','TCL','Google TV Serie P'),(176,'TV','Xiaomi','Mi TV P1');
/*!40000 ALTER TABLE `catalogo_equipos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizaciones`
--

DROP TABLE IF EXISTS `cotizaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cotizaciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) NOT NULL,
  `cliente_nombre` varchar(255) NOT NULL,
  `cliente_telefono` varchar(50) DEFAULT NULL,
  `equipo` varchar(255) NOT NULL,
  `falla_descripcion` text DEFAULT NULL,
  `valor_estimado` decimal(10,2) NOT NULL,
  `fecha_emision` timestamp NOT NULL DEFAULT current_timestamp(),
  `creado_por` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizaciones`
--

LOCK TABLES `cotizaciones` WRITE;
/*!40000 ALTER TABLE `cotizaciones` DISABLE KEYS */;
INSERT INTO `cotizaciones` VALUES (1,'COT-2026-752','gabriela moscoso','+56937658841','iphone 12','pantalla de ihpne 12 mala ',123333.00,'2026-04-23 23:25:51',14),(2,'COT-2026-662','brandon meliao','+56937658841','iphone 12','cdvc',3444.00,'2026-04-23 23:44:38',14);
/*!40000 ALTER TABLE `cotizaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entregas`
--

DROP TABLE IF EXISTS `entregas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entregas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `orden_id` int(11) DEFAULT NULL,
  `quien_retira` varchar(255) DEFAULT NULL,
  `metodo_pago` varchar(50) DEFAULT NULL,
  `fecha_entrega` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entregas`
--

LOCK TABLES `entregas` WRITE;
/*!40000 ALTER TABLE `entregas` DISABLE KEYS */;
INSERT INTO `entregas` VALUES (1,87,'javier maldonado','Transferencia','2026-04-23 22:25:03'),(2,82,'javier maldonado','Transferencia','2026-04-23 22:26:26'),(3,82,'javier maldonado','Efectivo','2026-04-23 22:28:04');
/*!40000 ALTER TABLE `entregas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fallas_extra`
--

DROP TABLE IF EXISTS `fallas_extra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fallas_extra` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `orden_id` int(11) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `costo` int(11) DEFAULT 0,
  `aceptada` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `orden_id` (`orden_id`),
  CONSTRAINT `fallas_extra_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `ordenes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fallas_extra`
--

LOCK TABLES `fallas_extra` WRITE;
/*!40000 ALTER TABLE `fallas_extra` DISABLE KEYS */;
INSERT INTO `fallas_extra` VALUES (39,37,'Tiene malo el puerto de carga ',22222,NULL),(40,40,'Al abrir el teléfono tenia moco blanco en el parlando desea cambiarlo ',5000,1),(41,40,'Cago el puerto',2000,NULL),(42,40,'Le gusta el pene ',2000,NULL),(46,87,'cago el parlante',7876,1),(47,87,'cago',7677,1);
/*!40000 ALTER TABLE `fallas_extra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fotos`
--

DROP TABLE IF EXISTS `fotos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fotos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `orden_id` int(11) NOT NULL,
  `archivo` varchar(255) DEFAULT NULL,
  `tipo` varchar(30) DEFAULT NULL,
  `subida_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `orden_id` (`orden_id`),
  CONSTRAINT `fotos_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `ordenes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=275 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fotos`
--

LOCK TABLES `fotos` WRITE;
/*!40000 ALTER TABLE `fotos` DISABLE KEYS */;
INSERT INTO `fotos` VALUES (119,37,'1775199739419-453554788.jpg','foto_frontal','2026-04-03 07:02:19'),(120,37,'1775199739420-102798047.jpeg','foto_trasera','2026-04-03 07:02:19'),(121,37,'1775199739421-467280638.jpeg','foto_cargando','2026-04-03 07:02:19'),(122,37,'1775241951662-689237153.jpg','avance','2026-04-03 18:45:51'),(123,38,'1775242876369-18118082.jpg','foto_frontal','2026-04-03 19:01:24'),(124,38,'1775242881510-460714466.jpg','foto_trasera','2026-04-03 19:01:24'),(125,38,'1775242884809-305767926.jpg','foto_cargando','2026-04-03 19:01:24'),(126,39,'1775439836338-262935470.jpg','foto_frontal','2026-04-06 01:44:05'),(127,39,'1775439836756-795432557.jpg','foto_trasera','2026-04-06 01:44:05'),(128,39,'1775439844662-18598026.jpg','foto_cargando','2026-04-06 01:44:05'),(129,40,'1775440032392-529803808.webp','foto_frontal','2026-04-06 01:47:12'),(130,40,'1775440032577-290062812.jpeg','foto_trasera','2026-04-06 01:47:12'),(131,40,'1775440032665-538961800.jpg','foto_cargando','2026-04-06 01:47:12'),(132,40,'1775440290268-566474377.png','avance','2026-04-06 01:51:31'),(133,40,'1775440311233-298947422.png','avance','2026-04-06 01:51:55'),(134,41,'1775846089621-606601725.jpg','foto_frontal','2026-04-10 18:34:49'),(135,41,'1775846089696-714132060.jpg','foto_trasera','2026-04-10 18:34:49'),(136,41,'1775846089706-89038638.jpg','foto_cargando','2026-04-10 18:34:49'),(149,46,'1775850531706-115910870.jpg','foto_frontal','2026-04-10 19:48:51'),(150,46,'1775850531707-502610899.jpg','foto_trasera','2026-04-10 19:48:51'),(151,46,'1775850531707-341992115.jpg','foto_cargando','2026-04-10 19:48:51'),(152,47,'1775850615583-178426606.jpg','foto_frontal','2026-04-10 19:50:15'),(153,47,'1775850615583-890015773.jpg','foto_trasera','2026-04-10 19:50:15'),(154,47,'1775850615583-703038513.jpg','foto_cargando','2026-04-10 19:50:15'),(155,48,'1776225373740-75495506.jpg','foto_frontal','2026-04-15 03:56:22'),(156,48,'1776225381836-187246617.jpg','foto_trasera','2026-04-15 03:56:22'),(157,48,'1776225381837-101769009.jpg','foto_cargando','2026-04-15 03:56:22'),(158,49,'1776296149522-493539770.jpg','foto_frontal','2026-04-15 23:35:50'),(159,49,'1776296149958-869253904.jpg','foto_trasera','2026-04-15 23:35:50'),(160,49,'1776296150144-146345.jpg','foto_cargando','2026-04-15 23:35:50'),(161,50,'1776911402886-696169919.jpg','foto_frontal','2026-04-23 02:30:09'),(162,50,'1776911406131-974464498.jpg','foto_trasera','2026-04-23 02:30:09'),(163,50,'1776911408325-441753199.jpg','foto_cargando','2026-04-23 02:30:09'),(164,51,'1776913726643-511430322.jpg','foto_frontal','2026-04-23 03:08:46'),(165,51,'1776913726643-730852144.url','foto_trasera','2026-04-23 03:08:46'),(166,51,'1776913726643-700342481.jpg','foto_cargando','2026-04-23 03:08:46'),(167,52,'1776913882054-46461083.jpg','foto_frontal','2026-04-23 03:11:22'),(168,52,'1776913882054-294038202.url','foto_trasera','2026-04-23 03:11:22'),(169,52,'1776913882054-69708385.jpg','foto_cargando','2026-04-23 03:11:22'),(170,53,'1776913918357-990173111.jpg','foto_frontal','2026-04-23 03:11:58'),(171,53,'1776913918357-760308954.url','foto_trasera','2026-04-23 03:11:58'),(172,53,'1776913918357-285183962.jpg','foto_cargando','2026-04-23 03:11:58'),(173,54,'1776914199179-594085257.jpg','foto_frontal','2026-04-23 03:16:39'),(174,54,'1776914199179-832624292.jpg','foto_trasera','2026-04-23 03:16:39'),(175,54,'1776914199179-210588035.jpg','foto_cargando','2026-04-23 03:16:39'),(176,55,'1776914855970-16892167.jpg','foto_frontal','2026-04-23 03:27:35'),(177,55,'1776914855970-200972172.jpg','foto_trasera','2026-04-23 03:27:35'),(178,55,'1776914855971-531550020.jpg','foto_cargando','2026-04-23 03:27:35'),(179,56,'1776974037079-470083277.jpg','foto_frontal','2026-04-23 19:53:57'),(180,56,'1776974037080-219111040.jpg','foto_trasera','2026-04-23 19:53:57'),(181,56,'1776974037080-678774229.jpg','foto_cargando','2026-04-23 19:53:57'),(182,57,'1776974059675-292415800.jpg','foto_frontal','2026-04-23 19:54:19'),(183,57,'1776974059675-449649972.jpg','foto_trasera','2026-04-23 19:54:19'),(184,57,'1776974059675-569603998.jpg','foto_cargando','2026-04-23 19:54:19'),(185,58,'1776974213998-988205846.jpg','foto_frontal','2026-04-23 19:56:54'),(186,58,'1776974213998-757559079.jpg','foto_trasera','2026-04-23 19:56:54'),(187,58,'1776974213998-915876250.jpg','foto_cargando','2026-04-23 19:56:54'),(188,59,'1776974214712-617232267.jpg','foto_frontal','2026-04-23 19:56:54'),(189,59,'1776974214712-509873376.jpg','foto_trasera','2026-04-23 19:56:54'),(190,59,'1776974214712-907978768.jpg','foto_cargando','2026-04-23 19:56:54'),(191,60,'1776974215318-783695099.jpg','foto_frontal','2026-04-23 19:56:55'),(192,60,'1776974215319-497162870.jpg','foto_trasera','2026-04-23 19:56:55'),(193,60,'1776974215319-156041093.jpg','foto_cargando','2026-04-23 19:56:55'),(194,61,'1776974215796-767518639.jpg','foto_frontal','2026-04-23 19:56:55'),(195,61,'1776974215796-925076629.jpg','foto_trasera','2026-04-23 19:56:55'),(196,61,'1776974215796-864322181.jpg','foto_cargando','2026-04-23 19:56:55'),(197,62,'1776974216028-890907845.jpg','foto_frontal','2026-04-23 19:56:56'),(198,62,'1776974216028-684429750.jpg','foto_trasera','2026-04-23 19:56:56'),(199,62,'1776974216028-672081578.jpg','foto_cargando','2026-04-23 19:56:56'),(200,63,'1776974216253-67973085.jpg','foto_frontal','2026-04-23 19:56:56'),(201,63,'1776974216253-394108933.jpg','foto_trasera','2026-04-23 19:56:56'),(202,63,'1776974216253-161657019.jpg','foto_cargando','2026-04-23 19:56:56'),(203,64,'1776974216567-60616801.jpg','foto_frontal','2026-04-23 19:56:56'),(204,64,'1776974216567-896707457.jpg','foto_trasera','2026-04-23 19:56:56'),(205,64,'1776974216567-286244588.jpg','foto_cargando','2026-04-23 19:56:56'),(206,65,'1776974216781-988889730.jpg','foto_frontal','2026-04-23 19:56:56'),(207,65,'1776974216781-702576484.jpg','foto_trasera','2026-04-23 19:56:56'),(208,65,'1776974216781-262804395.jpg','foto_cargando','2026-04-23 19:56:56'),(209,66,'1776974217136-556934364.jpg','foto_frontal','2026-04-23 19:56:57'),(210,66,'1776974217136-250696668.jpg','foto_trasera','2026-04-23 19:56:57'),(211,66,'1776974217136-730144555.jpg','foto_cargando','2026-04-23 19:56:57'),(212,67,'1776974217397-114692541.jpg','foto_frontal','2026-04-23 19:56:57'),(213,67,'1776974217398-149956745.jpg','foto_trasera','2026-04-23 19:56:57'),(214,67,'1776974217398-274408995.jpg','foto_cargando','2026-04-23 19:56:57'),(215,68,'1776974217732-845731548.jpg','foto_frontal','2026-04-23 19:56:57'),(216,68,'1776974217732-839920163.jpg','foto_trasera','2026-04-23 19:56:57'),(217,68,'1776974217732-911329973.jpg','foto_cargando','2026-04-23 19:56:57'),(218,69,'1776974217931-748434478.jpg','foto_frontal','2026-04-23 19:56:57'),(219,69,'1776974217931-280894502.jpg','foto_trasera','2026-04-23 19:56:57'),(220,69,'1776974217931-410199233.jpg','foto_cargando','2026-04-23 19:56:57'),(221,70,'1776974218276-496202715.jpg','foto_frontal','2026-04-23 19:56:58'),(222,70,'1776974218276-642753823.jpg','foto_trasera','2026-04-23 19:56:58'),(223,70,'1776974218276-576240454.jpg','foto_cargando','2026-04-23 19:56:58'),(224,71,'1776974218489-750846753.jpg','foto_frontal','2026-04-23 19:56:58'),(225,71,'1776974218489-949928695.jpg','foto_trasera','2026-04-23 19:56:58'),(226,71,'1776974218489-62072544.jpg','foto_cargando','2026-04-23 19:56:58'),(227,73,'1776974218882-9163593.jpg','foto_frontal','2026-04-23 19:56:58'),(228,73,'1776974218882-685316690.jpg','foto_trasera','2026-04-23 19:56:58'),(229,73,'1776974218883-371311420.jpg','foto_cargando','2026-04-23 19:56:58'),(230,74,'1776974219839-610388916.jpg','foto_frontal','2026-04-23 19:56:59'),(231,74,'1776974219839-1519683.jpg','foto_trasera','2026-04-23 19:56:59'),(232,74,'1776974219839-683708572.jpg','foto_cargando','2026-04-23 19:56:59'),(233,75,'1776974220069-153398406.jpg','foto_frontal','2026-04-23 19:57:00'),(234,75,'1776974220069-844554112.jpg','foto_trasera','2026-04-23 19:57:00'),(235,75,'1776974220069-152659279.jpg','foto_cargando','2026-04-23 19:57:00'),(236,76,'1776974412387-255437758.jpg','foto_frontal','2026-04-23 20:00:12'),(237,76,'1776974412387-428919970.jpg','foto_trasera','2026-04-23 20:00:12'),(238,76,'1776974412387-74098020.jpg','foto_cargando','2026-04-23 20:00:12'),(239,77,'1776974434834-883416646.jpg','foto_frontal','2026-04-23 20:00:34'),(240,77,'1776974434834-762444870.jpg','foto_trasera','2026-04-23 20:00:34'),(241,77,'1776974434834-82723523.jpg','foto_cargando','2026-04-23 20:00:34'),(242,78,'1776974435788-929824002.jpg','foto_frontal','2026-04-23 20:00:35'),(243,78,'1776974435788-105626120.jpg','foto_trasera','2026-04-23 20:00:35'),(244,78,'1776974435788-143463590.jpg','foto_cargando','2026-04-23 20:00:35'),(245,79,'1776974436274-7105883.jpg','foto_frontal','2026-04-23 20:00:36'),(246,79,'1776974436274-10658070.jpg','foto_trasera','2026-04-23 20:00:36'),(247,79,'1776974436274-763058990.jpg','foto_cargando','2026-04-23 20:00:36'),(248,80,'1776974436803-963562287.jpg','foto_frontal','2026-04-23 20:00:36'),(249,80,'1776974436803-680311935.jpg','foto_trasera','2026-04-23 20:00:36'),(250,80,'1776974436803-169118339.jpg','foto_cargando','2026-04-23 20:00:36'),(251,81,'1776974437248-271341499.jpg','foto_frontal','2026-04-23 20:00:37'),(252,81,'1776974437248-565825081.jpg','foto_trasera','2026-04-23 20:00:37'),(253,81,'1776974437248-145781868.jpg','foto_cargando','2026-04-23 20:00:37'),(254,82,'1776976858919-346533598.jpg','foto_frontal','2026-04-23 20:40:58'),(255,82,'1776976858920-976036316.jpg','foto_trasera','2026-04-23 20:40:58'),(256,82,'1776976858920-13725237.docx','foto_cargando','2026-04-23 20:40:58'),(257,83,'1776977143885-683633810.jpg','foto_frontal','2026-04-23 20:45:43'),(258,83,'1776977143886-941725855.jpg','foto_trasera','2026-04-23 20:45:43'),(259,83,'1776977143886-575189805.jpg','foto_cargando','2026-04-23 20:45:43'),(260,84,'1776977201593-203454437.jpg','foto_frontal','2026-04-23 20:46:41'),(261,84,'1776977201593-56856934.jpg','foto_trasera','2026-04-23 20:46:41'),(262,84,'1776977201594-874159443.jpg','foto_cargando','2026-04-23 20:46:41'),(263,85,'1776977205728-195561656.jpg','foto_frontal','2026-04-23 20:46:45'),(264,85,'1776977205728-706163856.jpg','foto_trasera','2026-04-23 20:46:45'),(265,85,'1776977205728-577001820.jpg','foto_cargando','2026-04-23 20:46:45'),(266,86,'1776977314869-455753667.jpg','foto_frontal','2026-04-23 20:48:34'),(267,86,'1776977314870-493626243.jpg','foto_trasera','2026-04-23 20:48:34'),(268,86,'1776977314870-256283080.jpg','foto_cargando','2026-04-23 20:48:34'),(269,87,'1776978858473-105436636.jpg','foto_frontal','2026-04-23 21:14:18'),(270,87,'1776978858474-258978374.jpg','foto_trasera','2026-04-23 21:14:18'),(271,87,'1776978858474-428606416.jpg','foto_cargando','2026-04-23 21:14:18'),(272,88,'1776979057634-155287469.jpg','foto_frontal','2026-04-23 21:17:37'),(273,88,'1776979057634-768210759.jpg','foto_trasera','2026-04-23 21:17:37'),(274,88,'1776979057634-98440644.jpg','foto_cargando','2026-04-23 21:17:37');
/*!40000 ALTER TABLE `fotos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historial_ventas`
--

DROP TABLE IF EXISTS `historial_ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `historial_ventas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `telefono_id` int(11) DEFAULT NULL,
  `nombre_equipo` varchar(100) DEFAULT NULL,
  `precio_venta` decimal(10,2) DEFAULT NULL,
  `vendedor_id` int(11) DEFAULT NULL,
  `fecha_venta` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `vendedor_id` (`vendedor_id`),
  CONSTRAINT `historial_ventas_ibfk_1` FOREIGN KEY (`vendedor_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historial_ventas`
--

LOCK TABLES `historial_ventas` WRITE;
/*!40000 ALTER TABLE `historial_ventas` DISABLE KEYS */;
INSERT INTO `historial_ventas` VALUES (1,1,'iphone4',4.00,14,'2026-03-26 19:15:18'),(2,2,'iphone4',543543.00,14,'2026-03-26 19:36:23'),(3,3,'huea',3213213.00,14,'2026-04-03 04:00:40'),(4,5,'Motorola',33333.00,14,'2026-04-10 20:27:33'),(5,4,'iPhone 12',20000.00,14,'2026-04-10 20:27:35'),(6,10,'Hwhehe',6464.00,14,'2026-04-10 20:38:05'),(7,9,'Hwheh',1661.00,14,'2026-04-10 20:38:07'),(8,7,'Hwhehe',4661.00,14,'2026-04-10 20:38:14'),(9,14,'huea',342.00,14,'2026-04-10 21:11:06'),(10,22,'dfsdsf',5345.00,14,'2026-04-10 21:11:57'),(11,23,'gdf',54654.00,14,'2026-04-10 21:12:20'),(12,21,'fewfe',45354.00,14,'2026-04-10 21:12:22'),(13,13,'iphone4',89897.00,14,'2026-04-10 21:12:24'),(14,8,'EGDFGSD',324324.00,14,'2026-04-10 21:12:26'),(15,11,'iphone4',32423.00,14,'2026-04-10 21:12:28'),(16,24,'dfsfg',6546.00,14,'2026-04-10 21:12:45'),(17,25,'gfdg',5.00,14,'2026-04-10 21:14:51'),(18,27,'5435',5435.00,14,'2026-04-10 21:18:09'),(19,30,'Hsjsh',46464.00,14,'2026-04-10 21:30:13'),(20,31,'GDFG',4534.00,14,'2026-04-10 21:30:15'),(21,33,'huea',4534.00,14,'2026-04-10 21:37:41'),(22,32,'Hwjwjs',464646.00,14,'2026-04-10 21:37:43'),(23,29,'435',5345.00,14,'2026-04-10 21:39:41'),(24,34,'FGRT',435.00,14,'2026-04-10 21:39:43'),(25,36,'Ywhshsh',46454.00,13,'2026-04-15 03:32:30'),(26,38,'Jejejs',466464.00,13,'2026-04-15 03:49:48'),(27,39,'Jsjshs',64644.00,14,'2026-04-23 21:13:34');
/*!40000 ALTER TABLE `historial_ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mensajes`
--

DROP TABLE IF EXISTS `mensajes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mensajes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `orden_id` int(11) NOT NULL,
  `autor` enum('tecnico','cliente') DEFAULT NULL,
  `texto` text DEFAULT NULL,
  `enviado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `orden_id` (`orden_id`),
  CONSTRAINT `mensajes_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `ordenes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mensajes`
--

LOCK TABLES `mensajes` WRITE;
/*!40000 ALTER TABLE `mensajes` DISABLE KEYS */;
INSERT INTO `mensajes` VALUES (26,40,'tecnico','Lol','2026-04-06 01:51:39'),(27,40,'cliente','Martin gay','2026-04-06 01:52:19'),(28,40,'tecnico','Jajaja confirmado ','2026-04-06 01:52:31'),(32,86,'cliente','Hola joven','2026-04-23 20:50:29'),(33,86,'tecnico','QUE PASO','2026-04-23 20:50:36'),(34,87,'tecnico','QUE PASO','2026-04-23 21:16:10'),(35,87,'cliente','Lol','2026-04-23 21:16:29');
/*!40000 ALTER TABLE `mensajes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ordenes`
--

DROP TABLE IF EXISTS `ordenes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ordenes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(30) NOT NULL,
  `cliente_nombre` varchar(100) NOT NULL,
  `cliente_telefono` varchar(20) DEFAULT NULL,
  `cliente_email` varchar(100) DEFAULT NULL,
  `contacto` enum('whatsapp','email') DEFAULT 'whatsapp',
  `equipo_tipo` varchar(30) DEFAULT NULL,
  `equipo_marca` varchar(50) DEFAULT NULL,
  `equipo_modelo` varchar(100) DEFAULT NULL,
  `equipo_password` varchar(50) DEFAULT NULL,
  `falla_descripcion` text DEFAULT NULL,
  `costo_estimado` int(11) DEFAULT 0,
  `costo_total` int(11) DEFAULT 0,
  `estado` enum('taller','reparacion','listo','entregado') DEFAULT 'taller',
  `fecha_ingreso` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordenes`
--

LOCK TABLES `ordenes` WRITE;
/*!40000 ALTER TABLE `ordenes` DISABLE KEYS */;
INSERT INTO `ordenes` VALUES (37,'TRP-2026-926','gabriela moscoso','+56949164821','ronaldoyony@gmail.com','whatsapp','tablet','Samsung','samugn a04','21434','vhcghcghcg',75756,75756,'taller','2026-04-03 07:02:19'),(38,'TRP-2026-668','Silvana lara','+56922376101','ronaldoyony@gmail.com','whatsapp','telefono','Motorola ','G50 5g','Sin pin','El teléfono no quiere cargar el cual por viste se ve que el puerto está malo ',10000,10000,'reparacion','2026-04-03 19:01:24'),(39,'TRP-2026-958','Brandon melinao','+56857637397','ronaldoyony@gmail.com','whatsapp','telefono','Motorola ','G50 5g','1234','Cago la pantalla corriéndome una pagita',45000,45000,'taller','2026-04-06 01:44:05'),(40,'TRP-2026-460','Brandon melinao','+56957637397','ronaldoyony@gmail.com','whatsapp','telefono','Motorola ','G50 5g','Sin pin','Se Estaba tocando ya pantalla se murió ',45000,50000,'reparacion','2026-04-06 01:47:12'),(41,'TRP-2026-979','Mariela Ampuero ','+56961645268','ronaldoyony@gmail.com','whatsapp','telefono','Samsung ','A13 4g','Sin','Producto de una caída el teléfono presenta una quebrado por la cual el teléfono no da bien imagen ',27000,27000,'taller','2026-04-10 18:34:49'),(46,'TRP-2026-667','brandon meliao','+56937658841','ronaldoyony@gmail.com','whatsapp','Teléfono','Motorola','Moto E40','21434','se me cayo al agua y no prende la pantalla',0,0,'taller','2026-04-10 19:48:51'),(47,'TRP-2026-719','gabriela moscoso','+56949164821','ronaldoyony@gmail.com','whatsapp','Teléfono','ZTE','Blade V40','99999','cambio de puerto de carga ',12000,12000,'listo','2026-04-10 19:50:15'),(48,'TRP-2026-364','Yont','+56857637397','ronaldoyony@gmail.com','whatsapp','Tablet','Huawei','MatePad 11','Sin pin','Jsjsjs',44000,44000,'reparacion','2026-04-15 03:56:22'),(49,'TRP-2026-307','Javiera Maldonado ','+56957637397','ronaldoyony@gmail.com','whatsapp','Teléfono','Huawei','Y9 Prime','Sin pin','Se cayó de las manos y se me rompió la pantalla y no se puede ver nada ',43000,43000,'listo','2026-04-15 23:35:50'),(50,'TRP-2026-905','Mariela Ampuero ','961645268','gabrielamperalta68@gmail.com','','Teléfono','Samsung','Galaxy A13 4G','Sin pin','Pantalla mala',27000,27000,'reparacion','2026-04-23 02:30:09'),(51,'TRP-2026-521','brandon meliao','+56937658841','ronaldoyony@gmail.com','whatsapp','Notebook','Acer','iphone 14','21434','dfsf',343444,343444,'taller','2026-04-23 03:08:46'),(52,'TRP-2026-977','brandon meliao','+56937658841','ronaldoyony@gmail.com','whatsapp','Notebook','Acer','iphone 14','21434','dfsf',343444,343444,'taller','2026-04-23 03:11:22'),(53,'TRP-2026-571','brandon meliao','+56937658841','ronaldoyony@gmail.com','whatsapp','Notebook','Acer','iphone 14','21434','dfsf',343444,343444,'listo','2026-04-23 03:11:58'),(54,'TRP-2026-952','gabriela moscoso','+56937658841','ronaldoyony@gmail.com','whatsapp','Notebook','Acer','Aspire 5','','pp',99809000,99809000,'listo','2026-04-23 03:16:39'),(55,'TRP-2026-767','brandon meliao','+56937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Acer','Aspire 5','21434','2esdsa',344444,344444,'taller','2026-04-23 03:27:35'),(56,'TRP-2026-450','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:53:57'),(57,'TRP-2026-192','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:54:19'),(58,'TRP-2026-990','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:54'),(59,'TRP-2026-864','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:54'),(60,'TRP-2026-202','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:55'),(61,'TRP-2026-622','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:55'),(62,'TRP-2026-261','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:56'),(63,'TRP-2026-728','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:56'),(64,'TRP-2026-974','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:56'),(65,'TRP-2026-879','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:56'),(66,'TRP-2026-447','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:57'),(67,'TRP-2026-947','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:57'),(68,'TRP-2026-228','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:57'),(69,'TRP-2026-126','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:57'),(70,'TRP-2026-325','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:58'),(71,'TRP-2026-859','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:58'),(73,'TRP-2026-645','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:58'),(74,'TRP-2026-660','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:56:59'),(75,'TRP-2026-386','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 19:57:00'),(76,'TRP-2026-109','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 20:00:12'),(77,'TRP-2026-927','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 20:00:34'),(78,'TRP-2026-430','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 20:00:35'),(79,'TRP-2026-532','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 20:00:36'),(80,'TRP-2026-190','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 20:00:36'),(81,'TRP-2026-141','yony maldonado','937886541','ronaldoyony@gmail.com','whatsapp','Notebook','Lenovo','ThinkPad E14','21434','cambio de ram por unas de 8gb cual antes tenia unas de 4gb',455555,455555,'taller','2026-04-23 20:00:37'),(82,'TRP-2026-988','gabriela moscoso','+56937658841','rosalesjanss743@gmail.com','','Tablet','Huawei','MatePad 11','4234','pnatalla de demasiada mala para reparar ',545555,545555,'entregado','2026-04-23 20:40:58'),(83,'TRP-2026-142','brandon meliao','+56937658841','moscosoyon23@gmail.com','','Notebook','Acer','Aspire 5','4234','asdhgwesdhjfhe',3444,3444,'taller','2026-04-23 20:45:43'),(84,'TRP-2026-439','brandon meliao','+56937658841','moscosoyon23@gmail.com','','Notebook','Acer','Aspire 5','4234','asdhgwesdhjfhe',3444,3444,'taller','2026-04-23 20:46:41'),(85,'TRP-2026-854','brandon meliao','+56937658841','moscosoyon23@gmail.com','','Notebook','Acer','Aspire 5','4234','asdhgwesdhjfhe',3444,3444,'listo','2026-04-23 20:46:45'),(86,'TRP-2026-183','brandon meliao','+56937658841','moscosoyon23@gmail.com','','Notebook','Acer','Aspire 5','4234','asdhgwesdhjfhe',3444,3444,'listo','2026-04-23 20:48:34'),(87,'TRP-2026-644','brandon meliao','+56937658841','ronaldoyony@gmail.com','','Notebook','Apple','MacBook Air M1','21434','fsdfdsf',34444,49997,'entregado','2026-04-23 21:14:18'),(88,'TRP-2026-802','brandon meliao','+56937658841','ronaldoyony@gmail.com','','Notebook','Apple','MacBook Air M1','21434','fsdfdsf',34444,34444,'listo','2026-04-23 21:17:37');
/*!40000 ALTER TABLE `ordenes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `repuestos`
--

DROP TABLE IF EXISTS `repuestos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `repuestos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `modelo_compatible` varchar(255) DEFAULT NULL,
  `cantidad` int(11) DEFAULT 0,
  `precio_compra` decimal(10,2) DEFAULT NULL,
  `precio_venta` decimal(10,2) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `repuestos`
--

LOCK TABLES `repuestos` WRITE;
/*!40000 ALTER TABLE `repuestos` DISABLE KEYS */;
INSERT INTO `repuestos` VALUES (2,'iphone 12','iphone 12 , 12pro',12,12000.00,23000.00,'2026-04-23 21:38:03'),(3,'Samsung','a13 4g',2,11200.00,37000.00,'2026-04-23 21:40:35');
/*!40000 ALTER TABLE `repuestos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int(11) unsigned NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('SzeJAmCj9KmMDeK5T9XmebZtQKG1EMuB',1777070666,'{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"userId\":14,\"rol\":\"tecnico\"}'),('UmKz_7KhyUwuCL5eIrv24DJbdCu8yIgs',1777065500,'{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"userId\":14,\"rol\":\"tecnico\"}'),('b-UyCoyxdDwbi3aTws3WifGSiOFF3oSo',1777074741,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-24T23:52:10.788Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"userId\":14,\"rol\":\"tecnico\"}');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `telefonos_venta`
--

DROP TABLE IF EXISTS `telefonos_venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `telefonos_venta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` int(11) DEFAULT NULL,
  `precio_anterior` int(11) DEFAULT NULL,
  `bateria` int(11) DEFAULT NULL,
  `storage` varchar(20) DEFAULT NULL,
  `color` varchar(30) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `disponible` tinyint(1) DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `telefonos_venta`
--

LOCK TABLES `telefonos_venta` WRITE;
/*!40000 ALTER TABLE `telefonos_venta` DISABLE KEYS */;
INSERT INTO `telefonos_venta` VALUES (2,'iphone4','FDSDFZSD',543543,453435,545,'432','FSDFSD','1774552578065-616178910.jpg',0,'2026-03-26 19:16:18'),(3,'huea','esdfjrewbfhjkwef',3213213,434234,545,'123','blanco','1774555087569-999225555.jpg',0,'2026-03-26 19:38:46'),(4,'iPhone 12','Está bueno ',20000,60000,88,'766','Black','1775440399211-748769687.jpg',0,'2026-04-06 01:53:22'),(5,'Motorola','Está Brando ',33333,2222,88,'128','Blanco ','1775440460092-496454423.jpg',0,'2026-04-06 01:54:20'),(6,'iphone4','EFSD',43243,3242,432432,'42432','43','1775852841734-827694202.jpg',1,'2026-04-10 20:27:21'),(7,'Hwhehe','Hshhweh',4661,464664,0,'Shhshs','Wjjehe','1775852928465-656098906.jpg',0,'2026-04-10 20:28:50'),(8,'EGDFGSD','435345',324324,435,435345,'FSDFSD','DSF','1775852994926-684784157.jpg',0,'2026-04-10 20:29:54'),(9,'Hwheh','Dhhd',1661,5454,0,'Shgs','Whwhhw','1775853189118-209216211.jpg',0,'2026-04-10 20:33:09'),(10,'Hwhehe','Hshsh',6464,611,0,'Hshs','Hdhhd','1775853472423-392361494.jpg',0,'2026-04-10 20:37:53'),(11,'iphone4','SDAFDS',32423,4324,324,'3423','FDS','1775854071367-924858233.jpg',0,'2026-04-10 20:47:51'),(13,'iphone4','gdsfg',89897,3432,324,'213','rojo','1775854798422-209486982.jpg',0,'2026-04-10 20:59:58'),(14,'huea','3424',342,4324,324432,'123','blanco','1775855027807-718730606.jpg',0,'2026-04-10 21:03:47'),(21,'fewfe','fsdf',45354,453543,5435,'wfewfew','fewfwe','1775855432522-436197303.jpg',0,'2026-04-10 21:10:32'),(23,'gdf','54645',54654,546456,6546,'ggdf','dfg','1775855507265-567260608.jpg',0,'2026-04-10 21:11:47'),(26,'iphone4','5345',5345,43543,3455,'534','3455','1775855684457-790335972.jpg',1,'2026-04-10 21:14:44'),(28,'iphone4','342432',4324,4324,32432,'34324','4324','1775855872430-819668503.jpg',1,'2026-04-10 21:17:52'),(29,'435','34534',5345,534534,5435,'5435','3455','1775855908162-711209387.jpg',0,'2026-04-10 21:18:28'),(30,'Hsjsh','Hshsh',46464,6454,0,'Shshs','Shshs','1775856016533-993297052.jpg',0,'2026-04-10 21:20:18'),(31,'GDFG','543543',4534,3455,34534,'534','534','1775856558726-991808738.jpg',0,'2026-04-10 21:29:18'),(32,'Hwjwjs','Sggs',464646,464664,0,'Sshhs','Shshhs','1775856593496-559396928.jpg',0,'2026-04-10 21:29:54'),(33,'huea','FEW',4534,43534,0,'EF','EFWE','1775856643709-103061367.jpg',0,'2026-04-10 21:30:43'),(34,'FGRT','543534',435,4534,534543,'RERTE','GDF','1775857053368-618964677.jpg',0,'2026-04-10 21:37:33'),(35,'yony','GFD',654645,546,564654,'VFDD','FDGD','1775857114067-291566111.ico',1,'2026-04-10 21:38:34'),(37,'huea','432423',4324,432423,342432,'32423','3423','1776224054576-633120187.jpg',1,'2026-04-15 03:34:14'),(39,'Jsjshs','Shhshs',64644,9454,0,'Sbhsys','Shshs','1776224962827-486441292.jpg',0,'2026-04-15 03:49:23'),(40,'gf','543',545,454,545,'45','545','1776980977370-240258256.jpg',1,'2026-04-23 21:49:37'),(41,'543','5434',5435,43543,5435,'534','4534','1776980987338-536831712.jpg',1,'2026-04-23 21:49:47'),(42,'5454','5345',5435,534,5435,'5345','545','1776981015483-69255906.jpg',1,'2026-04-23 21:50:15');
/*!40000 ALTER TABLE `telefonos_venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transacciones_caja`
--

DROP TABLE IF EXISTS `transacciones_caja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transacciones_caja` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `caja_id` int(11) NOT NULL,
  `tipo` enum('ingreso','egreso') NOT NULL,
  `concepto` varchar(255) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `metodo_pago` varchar(50) DEFAULT 'efectivo',
  `usuario_id` int(11) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `caja_id` (`caja_id`),
  CONSTRAINT `transacciones_caja_ibfk_1` FOREIGN KEY (`caja_id`) REFERENCES `caja_diaria` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transacciones_caja`
--

LOCK TABLES `transacciones_caja` WRITE;
/*!40000 ALTER TABLE `transacciones_caja` DISABLE KEYS */;
INSERT INTO `transacciones_caja` VALUES (1,1,'ingreso','5gfdg',444.00,'efectivo',13,'2026-04-23 23:29:00');
/*!40000 ALTER TABLE `transacciones_caja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `rol` enum('admin','tecnico') DEFAULT 'tecnico',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (13,'Administrador','admin@techrepair.cl','$2b$10$Kb9ZjCfUzIIkB/5K/WsocuYeQtxKR5S239UwMXiXNvbnQ1B2zJWBG','admin','2026-03-25 21:05:15'),(14,'yony','ronaldoyony@gmail.com','$2b$10$HA0.dOm3ASfFq.hfqnY0Ce90N3GIL4XAehRm6dv8GOcz31FH/tPKu','tecnico','2026-03-25 21:38:33');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-23 19:58:02
