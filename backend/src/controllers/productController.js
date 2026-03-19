// src/controllers/productController.js
const db = require('../config/db');

exports.getProducts = async (req, res) => {
    try {
        const [products] = await db.execute(`
            SELECT p.*, c.cat_name 
            FROM Products p
            LEFT JOIN Categories c ON p.cat_id = c.cat_id
        `);
        res.json(products);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updateStockIn = async (req, res) => {
    const { pro_id, qty, receiver_id } = req.body;
    try {
        // 1. เพิ่มข้อมูลใน Stock_In
        await db.execute('INSERT INTO Stock_In (pro_id, qty_in, receiver_id) VALUES (?, ?, ?)', [pro_id, qty, receiver_id]);
        
        // 2. อัปเดต Stock ปัจจุบัน
        await db.execute('UPDATE Products SET current_stock = current_stock + ? WHERE pro_id = ?', [qty, pro_id]);

        // 3. บันทึก Log การเคลื่อนไหว
        const [prod] = await db.execute('SELECT current_stock FROM Products WHERE pro_id = ?', [pro_id]);
        await db.execute('INSERT INTO Stock_Logs (pro_id, action_type, qty, balance_after, ref_id) VALUES (?, "IN", ?, ?, "STOCK-IN")', 
            [pro_id, qty, prod[0].current_stock]);

        res.json({ message: "รับสินค้าเข้าสำเร็จ" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};