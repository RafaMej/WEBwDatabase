const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Conexión a la base de datos
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME
});

// Ruta: Obtener todos los usuarios
app.get('/users', (req, res) => {
    db.query("SELECT * FROM users", (err, results) => {
        if (err) return res.status(500).send(err);
        res.json(results);
    });
});

// Ruta: Agregar usuario
app.post('/users', (req, res) => {
    const { name, email } = req.body;
    db.query("INSERT INTO users (name, email) VALUES (?, ?)", [name, email], (err, result) => {
        if (err) return res.status(500).send(err);
        res.json({ id: result.insertId, name, email });
    });
});

// Ruta: Editar usuario
app.put('/users/:id', (req, res) => {
    const { id } = req.params;
    const { name, email } = req.body;
    db.query("UPDATE users SET name = ?, email = ? WHERE id = ?", [name, email, id], (err) => {
        if (err) return res.status(500).send(err);
        res.send("Usuario actualizado");
    });
});

// Ruta: Eliminar usuario
app.delete('/users/:id', (req, res) => {
    const { id } = req.params;
    db.query("DELETE FROM users WHERE id = ?", [id], (err) => {
        if (err) return res.status(500).send(err);
        res.send("Usuario eliminado");
    });
});

// Iniciar servidor
app.listen(3000, () => console.log('Servidor corriendo en http://localhost:3000'));