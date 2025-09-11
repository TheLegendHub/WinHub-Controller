const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors'); // Import the cors middleware

        // Define the sendUsername function
 const boysLabIPs = ['169.254.17.207','169.254.3.84','169.254.6.116','169.254.2.68','169.254.6.116','169.254.1.246','169.254.2.193','169.254.1.243','169.254.4.7','169.254.1.181','169.254.2.108','169.254.11.63','169.254.16.24','169.254.5.4','169.254.2.133','169.254.5.94','169.254.5.6','169.254.11.70']; // Add all Boys Lab IP addresses
 const girlsLabIPs = ['0']; // Add all Girls Lab IP addresses
const app = express();
const port = 3000;

// Middleware to enable CORS
app.use(cors());

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Endpoint to handle incoming username and IP submissions
app.post('/submit-username', (req, res) => {
    const { username, ip } = req.body;
    console.log('Received username:', username);
    console.log('Received IP:', ip);
   if (boysLabIPs.includes(ip)) {
        console.log('This IP belongs to Boys Lab.');
        // Handle Boys Lab IP address
        // You can perform any specific actions for Boys Lab here
    } else if (girlsLabIPs.includes(ip)) {
        console.log('This IP belongs to Girls Lab.');
        // Handle Girls Lab IP address
        // You can perform any specific actions for Girls Lab here
    } else {
        console.log('Unknown IP.');
        // Handle other IP addresses
    }

    // You can process the username and IP here (store them in a database, etc.)
    res.json({ message: 'Username and IP received successfully' });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
});
