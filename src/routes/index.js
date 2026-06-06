const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const sensorController = require('../controllers/sensorController');
const actuatorController = require('../controllers/actuatorController');
const alertController = require('../controllers/alertController');
const { authMiddleware, adminOnly, eleveurOrAdmin } = require('../middlewares/auth');

router.post('/auth/login', authController.login);
router.post('/auth/register', authMiddleware, adminOnly, authController.register);
router.get('/auth/me', authMiddleware, authController.getMe);

router.get('/sensors', authMiddleware, sensorController.getAllSensors);
router.get('/sensors/latest', authMiddleware, sensorController.getLatestData);
router.get('/sensors/:id/data', authMiddleware, sensorController.getSensorData);
router.post('/sensors/data', sensorController.postSensorData);

router.get('/actuators', authMiddleware, actuatorController.getAllActuators);
router.put('/actuators/:id/control', authMiddleware, eleveurOrAdmin, actuatorController.controlActuator);
router.get('/actuators/:id/logs', authMiddleware, actuatorController.getActuatorLogs);

router.get('/alerts', authMiddleware, alertController.getAlerts);
router.post('/alerts', authMiddleware, alertController.createAlert);
router.put('/alerts/:id/acknowledge', authMiddleware, alertController.acknowledgeAlert);
router.get('/alerts/rules', authMiddleware, alertController.getAlertRules);

module.exports = router;