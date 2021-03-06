// 
// This file is part of PiSleepTalk.
// Learn more at: https://github.com/blaues0cke/PiSleepTalk
// 
// Author:  Thomas Kekeisen <pisleeptalk@tk.ca.kekeisen.it>
// License: This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
//          To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
//

var fs = require('fs');

var alphanumeric = function (input) {  
	// Thanks to
	// * http://www.w3resource.com/javascript/form/letters-numbers-field.php
	var letterNumber = /^[0-9a-zA-Z_\-\.]+$/;

	return input.match(letterNumber);
};

this.alphanumeric = alphanumeric;

this.checkFile = function (req, res, ending, path) {
	console.log('Checking file name', req.params);

	if (req.params.name && alphanumeric(req.params.name)) {
		var pathList = [];

		// Thanks to
		// * http://stackoverflow.com/questions/4775722/check-if-object-is-array
		if (Object.prototype.toString.call(path) === '[object Array]') {
    		pathList = path;

    		path = pathList[0];

    		pathList.shift();
		}

		// Thanks to
		// * http://stackoverflow.com/questions/8181879/nodejs-setting-up-wildcard-routes-or-url-rewrite
		var filepath = path + '/' + req.params.name + (ending ? '.' + ending : '');

		if (fs.existsSync(filepath)) {
			return filepath;
		}
		else {
			if (pathList.length > 0)
			{
				console.log('Path error, tryin to fallback', pathList);

				return this.checkFile(req, res, ending, pathList);
			}

			// Thanks to
			// * http://stackoverflow.com/questions/8393275/how-to-programmatically-send-a-404-response-with-express-node
			res.status(404).send('Sorry, file not found. "' + filepath + '" does not exist on server.');
		}
	}
	else {
		res.status(500).send('Malformed filename. Stop tryin to hack this server.');
	}
		
	return false;
};