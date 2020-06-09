var express = require('express');
var router = express.Router();

router.get('/status', (req, res) => {
	res.send('active');
});

module.exports = router;
