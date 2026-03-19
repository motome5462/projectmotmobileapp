// src/controllers/authController.js
const db = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
    const { username, password } = req.body;
    const ipAddress = req.ip;
    const userAgent = req.headers['user-agent'];

    try {
        // 1. ตรวจสอบ User และดึงข้อมูล Role/Dept
        const [users] = await db.execute(`
            SELECT u.*, a.password_hash 
            FROM Users u 
            JOIN User_Auth a ON u.user_id = a.user_id 
            WHERE a.username = ? AND u.is_active = 1
        `, [username]);

        if (users.length === 0) return res.status(401).json({ message: "ไม่พบผู้ใช้งานนี้" });

        const user = users[0];

        // 2. ตรวจสอบรหัสผ่าน
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) return res.status(401).json({ message: "รหัสผ่านไม่ถูกต้อง" });

        // 3. สร้าง JWT Token
        const token = jwt.sign(
            { user_id: user.user_id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        // 4. บันทึก Login_Logs
        const [logResult] = await db.execute(`
            INSERT INTO Login_Logs (user_id, action, ip_address, user_agent) 
            VALUES (?, 'Login', ?, ?)
        `, [user.user_id, ipAddress, userAgent]);

        // 5. อัปเดตเวลา Last Login ใน User_Auth
        await db.execute('UPDATE User_Auth SET last_login_at = NOW() WHERE user_id = ?', [user.user_id]);

        res.json({
            token,
            log_id: logResult.insertId, // ส่งกลับเพื่อให้ Flutter ใช้ตอน Logout
            user: {
                id: user.user_id,
                name: user.full_name,
                role: user.role,
                dept_id: user.dept_id
            }
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.logout = async (req, res) => {
    const { log_id } = req.body; // รับ log_id จาก Flutter
    try {
        // อัปเดต logout_timestamp ใน Login_Logs
        await db.execute('UPDATE Login_Logs SET logout_timestamp = NOW(), action = "Logout" WHERE log_id = ?', [log_id]);
        res.json({ message: "ออกจากระบบสำเร็จ" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.register = async (req, res) => {
    const { username, password, full_name, role, dept_id } = req.body;
    try {
        // 1. Hash รหัสผ่าน
        const hashedPassword = await bcrypt.hash(password, 10);

        // 2. บันทึกข้อมูลลงตาราง Users
        const [userResult] = await db.execute(
            'INSERT INTO Users (full_name, role, dept_id) VALUES (?, ?, ?)',
            [full_name, role, dept_id]
        );

        // 3. บันทึกข้อมูลลงตาราง User_Auth
        await db.execute(
            'INSERT INTO User_Auth (user_id, username, password_hash) VALUES (?, ?, ?)',
            [userResult.insertId, username, hashedPassword]
        );

        res.json({ message: "ลงทะเบียนผู้ใช้สำเร็จ!" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};