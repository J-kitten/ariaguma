use ariaguma;
-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: localhost    Database: ariaguma_dev
-- ------------------------------------------------------
-- Server version	8.0.42-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `contacts`
--

DROP TABLE IF EXISTS `contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contacts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `subject` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contacts_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contacts`
--

LOCK TABLES `contacts` WRITE;
/*!40000 ALTER TABLE `contacts` DISABLE KEYS */;
INSERT INTO `contacts` VALUES (1,'太郎','テスト','{\"p\":\"pvKjoIsflsv6lTP0VLflCg==\",\"h\":{\"iv\":\"elzX9pWWZmzb7X7s\",\"at\":\"bspfp22N2aw+bXPHmjh7LQ==\"}}','こんにちは','2025-05-10 16:41:15.351023','2025-05-10 16:41:15.351023'),(2,'教子','テスト','{\"p\":\"v1bAae1v8vhCmLFbh/PbDo3JDA==\",\"h\":{\"iv\":\"E1EBxmq1oVXs2Y/3\",\"at\":\"aBQ9nFIJHzz4gPP/3ZVPUg==\"}}','こんにちは、こんばんは','2025-05-10 17:08:49.817723','2025-05-10 17:08:49.817723'),(3,'佐藤まよ','佐藤と申します','{\"p\":\"R8qXbxr81PJAFbcfabD1eojSlMmCn9GwfAFywCs=\",\"h\":{\"iv\":\"kKxuAnTH66HESGEA\",\"at\":\"/nWL18Mho72roMVvhFswwA==\"}}','メッセージです。','2025-05-11 15:24:35.259202','2025-05-11 15:24:35.259202'),(4,'佐藤まよ','佐藤と申します','{\"p\":\"bv6joUs3n3g6jQlF+BngKrIk0VLTMayuXg6tjlY=\",\"h\":{\"iv\":\"wGKXV45vMVRR8pUl\",\"at\":\"nKBF5aPqGG8HVfy/bQteOg==\"}}','テストメールです。2025-5-12 18:21','2025-05-12 09:21:21.884955','2025-05-12 09:21:21.884955'),(5,'佐藤 教子','佐藤と申します','{\"p\":\"UFHsIWj4E4HzFV3oThqIY5CVYfGEfvf96Pb6XCM=\",\"h\":{\"iv\":\"IY2D5HdikYKCde7d\",\"at\":\"NyaGrdQJIxmgO3A9NdmtqQ==\"}}','こんばんは\r\n','2025-05-12 12:48:24.601002','2025-05-12 12:48:24.601002'),(6,'佐藤 教子','佐藤と申します 2025/5/12 21:48','{\"p\":\"fOpwZsxQbOn+oKxpZ7BlwUl9QneAFKrd3g49mLw=\",\"h\":{\"iv\":\"DuUBfw9b7GPXHckX\",\"at\":\"YHesNdxxAJ0sow5yGOFGTg==\"}}','こんばんは！','2025-05-12 12:49:19.885648','2025-05-12 12:49:19.885648');
/*!40000 ALTER TABLE `contacts` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-05-29 21:52:11
