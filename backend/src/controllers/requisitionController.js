// src/controllers/requisitionController.js
const db = require('../config/db');

// 1. สร้างใบเบิกสินค้า (Requester)
exports.createRequisition = async (req, res) => {
    const { user_id, dept_id, reason, items } = req.body; // items คือ Array ของ {pro_id, qty}
    
    try {
        // เริ่ม Transaction เพื่อความปลอดภัยของข้อมูล
        const conn = await db.getConnection();
        await conn.beginTransaction();

        try {
            // เพิ่มหัวใบเบิก
            const [header] = await conn.execute(
                'INSERT INTO Requisitions (user_id, dept_id, reason, status) VALUES (?, ?, ?, "Pending")',
                [user_id, dept_id, reason]
            );
            const req_id = header.insertId;

            // เพิ่มรายการสินค้า
            for (let item of items) {
                await conn.execute(
                    'INSERT INTO Requisition_Details (req_id, pro_id, qty_requested) VALUES (?, ?, ?)',
                    [req_id, item.pro_id, item.qty]
                );
            }

            await conn.commit();
            res.json({ message: "ส่งคำขอเบิกสำเร็จ", req_id });
        } catch (err) {
            await conn.rollback();
            throw err;
        } finally {
            conn.release();
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// 2. อนุมัติใบเบิก และ ตัดสต๊อกอัตโนมัติ (Approver)
exports.approveRequisition = async (req, res) => {
    const { req_id, approver_id, status, note } = req.body; // status: 'Approved' หรือ 'Rejected'

    try {
        const conn = await db.getConnection();
        await conn.beginTransaction();

        try {
            // อัปเดตสถานะใบเบิก
            await conn.execute(
                'UPDATE Requisitions SET status = ?, approver_id = ?, approve_note = ?, approve_date = NOW() WHERE req_id = ?',
                [status, approver_id, note, req_id]
            );

            // ถ้าอนุมัติ ให้ทำการตัดสต๊อก
            if (status === 'Approved') {
                const [details] = await conn.execute('SELECT pro_id, qty_requested FROM Requisition_Details WHERE req_id = ?', [req_id]);
                
                for (let item of details) {
                    // ตรวจสอบสต๊อกก่อนตัด
                    const [prod] = await conn.execute('SELECT current_stock FROM Products WHERE pro_id = ?', [item.pro_id]);
                    if (prod[0].current_stock < item.qty_requested) {
                        throw new Error(`สินค้ารหัส ${item.pro_id} มีจำนวนไม่พอ`);
                    }

                    // ตัดสต๊อก
                    await conn.execute('UPDATE Products SET current_stock = current_stock - ? WHERE pro_id = ?', [item.qty_requested, item.pro_id]);

                    // บันทึก Stock Log (OUT)
                    const [newStock] = await conn.execute('SELECT current_stock FROM Products WHERE pro_id = ?', [item.pro_id]);
                    await conn.execute(
                        'INSERT INTO Stock_Logs (pro_id, action_type, qty, balance_after, ref_id) VALUES (?, "OUT", ?, ?, ?)',
                        [item.pro_id, item.qty_requested, newStock[0].current_stock, `REQ-${req_id}`]
                    );
                }
            }

            await conn.commit();
            res.json({ message: `จัดการคำขอเรียบร้อยแล้ว (${status})` });
        } catch (err) {
            await conn.rollback();
            res.status(400).json({ error: err.message });
        } finally {
            conn.release();
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};