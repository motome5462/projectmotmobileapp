const express = require('express');
const cors = require('cors');
const authController = require('./src/controllers/authController');
const productController = require('./src/controllers/productController');

const app = express();
app.use(cors());
app.use(express.json());

// Auth Routes
app.post('/api/login', authController.login);
app.post('/api/logout', authController.logout);

// Product Routes
app.get('/api/products', productController.getProducts);
app.post('/api/stock-in', productController.updateStockIn);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});