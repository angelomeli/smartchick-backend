-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 15 juil. 2026 à 04:36
-- Version du serveur : 8.0.31
-- Version de PHP : 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `smartchick_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `actuators`
--

DROP TABLE IF EXISTS `actuators`;
CREATE TABLE IF NOT EXISTS `actuators` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `coop_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('ventilateur','pompe_eau','distributeur','eclairage','chauffage','refroidissement') COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `etat` tinyint(1) NOT NULL DEFAULT '0',
  `puissance` decimal(5,2) DEFAULT '0.00',
  `mode` enum('auto','manuel','schedule') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'auto',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `coop_id` (`coop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `actuators`
--

INSERT INTO `actuators` (`id`, `coop_id`, `type`, `nom`, `etat`, `puissance`, `mode`, `created_at`, `updated_at`) VALUES
('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'ventilateur', 'Ventilateur 1', 0, '0.00', 'auto', '2026-06-03 11:09:15', '2026-06-03 11:09:15');

-- --------------------------------------------------------

--
-- Structure de la table `actuator_logs`
--

DROP TABLE IF EXISTS `actuator_logs`;
CREATE TABLE IF NOT EXISTS `actuator_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `actuator_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` enum('on','off','set_level') COLLATE utf8mb4_unicode_ci NOT NULL,
  `puissance` decimal(5,2) DEFAULT NULL,
  `triggered_by` enum('auto','manuel','schedule') COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logged_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_act_time` (`actuator_id`,`logged_at` DESC),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `alerts_log`
--

DROP TABLE IF EXISTS `alerts_log`;
CREATE TABLE IF NOT EXISTS `alerts_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sensor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parameter` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alert_level` enum('warning','alert','critical') COLLATE utf8mb4_unicode_ci NOT NULL,
  `valeur` decimal(10,4) NOT NULL,
  `seuil` decimal(10,4) DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `acknowledged` tinyint(1) NOT NULL DEFAULT '0',
  `acked_by` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `acked_at` datetime DEFAULT NULL,
  `triggered_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `alert_rules`
--

DROP TABLE IF EXISTS `alert_rules`;
CREATE TABLE IF NOT EXISTS `alert_rules` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sensor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `seuil_bas` decimal(10,2) DEFAULT NULL,
  `seuil_haut` decimal(10,2) DEFAULT NULL,
  `niveau` enum('warning','alert','critical') COLLATE utf8mb4_unicode_ci NOT NULL,
  `canaux` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'push',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sensor_id` (`sensor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `alert_rules`
--

INSERT INTO `alert_rules` (`id`, `sensor_id`, `seuil_bas`, `seuil_haut`, `niveau`, `canaux`, `is_active`, `created_at`, `updated_at`) VALUES
('r0000000-0000-0000-0000-000000000001', 's0000000-0000-0000-0000-000000000001', NULL, '28.00', 'warning', 'push', 1, '2026-06-03 11:09:15', '2026-06-03 11:09:15');

-- --------------------------------------------------------

--
-- Structure de la table `coops`
--

DROP TABLE IF EXISTS `coops`;
CREATE TABLE IF NOT EXISTS `coops` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `farm_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacite` int DEFAULT NULL,
  `statut` enum('actif','vide','maintenance') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'actif',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `farm_id` (`farm_id`)
) ;

--
-- Déchargement des données de la table `coops`
--

INSERT INTO `coops` (`id`, `farm_id`, `nom`, `capacite`, `statut`, `created_at`) VALUES
('c0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'Poulailler A', 500, 'actif', '2026-06-03 11:09:15');

-- --------------------------------------------------------

--
-- Structure de la table `farms`
--

DROP TABLE IF EXISTS `farms`;
CREATE TABLE IF NOT EXISTS `farms` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `localisation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `owner_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Fermes avicoles enregistrées';

--
-- Déchargement des données de la table `farms`
--

INSERT INTO `farms` (`id`, `nom`, `localisation`, `description`, `owner_id`, `is_active`, `created_at`, `updated_at`) VALUES
('f0000000-0000-0000-0000-000000000001', 'Ferme SmartChick 01', 'Douala Nord', 'Pilote', 'u0000000-0000-0000-0000-000000000001', 1, '2026-06-03 11:09:15', '2026-06-03 11:09:15');

-- --------------------------------------------------------

--
-- Structure de la table `farm_users`
--

DROP TABLE IF EXISTS `farm_users`;
CREATE TABLE IF NOT EXISTS `farm_users` (
  `farm_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','eleveur','observateur') COLLATE utf8mb4_unicode_ci NOT NULL,
  `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`farm_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Accès utilisateurs par ferme';

--
-- Déchargement des données de la table `farm_users`
--

INSERT INTO `farm_users` (`farm_id`, `user_id`, `role`, `joined_at`) VALUES
('f0000000-0000-0000-0000-000000000001', 'u0000000-0000-0000-0000-000000000001', 'admin', '2026-06-03 11:09:15'),
('f0000000-0000-0000-0000-000000000001', 'u0000000-0000-0000-0000-000000000002', 'eleveur', '2026-06-03 11:09:15');

-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `farm_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rule_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `canal` enum('push','sms','call','email') COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `statut` enum('sent','delivered','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sent',
  `sent_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `acked_at` datetime DEFAULT NULL,
  `acked_by` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `farm_id` (`farm_id`),
  KEY `rule_id` (`rule_id`),
  KEY `acked_by` (`acked_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reports`
--

DROP TABLE IF EXISTS `reports`;
CREATE TABLE IF NOT EXISTS `reports` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `farm_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('weekly','monthly','custom') COLLATE utf8mb4_unicode_ci NOT NULL,
  `periode_debut` date NOT NULL,
  `periode_fin` date NOT NULL,
  `fichier_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `farm_id` (`farm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
CREATE TABLE IF NOT EXISTS `schedules` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actuator_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `heure_debut` time NOT NULL,
  `duree_minutes` int NOT NULL,
  `jours` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'lun,mar,mer,jeu,ven,sam,dim',
  `quantite` decimal(8,2) DEFAULT NULL,
  `puissance_cible` decimal(5,2) DEFAULT '100.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `actuator_id` (`actuator_id`)
) ;

-- --------------------------------------------------------

--
-- Structure de la table `sensors`
--

DROP TABLE IF EXISTS `sensors`;
CREATE TABLE IF NOT EXISTS `sensors` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `coop_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('temperature','humidity','air_quality','luminosity','water_level','food_level','motion') COLLATE utf8mb4_unicode_ci NOT NULL,
  `modele` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `seuil_min` decimal(10,2) DEFAULT NULL,
  `seuil_max` decimal(10,2) DEFAULT NULL,
  `unite` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_seen` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `coop_id` (`coop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Capteurs IoT enregistrés';

--
-- Déchargement des données de la table `sensors`
--

INSERT INTO `sensors` (`id`, `coop_id`, `type`, `modele`, `seuil_min`, `seuil_max`, `unite`, `is_active`, `last_seen`, `created_at`) VALUES
('s0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'temperature', 'DHT22', '18.00', '25.00', 'C', 1, NULL, '2026-06-03 11:09:15'),
('s0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'humidity', 'DHT22', '40.00', '80.00', '%', 1, NULL, '2026-06-03 11:09:15');

-- --------------------------------------------------------

--
-- Structure de la table `sensor_data`
--

DROP TABLE IF EXISTS `sensor_data`;
CREATE TABLE IF NOT EXISTS `sensor_data` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sensor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `farm_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `valeur` decimal(10,4) NOT NULL,
  `unite` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sensor_time` (`sensor_id`,`recorded_at` DESC),
  KEY `idx_farm_time` (`farm_id`,`recorded_at` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `sensor_data`
--

INSERT INTO `sensor_data` (`id`, `sensor_id`, `farm_id`, `valeur`, `unite`, `recorded_at`) VALUES
(9, 's0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', '26.3000', '°C', '2026-07-07 04:53:31'),
(10, 's0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000001', '62.1000', '%', '2026-07-07 04:53:31');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prenom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','eleveur','observateur') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'observateur',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Comptes utilisateurs SmartChick';

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `nom`, `prenom`, `email`, `password_hash`, `role`, `is_active`, `created_at`, `updated_at`) VALUES
('u-999', 'Admin', 'Smartix', 'admin@smartix.cm', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TsCl2PEcNJJiKbMzNGAFBdVXxhre', 'admin', 1, '2026-06-05 09:57:08', '2026-06-05 09:57:08'),
('u0000000-0000-0000-0000-000000000001', 'meli', 'angelo', 'meli@smartchick.cm', '$2b$10$7R6vW1A9876Uu389C9hKfeO9bVWhU2lgKQwgh9cXCOIZ3RztJ.N2a', 'admin', 1, '2026-06-03 11:09:15', '2026-07-13 06:47:09'),
('u0000000-0000-0000-0000-000000000002', 'Ngono', 'Jean', 'jean@smartchick.cm', 'hash2', 'eleveur', 1, '2026-06-03 11:09:15', '2026-06-03 11:09:15'),
('u0000000-0000-0000-0000-000000000003', 'Mballa', 'Alice', 'alice@smartchick.cm', 'hash3', 'observateur', 1, '2026-06-03 11:09:15', '2026-06-03 11:09:15');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `actuators`
--
ALTER TABLE `actuators`
  ADD CONSTRAINT `actuators_ibfk_1` FOREIGN KEY (`coop_id`) REFERENCES `coops` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `actuator_logs`
--
ALTER TABLE `actuator_logs`
  ADD CONSTRAINT `actuator_logs_ibfk_1` FOREIGN KEY (`actuator_id`) REFERENCES `actuators` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `actuator_logs_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `alert_rules`
--
ALTER TABLE `alert_rules`
  ADD CONSTRAINT `alert_rules_ibfk_1` FOREIGN KEY (`sensor_id`) REFERENCES `sensors` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coops`
--
ALTER TABLE `coops`
  ADD CONSTRAINT `coops_ibfk_1` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `farms`
--
ALTER TABLE `farms`
  ADD CONSTRAINT `farms_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `farm_users`
--
ALTER TABLE `farm_users`
  ADD CONSTRAINT `farm_users_ibfk_1` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `farm_users_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`rule_id`) REFERENCES `alert_rules` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `notifications_ibfk_3` FOREIGN KEY (`acked_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`actuator_id`) REFERENCES `actuators` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `sensors`
--
ALTER TABLE `sensors`
  ADD CONSTRAINT `sensors_ibfk_1` FOREIGN KEY (`coop_id`) REFERENCES `coops` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `sensor_data`
--
ALTER TABLE `sensor_data`
  ADD CONSTRAINT `sensor_data_ibfk_1` FOREIGN KEY (`sensor_id`) REFERENCES `sensors` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sensor_data_ibfk_2` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
