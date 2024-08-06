SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for user_list
-- ----------------------------
DROP TABLE IF EXISTS `user_list`;
CREATE TABLE `user_list` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `user_name` varchar(255) NOT NULL COMMENT '用户名',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of user_list
-- ----------------------------
BEGIN;
INSERT INTO `user_list` (`user_id`, `user_name`) VALUES (1, '小萍');
INSERT INTO `user_list` (`user_id`, `user_name`) VALUES (2, '小明');
INSERT INTO `user_list` (`user_id`, `user_name`) VALUES (3, '小张');
INSERT INTO `user_list` (`user_id`, `user_name`) VALUES (4, '小王');
INSERT INTO `user_list` (`user_id`, `user_name`) VALUES (5, '小李');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
