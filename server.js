const express = require('express');
const mysql = require('mysql2');
const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session);
const http = require('http');
const { Server } = require('socket.io');
const multer = require('multer');
const path = require('path');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
app.set('trust proxy', 1); // Confía en el proxy de ngrok
const server = http.createServer(app);
const io = new Server(server);
const port = 3000;

// ─── CONEXIÓN BASE DE DATOS ───────────────────────────────────────────────────
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'yjmrepair_db'
};
app.use((req, res, next) => {
    res.setHeader('ngrok-skip-browser-warning', 'true');
    next();
});

const oConexion = mysql.createConnection(dbConfig);

oConexion.connect((err) => {
    if (err) {
        console.error('Error conectando a la base de datos:', err.stack);
        return;
    }
    console.log('Conectado a la base de datos yjmrepair_db');
    
    // Crear tabla de repuestos si no existe
    const sqlRepuestos = `
        CREATE TABLE IF NOT EXISTS repuestos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(255) NOT NULL,
            modelo_compatible VARCHAR(255),
            cantidad INT DEFAULT 0,
            precio_compra DECIMAL(10, 2),
            precio_venta DECIMAL(10, 2),
            creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    `;
    oConexion.query(sqlRepuestos, (errR) => {
        if (errR) console.error("Error creando tabla repuestos:", errR);
    });

    const sqlEntregas = `
        CREATE TABLE IF NOT EXISTS entregas (
            id INT AUTO_INCREMENT PRIMARY KEY,
            orden_id INT,
            quien_retira VARCHAR(255),
            metodo_pago VARCHAR(50),
            fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    `;
    oConexion.query(sqlEntregas, (err) => {
        if (err) console.error("Error creando entregas:", err);
    });

    // --- NUEVAS TABLAS: COTIZACIONES Y CAJA ---
    const sqlCotizaciones = `
        CREATE TABLE IF NOT EXISTS cotizaciones (
            id INT AUTO_INCREMENT PRIMARY KEY,
            codigo VARCHAR(50) NOT NULL,
            cliente_nombre VARCHAR(255) NOT NULL,
            cliente_telefono VARCHAR(50),
            equipo VARCHAR(255) NOT NULL,
            falla_descripcion TEXT,
            valor_estimado DECIMAL(10, 2) NOT NULL,
            fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            creado_por INT
        )
    `;
    oConexion.query(sqlCotizaciones, (err) => {
        if (err) console.error("Error creando cotizaciones:", err);
    });

    const sqlCaja = `
        CREATE TABLE IF NOT EXISTS caja_diaria (
            id INT AUTO_INCREMENT PRIMARY KEY,
            fecha_apertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            fecha_cierre TIMESTAMP NULL,
            monto_inicial DECIMAL(10, 2) DEFAULT 0,
            estado ENUM('abierta', 'cerrada') DEFAULT 'abierta',
            abierta_por INT,
            cerrada_por INT
        )
    `;
    oConexion.query(sqlCaja, (err) => {
        if (err) console.error("Error creando caja_diaria:", err);
    });

    const sqlTransacciones = `
        CREATE TABLE IF NOT EXISTS transacciones_caja (
            id INT AUTO_INCREMENT PRIMARY KEY,
            caja_id INT NOT NULL,
            tipo ENUM('ingreso', 'egreso') NOT NULL,
            concepto VARCHAR(255) NOT NULL,
            monto DECIMAL(10, 2) NOT NULL,
            metodo_pago VARCHAR(50) DEFAULT 'efectivo',
            usuario_id INT,
            fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (caja_id) REFERENCES caja_diaria(id)
        )
    `;
    oConexion.query(sqlTransacciones, (err) => {
        if (err) console.error("Error creando transacciones_caja:", err);
    });
});

// ─── SESIONES ─────────────────────────────────────────────────────────────────
const sessionStore = new MySQLStore({}, oConexion.promise());
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
// --- MEJORAS DE SEGURIDAD (HELMET) ---
// Helmet blinda las cabeceras HTTP contra ataques como Clickjacking y XSS.
// Desactivamos CSP temporalmente para no bloquear los scripts inline de Socket.io en EJS.
app.use(helmet({
    contentSecurityPolicy: false,
}));

app.use((req, res, next) => {
    res.set('Cache-Control', 'no-cache, private, no-store, must-revalidate, max-stale=0, post-check=0, pre-check=0');
    next();
});

// --- SEGURIDAD DE SESIÓN ---
app.use(session({
    secret: process.env.SESSION_SECRET || 'fallback_secreto_temporal',
    resave: false,
    saveUninitialized: false,
    store: sessionStore,
    cookie: {
        httpOnly: true, // Evita que JS en el navegador robe la cookie (Protección XSS)
        sameSite: 'lax', // Protege contra ataques CSRF (Cross-Site Request Forgery)
        maxAge: 1000 * 60 * 60 * 24 // La sesión expira en 24 horas
    }
}));

// ─── MOTOR DE VISTAS ──────────────────────────────────────────────────────────
app.set('view engine', 'ejs');
app.use(express.static('public'));

// ─── SUBIDA DE FOTOS (igual a tu proyecto anterior con multer) ────────────────
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const unique = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, unique + path.extname(file.originalname));
    }
});
const upload = multer({ storage });
app.use('/uploads', express.static('uploads'));

// ─── MIDDLEWARES (igual estructura que tu proyecto) ───────────────────────────
function authMiddleware(req, res, next) {
    if (req.session.userId) {
        // Consultamos rol y nombre para asegurar que la sesión es fresca
        const sql = 'SELECT nombre, rol FROM usuarios WHERE id = ?';
        oConexion.query(sql, [req.session.userId], (error, results) => {
            if (error) throw error;
            if (results.length > 0) {
                req.user = results[0];
                res.locals.user = results[0]; // Permite usar 'user' en todos los EJS
                next();
            } else {
                // Si el ID de sesión no existe en la DB, destruimos todo
                req.session.destroy(() => {
                    res.clearCookie('connect.sid');
                    res.redirect('/login');
                });
            }
        });
    } else {
        res.redirect('/login');
    }
}

function adminMiddleware(req, res, next) {
    if (req.session.rol === 'admin') {
        next();
    } else {
        res.redirect('/panel');
    }
}

// ─── HELPER: generar código de orden ─────────────────────────────────────────
function generarCodigo() {
    const fecha = new Date();
    const anio = fecha.getFullYear();
    // Genera un número de 6 dígitos en lugar de 3 para evitar duplicados
    const rand = Math.floor(Math.random() * 900000) + 100000;
    return `TRP-${anio}-${rand}`;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  RUTAS PÚBLICAS
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/', (req, res) => res.redirect('/login'));

app.get('/login', (req, res) => res.render('login'));

app.get('/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) console.log(err);
        res.clearCookie('connect.sid'); // Borra la cookie del navegador
        res.set('Cache-Control', 'no-cache, private, no-store, must-revalidate'); // Refuerzo de salida
        res.redirect('/login');
    });
});

// Seguimiento público del cliente (acceso por link sin login)
app.get('/r/:codigo', (req, res) => {
    const codigo = req.params.codigo;
    const sql = 'SELECT * FROM ordenes WHERE codigo = ?';
    oConexion.query(sql, [codigo], (error, results) => {
        if (error) throw error;
        if (results.length === 0) return res.send('Orden no encontrada');
        const orden = results[0];

        // Traer fotos, mensajes y fallas extra
        const sqlFotos    = 'SELECT * FROM fotos WHERE orden_id = ? ORDER BY subida_en ASC';
        const sqlMensajes = 'SELECT * FROM mensajes WHERE orden_id = ? ORDER BY enviado_en ASC';
        const sqlFallas   = 'SELECT * FROM fallas_extra WHERE orden_id = ?';
        const sqlTels     = 'SELECT * FROM telefonos_venta WHERE disponible = 1';

        oConexion.query(sqlFotos, [orden.id], (e1, fotos) => {
            oConexion.query(sqlMensajes, [orden.id], (e2, mensajes) => {
                oConexion.query(sqlFallas, [orden.id], (e3, fallas) => {
                    oConexion.query(sqlTels, [], (e4, telefonos) => {
                        res.render('seguimiento', {
                            orden, fotos, mensajes, fallas, telefonos
                        });
                    });
                });
            });
        });
    });
});
// --- NUEVA RUTA: Link de gestión rápida para el TÉCNICO ---
app.get('/t/:codigo', (req, res) => {
    const codigo = req.params.codigo;
    const sql = 'SELECT * FROM ordenes WHERE codigo = ?';
    
    oConexion.query(sql, [codigo], (error, results) => {
        if (error) throw error;
        if (results.length === 0) return res.send('Orden no encontrada');
        
        const orden = results[0];

        // Traemos toda la info para que el técnico gestione (igual que en /orden/:id)
        const sqlFotos    = 'SELECT * FROM fotos WHERE orden_id = ? ORDER BY subida_en ASC';
        const sqlMensajes = 'SELECT * FROM mensajes WHERE orden_id = ? ORDER BY enviado_en ASC';
        const sqlFallas   = 'SELECT * FROM fallas_extra WHERE orden_id = ?';

        oConexion.query(sqlFotos, [orden.id], (e1, fotos) => {
            oConexion.query(sqlMensajes, [orden.id], (e2, mensajes) => {
                oConexion.query(sqlFallas, [orden.id], (e3, fallas) => {
                    // Renderizamos 'orden' (la vista con botones de acción)
                    // Pasamos un usuario ficticio para que el EJS no de error
                    res.render('orden', {
                        orden, 
                        fotos, 
                        mensajes, 
                        fallas, 
                        user: { nombre: 'Técnico Externo', rol: 'tecnico' } 
                    });
                });
            });
        });
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  LOGIN Y SEGURIDAD CONTRA FUERZA BRUTA
// ═══════════════════════════════════════════════════════════════════════════════

// --- MEJORA DE SEGURIDAD (RATE LIMITING) ---
// Bloquea temporalmente a cualquier bot o IP que intente adivinar contraseñas
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutos de penalización
    max: 5, // Bloquea después de 5 intentos fallidos
    message: 'Demasiados intentos de inicio de sesión desde esta IP, por favor intenta nuevamente en 15 minutos.',
    standardHeaders: true, 
    legacyHeaders: false,
    validate: { xForwardedForHeader: false }
});

app.post('/empezar', loginLimiter, (req, res) => {
    const { email, password } = req.body;
    const sql = 'SELECT * FROM usuarios WHERE email = ?';
    oConexion.query(sql, [email], async (error, results) => {
        if (error) throw error;
        if (results.length === 0) return res.render('login', { error: 'Usuario no encontrado' });

        const usuario = results[0];
        const match = await bcrypt.compare(password, usuario.password);
        if (!match) return res.render('login', { error: 'Contraseña incorrecta' });

        req.session.userId = usuario.id;
        req.session.rol = usuario.rol;

       if (usuario.rol === 'admin') {
        res.redirect('/admin');
        } else {
            res.redirect('/panel');
        }
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  PANEL PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/panel', authMiddleware, (req, res) => {
    const sqlStats = `
        SELECT
            SUM(estado = 'taller')     AS en_taller,
            SUM(estado = 'reparacion') AS en_reparacion,
            SUM(estado = 'listo')      AS listos,
            COUNT(*)                   AS total
        FROM ordenes WHERE estado != 'entregado'
    `;
    const sqlRecientes = "SELECT * FROM ordenes WHERE estado != 'entregado' ORDER BY fecha_ingreso DESC LIMIT 6";
    const sqlTelefonos = 'SELECT * FROM telefonos_venta WHERE disponible = 1';

    oConexion.query(sqlStats, (e1, stats) => {
        oConexion.query(sqlRecientes, (e2, ordenes) => {
            oConexion.query(sqlTelefonos, (e3, telefonos) => {
                res.render('panel', {
                    user: req.user,
                    stats: stats[0],
                    ordenes,
                    telefonos
                });
            });
        });
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  ÓRDENES
// ═══════════════════════════════════════════════════════════════════════════════

/// --- ESTA DEBE SER LA ÚNICA RUTA /ORDENES EN TU SERVER.JS ---
app.get('/ordenes', authMiddleware, (req, res) => {
    // 1. Limpiamos el texto que viene de la URL
    const buscar = (req.query.q || '').trim().toLowerCase();
    
    // 2. SQL: Usamos LOWER para que no importe mayúsculas/minúsculas
    // Buscamos en Nombre, Código, Modelo Y Estado
    const sql = `
        SELECT * FROM ordenes 
        WHERE LOWER(cliente_nombre) LIKE ? 
           OR LOWER(codigo) LIKE ? 
           OR LOWER(equipo_modelo) LIKE ? 
           OR LOWER(estado) LIKE ?
        ORDER BY fecha_ingreso DESC`;

    const filtro = `%${buscar}%`;

    oConexion.query(sql, [filtro, filtro, filtro, filtro], (err, results) => {
        if (err) {
            console.error("Error SQL:", err);
            return res.status(500).send("Error de base de datos");
        }

        // Renderizamos enviando los resultados y el término 'buscar'
        res.render('ordenes', {
            user: req.user,
            ordenes: results,
            buscar: buscar, // Esto activa el color del botón
            active: 'ordenes'
        });
    });
});
// este crea el informe de las ordenes en qr
     app.get('/informe/:codigo', authMiddleware, (req, res) => {
    const codigo = req.params.codigo;
    const sql = 'SELECT * FROM ordenes WHERE codigo = ?';
    oConexion.query(sql, [codigo], (err, results) => {
        if (err || results.length === 0) return res.redirect('/panel?error=no_encontrado');
        const orden = results[0];
        
        // Consultas para traer fotos y fallas extra para el informe
        const sqlFotos = 'SELECT * FROM fotos WHERE orden_id = ?';
        const sqlFallas = 'SELECT * FROM fallas_extra WHERE orden_id = ? AND aceptada = 1';
        
        oConexion.query(sqlFotos, [orden.id], (err2, fotos) => {
            oConexion.query(sqlFallas, [orden.id], (err3, fallas) => {
                res.render('informe-tecnico', { orden, fotos, fallas, user: req.user });
            });
        });
    });
});
// Ver detalle de una orden
app.get('/orden/:id', authMiddleware, (req, res) => {
    const id = req.params.id;
    const sqlOrden    = 'SELECT * FROM ordenes WHERE id = ?';
    const sqlFotos    = 'SELECT * FROM fotos WHERE orden_id = ? ORDER BY subida_en ASC';
    const sqlMensajes = 'SELECT * FROM mensajes WHERE orden_id = ? ORDER BY enviado_en ASC';
    const sqlFallas   = 'SELECT * FROM fallas_extra WHERE orden_id = ?';

    oConexion.query(sqlOrden, [id], (e1, ordenes) => {
        if (ordenes.length === 0) return res.redirect('/ordenes');
        oConexion.query(sqlFotos, [id], (e2, fotos) => {
            oConexion.query(sqlMensajes, [id], (e3, mensajes) => {
                oConexion.query(sqlFallas, [id], (e4, fallas) => {
                    res.render('orden', {
                        orden: ordenes[0], fotos, mensajes, fallas, user: req.user
                    });
                });
            });
        });
    });
});

// Buscar por código de barras
app.get('/buscar-codigo', authMiddleware, (req, res) => {
    const codigo = req.query.codigo;
    const sql = 'SELECT id FROM ordenes WHERE codigo = ?';
    oConexion.query(sql, [codigo], (error, results) => {
        if (error) throw error;
        if (results.length > 0) {
            res.redirect('/orden/' + results[0].id);
        } else {
            res.redirect('/ordenes?error=no_encontrado');
        }
    });
});

// Formulario nueva orden (GET)
// ESTA ES LA RUTA QUE TE FALTABA
app.get('/nueva-orden', authMiddleware, (req, res) => {
    res.render('nueva-orden', { user: req.user });
});
// ─── GUARDAR NUEVA ORDEN (POST) ───────────────────────────────────────────────
app.post('/crear-orden', authMiddleware, upload.fields([
    { name: 'foto_frontal', maxCount: 1 },
    { name: 'foto_trasera', maxCount: 1 },
    { name: 'foto_cargando', maxCount: 1 },
    { name: 'fotos_extra', maxCount: 5 }
]), (req, res) => {
    const {
        cliente_nombre, cliente_telefono, cliente_email, contacto,
        equipo_tipo, equipo_marca, equipo_modelo, equipo_password,
        falla_descripcion, costo_estimado
    } = req.body;

    const codigo = generarCodigo();
    const barcodeValue = `${codigo}-${cliente_nombre.substring(0, 2).toUpperCase()}`;

    const sql = `INSERT INTO ordenes
        (codigo, cliente_nombre, cliente_telefono, cliente_email, contacto,
         equipo_tipo, equipo_marca, equipo_modelo, equipo_password,
         falla_descripcion, costo_estimado, costo_total, estado)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`;

    oConexion.query(sql, [
        codigo, cliente_nombre, cliente_telefono, cliente_email, contacto,
        equipo_tipo, equipo_marca, equipo_modelo, equipo_password,
        falla_descripcion, costo_estimado, costo_estimado, 'taller'
    ], (error, result) => {
        if (error) {
            console.error("Error al insertar orden:", error);
            return res.status(500).send("Error al crear la orden");
        }
        
        const ordenId = result.insertId;
// >>> ESTO ES LO QUE ESTAMOS AGREGANDO <<<
        function normalizarTexto(str) {
            if (!str) return '';
            return str
                .trim()
                .normalize("NFD").replace(/[\u0300-\u036f]/g, "") // Quita acentos
                .toLowerCase()
                .replace(/\b\w/g, l => l.toUpperCase()); // Primera letra mayúscula
        }

        const tipoLimpio = normalizarTexto(equipo_tipo);
        const marcaLimpia = normalizarTexto(equipo_marca);
        const modeloLimpio = normalizarTexto(equipo_modelo);

        const sqlCatalogo = 'INSERT IGNORE INTO catalogo_equipos (tipo, marca, modelo) VALUES (?, ?, ?)';
        oConexion.query(sqlCatalogo, [tipoLimpio, marcaLimpia, modeloLimpio], (errCat) => {
            if (errCat) console.error("Error al actualizar catálogo:", errCat);
        });
        // >>> FIN DE LA AGREGRACIÓN <<<
        // --- PROCESAMIENTO DE FOTOS ---
        const fotos = [];
        ['foto_frontal', 'foto_trasera', 'foto_cargando'].forEach(tipo => {
            if (req.files && req.files[tipo]) {
                fotos.push([ordenId, req.files[tipo][0].filename, tipo]);
            }
        });   

        if (req.files && req.files['fotos_extra']) {
            req.files['fotos_extra'].forEach(f => {
                fotos.push([ordenId, f.filename, 'extra']);
            });
        }

        if (fotos.length > 0) {
            const sqlFotos = 'INSERT INTO fotos (orden_id, archivo, tipo) VALUES ?';
            oConexion.query(sqlFotos, [fotos], (e) => { if (e) console.error("Error fotos:", e); });
        }

        // --- LÓGICA DE NOTIFICACIÓN PÚBLICA (NGROK) ---
        // 1. Definir dominios y links (Detección automática desde .env)
        const dominioPublico = process.env.DOMAIN_URL || `http://localhost:${port}`;

const linkSeguimiento = `${dominioPublico}/r/${codigo}`;
const linkTecnicoDirecto = `${dominioPublico}/t/${codigo}`;

// 2. Notificación para el CLIENTE (linkWtp)
let linkWtp = null;
if (contacto === 'WhatsApp') {
    const fonoLimpio = cliente_telefono.replace(/\D/g, '');
    const mensajeCli = 
        `*YJMREPAIR PRO* 🛠️\n\n` +
        `Hola *${cliente_nombre}*! 👋\n` +
        `Hemos recibido tu equipo: *${equipo_marca} ${equipo_modelo}*.\n\n` +
        `Puedes seguir el estado de tu reparación en tiempo real haciendo clic aquí:\n` +
        `👉 ${linkSeguimiento}\n\n` +
        `_Te avisaremos por este medio cualquier novedad._`;

    linkWtp = `https://wa.me/${fonoLimpio}?text=${encodeURIComponent(mensajeCli)}`;
}
// ... (el resto del código de notificaciones sigue igual)

        // 3. Notificación para el TÉCNICO (linkWtpTecnico)
        const fonoTecnico = process.env.TELEFONO_TECNICO || '';
        const mensajeTec = 
            `🛠️ *ASIGNACIÓN DE ORDEN*\n\n` +
            `*Equipo:* ${equipo_marca} ${equipo_modelo}\n` +
            `*Falla:* ${falla_descripcion}\n\n` +
            `*Gestionar aquí:* \n` +
            `👉 ${linkTecnicoDirecto}`;
            
        const linkWtpTecnico = `https://wa.me/${fonoTecnico}?text=${encodeURIComponent(mensajeTec)}`;

        // 4. Configuración de Correo Real (Nodemailer)
        if (contacto === 'Correo' && cliente_email && cliente_email.trim() !== '') {
            const mailOptions = {
                from: '"YJMRepair Pro" <ronaldoyony@gmail.com>', 
                to: cliente_email,
                subject: `Confirmación de Ingreso: Orden ${codigo}`,
                html: `
                    <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px; max-width: 500px;">
                        <h2 style="color: #185FA5;">¡Hola ${cliente_nombre}!</h2>
                        <p>Hemos recibido tu <strong>${equipo_marca} ${equipo_modelo}</strong> correctamente en nuestro taller.</p>
                        <p>Para tu tranquilidad, puedes ver fotos del proceso y chatear con el técnico en tiempo real haciendo clic en el siguiente botón:</p>
                        <div style="text-align: center; margin: 30px 0;">
                            <a href="${linkSeguimiento}" style="background-color: #185FA5; color: white; padding: 15px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block;">
                                VER MI REPARACIÓN EN VIVO
                            </a>
                        </div>
                        <p style="font-size: 12px; color: #888;">Si no puedes hacer clic, copia este link: ${linkSeguimiento}</p>
                        <hr style="border: 0; border-top: 1px solid #eee;">
                        <p style="font-size: 11px; color: #aaa;">YJMRepair Pro - Servicio Técnico Especializado</p>
                    </div>`
            };

            transporter.sendMail(mailOptions, (err, info) => {
                if (err) console.error("Error enviando correo:", err);
                else console.log("Correo enviado con éxito a: " + cliente_email);
            });
        }

        // --- RENDER DE CONFIRMACIÓN ---
        res.render('confirmacion-registro', { 
            user: req.user, 
            orden: {
                id: ordenId,
                codigo: codigo,
                cliente_nombre: cliente_nombre,
                equipo_marca: equipo_marca,
                equipo_modelo: equipo_modelo,
                cliente_email: cliente_email,
                contacto: contacto
            },
            barcodeData: barcodeValue,
            linkWtp: linkWtp,
            linkWtpTecnico: linkWtpTecnico, // Enviamos el link ya armado
            dominio: dominioPublico         // Enviamos el dominio para evitar el error de ReferenceError
        });
    });
});
//agrego nuevos modelos de equipo y tegno un registro de todos los modelos 
app.get('/api/catalogo-equipos', authMiddleware, (req, res) => {
    const sql = 'SELECT * FROM catalogo_equipos ORDER BY tipo, marca, modelo';
    oConexion.query(sql, (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});
// Actualizar estado de una orden
app.post('/actualizar-estado', authMiddleware, (req, res) => {
    const { orden_id, estado } = req.body;
    const sql = 'UPDATE ordenes SET estado = ? WHERE id = ?';
    oConexion.query(sql, [estado, orden_id], (error) => {
        if (error) throw error;
        // Notificar en tiempo real al cliente
        io.to('orden_' + orden_id).emit('estado_actualizado', { estado });
        res.redirect('/orden/' + orden_id);
    });
});

// Registrar entrega
app.post('/entregar-orden', authMiddleware, (req, res) => {
    const { orden_id, quien_retira, metodo_pago } = req.body;
    
    // 1. Insertar en entregas
    const sqlInsert = 'INSERT INTO entregas (orden_id, quien_retira, metodo_pago) VALUES (?, ?, ?)';
    oConexion.query(sqlInsert, [orden_id, quien_retira, metodo_pago], (error) => {
        if (error) return res.status(500).send("Error al registrar entrega");
        
        // 2. Actualizar estado a entregado
        oConexion.query("UPDATE ordenes SET estado = 'entregado' WHERE id = ?", [orden_id], (err) => {
            if (err) return res.status(500).send("Error actualizando estado");
            
            // 3. Buscar datos de la orden para armar el mensaje de confirmación
            oConexion.query('SELECT * FROM ordenes WHERE id = ?', [orden_id], (err2, results) => {
                if (err2 || results.length === 0) return res.redirect('/panel');
                
                const orden = results[0];
                const dominioPublico = process.env.DOMAIN_URL || `http://localhost:${port}`;
                const linkCartola = `${dominioPublico}/comprobante-entrega/${orden.id}`;
                
                let linkWtp = null;
                if (orden.contacto === 'WhatsApp') {
                    const fonoLimpio = orden.cliente_telefono.replace(/\D/g, '');
                    const mensajeCli = 
                        `*YJMREPAIR PRO* 🛠️\n\n` +
                        `Hola *${orden.cliente_nombre}*! 👋\n` +
                        `Tu equipo *${orden.equipo_marca} ${orden.equipo_modelo}* ha sido entregado exitosamente.\n\n` +
                        `📄 Puedes ver y descargar tu **Comprobante de Entrega y Garantía** haciendo clic en el siguiente enlace:\n` +
                        `👉 ${linkCartola}\n\n` +
                        `¡Gracias por confiar en nosotros!`;

                    linkWtp = `https://wa.me/${fonoLimpio}?text=${encodeURIComponent(mensajeCli)}`;
                }
                
                if (orden.contacto === 'Correo' && orden.cliente_email && orden.cliente_email.trim() !== '') {
                    const mailOptions = {
                        from: '"YJMRepair Pro" <ronaldoyony@gmail.com>', 
                        to: orden.cliente_email,
                        subject: `Comprobante de Entrega: Orden ${orden.codigo}`,
                        html: `
                            <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px; max-width: 500px;">
                                <h2 style="color: #185FA5;">¡Gracias por tu preferencia, ${orden.cliente_nombre}!</h2>
                                <p>Tu equipo <strong>${orden.equipo_marca} ${orden.equipo_modelo}</strong> ha sido entregado exitosamente.</p>
                                <div style="text-align: center; margin: 30px 0;">
                                    <a href="${linkCartola}" style="background-color: #3B6D11; color: white; padding: 15px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block;">
                                        VER COMPROBANTE DE ENTREGA Y GARANTÍA
                                    </a>
                                </div>
                                <hr style="border: 0; border-top: 1px solid #eee;">
                                <p style="font-size: 11px; color: #aaa;">YJMRepair Pro - Servicio Técnico Especializado</p>
                            </div>`
                    };
                    transporter.sendMail(mailOptions, () => {});
                }
                
                // --- INICIO: AUTOMATIZACIÓN DE CAJA ---
                oConexion.query('SELECT id FROM caja_diaria WHERE estado = "abierta" ORDER BY id DESC LIMIT 1', (errCaja, resCaja) => {
                    if (!errCaja && resCaja.length > 0) {
                        const cajaId = resCaja[0].id;
                        // Si pagó por garantía, el monto ingresado a caja es 0 para evitar descuadres.
                        const montoCaja = (metodo_pago && metodo_pago.toLowerCase().includes('garantia')) ? 0 : orden.costo_total;
                        
                        if (montoCaja > 0) {
                            const sqlTransaccion = 'INSERT INTO transacciones_caja (caja_id, tipo, concepto, monto, metodo_pago, usuario_id) VALUES (?, ?, ?, ?, ?, ?)';
                            oConexion.query(sqlTransaccion, [cajaId, 'ingreso', `Reparación Orden ${orden.codigo}`, montoCaja, metodo_pago || 'efectivo', req.session.userId]);
                        }
                    }
                    // Terminar y renderizar sin importar si la caja está abierta o no
                    res.render('confirmacion-entrega', { user: req.user, linkWtp, linkCartola, orden });
                });
                // --- FIN: AUTOMATIZACIÓN DE CAJA ---
            });
        });
    });
});

// Revertir entrega (Equivocación)
app.post('/revertir-entrega', authMiddleware, (req, res) => {
    const { orden_id } = req.body;
    oConexion.query('DELETE FROM entregas WHERE orden_id = ?', [orden_id], (err) => {
        if (err) return res.status(500).send("Error eliminando registro de entrega");
        
        oConexion.query("UPDATE ordenes SET estado = 'taller' WHERE id = ?", [orden_id], (err2) => {
            if (err2) throw err2;
            io.to('orden_' + orden_id).emit('estado_actualizado', { estado: 'taller' });
            res.redirect('/orden/' + orden_id);
        });
    });
});

// Reingresar por Garantía
app.post('/ingreso-garantia', authMiddleware, (req, res) => {
    const { orden_id } = req.body;
    // Se mantiene la entrega anterior en el historial, solo cambiamos el estado activo de la orden
    oConexion.query("UPDATE ordenes SET estado = 'garantia' WHERE id = ?", [orden_id], (err) => {
        if (err) throw err;
        io.to('orden_' + orden_id).emit('estado_actualizado', { estado: 'garantia' });
        res.redirect('/orden/' + orden_id);
    });
});

// Subir foto de avance desde la ficha
app.post('/subir-foto/:orden_id', authMiddleware, upload.single('foto'), (req, res) => {
    const orden_id = req.params.orden_id;
    const sql = 'INSERT INTO fotos (orden_id, archivo, tipo) VALUES (?, ?, ?)';
    oConexion.query(sql, [orden_id, req.file.filename, 'avance'], (error) => {
        if (error) throw error;
        // Notificar al cliente en tiempo real
        io.to('orden_' + orden_id).emit('nueva_foto', {
            archivo: req.file.filename,
            tipo: 'avance'
        });
        res.redirect('/orden/' + orden_id);
    });
});
// Agregar falla extra y NOTIFICAR al cliente en tiempo real
app.post('/agregar-falla', authMiddleware, (req, res) => {
    const { orden_id, descripcion, costo } = req.body;
    const sql = "INSERT INTO fallas_extra (orden_id, descripcion, costo, aceptada) VALUES (?, ?, ?, NULL)";
    
    oConexion.query(sql, [orden_id, descripcion, costo], (err) => {
        if (err) throw err;

        // ESTA ES LA CLAVE: Enviamos el aviso al cliente
        io.to('orden_' + orden_id).emit('nueva_falla');

        res.redirect('/orden/' + orden_id);
    });
});

// Cliente acepta/rechaza falla extra
// Ruta para que el cliente acepte o rechace una falla
app.post('/responder-falla', (req, res) => {
    const { falla_id, orden_id, acepta, codigo } = req.body;
    const estado_aceptacion = (acepta === 'si') ? 1 : 0;

    // 1. Actualizamos la tabla fallas_extra
    const sqlFalla = "UPDATE fallas_extra SET aceptada = ? WHERE id = ?";
    oConexion.query(sqlFalla, [estado_aceptacion, falla_id], (err) => {
        if (err) throw err;

        if (estado_aceptacion === 1) {
            // 2. Si aceptó, sumamos el costo al costo_total de la orden
            const sqlSuma = `
                UPDATE ordenes 
                SET costo_total = costo_total + (SELECT costo FROM fallas_extra WHERE id = ?) 
                WHERE id = ?`;
            oConexion.query(sqlSuma, [falla_id, orden_id], (err2) => {
                if (err2) throw err2;
                res.redirect('/r/' + codigo); // Redirige al seguimiento público
            });
        } else {
            res.redirect('/r/' + codigo);
        }
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  MENSAJES (igual estructura que tu sistema de carrito)
// ═══════════════════════════════════════════════════════════════════════════════

// BUSCA tu ruta app.post('/enviar-mensaje') y reemplázala por esta:
app.post('/enviar-mensaje', (req, res) => {
    const { orden_id, autor, texto, codigo } = req.body;

    // VALIDACIÓN: Si el autor dice ser 'tecnico', debe estar logueado
    if (autor === 'tecnico' && !req.session.userId) {
        return res.status(401).send("No autorizado");
    }

    // Usamos Query con parámetros [?] para evitar Inyección SQL
    const sql = 'INSERT INTO mensajes (orden_id, autor, texto) VALUES (?,?,?)';
    oConexion.query(sql, [orden_id, autor, texto], (error) => {
        if (error) {
            console.error("Error SQL en mensajes:", error);
            return res.status(500).send("Error al enviar mensaje");
        }
        
        io.to('orden_' + orden_id).emit('nuevo_mensaje', { autor, texto });

        if (autor === 'tecnico') {
            res.redirect('/orden/' + orden_id);
        } else {
            res.redirect('/r/' + codigo);
        }
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
//  TELÉFONOS EN VENTA (Ajustado a tu tabla PHPMyAdmin)
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
//  CRUD TELÉFONOS - GESTIÓN PARA TÉCNICOS Y ADMINS
// ═══════════════════════════════════════════════════════════════════════════════

// Ver lista de teléfonos (Técnicos y Admins)
app.get('/telefonos', authMiddleware, (req, res) => {
    const sql = 'SELECT * FROM telefonos_venta ORDER BY creado_en DESC';
    oConexion.query(sql, (error, results) => {
        if (error) return res.status(500).send("Error de servidor");
        res.render('telefonos', { telefonos: results, user: req.user });
    });
});

// Crear Teléfono (Quitamos adminMiddleware para que el Técnico pueda)
app.post('/crear-telefono', authMiddleware, upload.single('foto'), (req, res) => {
    const { nombre, descripcion, precio, precio_anterior, bateria, storage, color } = req.body;
    const foto = req.file ? req.file.filename : null;
    const pAnt = precio_anterior === "" ? null : precio_anterior;

    const sql = `INSERT INTO telefonos_venta 
        (nombre, descripcion, precio, precio_anterior, bateria, storage, color, foto, disponible) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)`;

    oConexion.query(sql, [nombre, descripcion, precio, pAnt, bateria, storage, color, foto], (error) => {
        if (error) return res.status(500).send("Error al crear");
        res.redirect('/telefonos');
    });
});

// Actualizar Teléfono
// 1. RUTA PARA MOSTRAR EL FORMULARIO (GET)
app.get('/editar-telefono/:id', authMiddleware, (req, res) => {
    const id = req.params.id;
    const sql = 'SELECT * FROM telefonos_venta WHERE id = ?';
    
    oConexion.query(sql, [id], (error, results) => {
        if (error) {
            console.error("Error al buscar el equipo:", error);
            return res.status(500).send("Error de base de datos");
        }
        
        if (results.length === 0) {
            return res.status(404).send("El equipo no existe en la base de datos");
        }

        // Enviamos el primer resultado del array y el usuario logueado
        res.render('editar-telefono', { 
            telefono: results[0], 
            user: req.user 
        });
    });
});
// este ve los dispositivos que estan conectados // --- GESTIÓN DE DISPOSITIVOS (SOLO ADMIN) ---
app.get('/admin/dispositivos', authMiddleware, (req, res) => {
    if (req.session.rol !== 'admin') return res.redirect('/panel');

    // Consultamos las sesiones activas directamente de la base de datos
    // Nota: 'sessions' es el nombre por defecto de la tabla de express-mysql-session
    const sql = 'SELECT session_id, data FROM sessions';
    
    oConexion.query(sql, (err, results) => {
        if (err) throw err;

        const dispositivos = results.map(row => {
            const data = JSON.parse(row.data);
            return {
                id: row.session_id,
                rol: data.rol,
                userId: data.userId,
                // Si el ID de sesión coincide con el actual, marcamos como "Este dispositivo"
                actual: row.session_id === req.sessionID
            };
        });

        res.render('admin-dispositivos', { user: req.user, dispositivos, active: 'dispositivos' });
    });
});

// Ruta para "Borrar/Cerrar" sesión de un dispositivo
app.post('/admin/eliminar-sesion', authMiddleware, (req, res) => {
    if (req.session.rol !== 'admin') return res.status(403).send("No autorizado");
    const { session_id } = req.body;

    const sql = 'DELETE FROM sessions WHERE session_id = ?';
    oConexion.query(sql, [session_id], (err) => {
        if (err) throw err;
        res.redirect('/admin/dispositivos');
    });
});

// 2. RUTA PARA GUARDAR LOS CAMBIOS (POST)
app.post('/actualizar-telefono', authMiddleware, upload.single('foto'), (req, res) => {
    const { id, nombre, descripcion, precio, precio_anterior, bateria, storage, color } = req.body;
    const foto = req.file ? req.file.filename : null;

    // Convertir precio anterior a NULL si está vacío para evitar error de SQL
    const pAnt = precio_anterior === "" ? null : precio_anterior;
    
    let sql = 'UPDATE telefonos_venta SET nombre=?, descripcion=?, precio=?, precio_anterior=?, bateria=?, storage=?, color=?';
    let params = [nombre, descripcion, precio, pAnt, bateria, storage, color];

    if (foto) {
        sql += ', foto=? WHERE id=?';
        params.push(foto, id);
    } else {
        sql += ' WHERE id=?';
        params.push(id);
    }
    oConexion.query(sql, params, (error) => {
        if (error) {
            console.error("Error al actualizar:", error);
            return res.status(500).send("No se pudieron guardar los cambios");
        }
        res.redirect('/telefonos');
    });
});

// Borrar Teléfono
app.post('/borrar-telefono', authMiddleware, (req, res) => {
    oConexion.query('DELETE FROM telefonos_venta WHERE id = ?', [req.body.id], (error) => {
        if (error) return res.status(500).send("Error al borrar");
        res.redirect('/telefonos');
    });
});

// MARCAR COMO VENDIDO Y CREAR HISTORIAL
app.post('/vender-telefono', authMiddleware, (req, res) => {
    const { id } = req.body;
    const vendedor_id = req.session.userId;

    // 1. Buscamos los datos del teléfono antes de marcarlo como vendido
    oConexion.query('SELECT * FROM telefonos_venta WHERE id = ?', [id], (err, results) => {
        if (err || results.length === 0) return res.status(500).send("Error");
        
        const tel = results[0];

        // 2. Insertamos en el historial de ventas
        const sqlHistorial = `INSERT INTO historial_ventas 
            (telefono_id, nombre_equipo, precio_venta, vendedor_id) 
            VALUES (?, ?, ?, ?)`;
        
        oConexion.query(sqlHistorial, [tel.id, tel.nombre, tel.precio, vendedor_id], (errH) => {
            if (errH) return res.status(500).send("Error al crear historial");

            // 3. Cambiamos disponible a 0 (Vendido)
            oConexion.query('UPDATE telefonos_venta SET disponible = 0 WHERE id = ?', [id], (errU) => {
                
                // --- INICIO: AUTOMATIZACIÓN DE CAJA ---
                oConexion.query('SELECT id FROM caja_diaria WHERE estado = "abierta" ORDER BY id DESC LIMIT 1', (errCaja, resCaja) => {
                    if (!errCaja && resCaja.length > 0) {
                        const cajaId = resCaja[0].id;
                        const sqlTransaccion = 'INSERT INTO transacciones_caja (caja_id, tipo, concepto, monto, metodo_pago, usuario_id) VALUES (?, ?, ?, ?, ?, ?)';
                        oConexion.query(sqlTransaccion, [cajaId, 'ingreso', `Venta Teléfono: ${tel.nombre}`, tel.precio, 'efectivo', vendedor_id]);
                    }
                    res.redirect('/telefonos');
                });
                // --- FIN: AUTOMATIZACIÓN DE CAJA ---

            });
        });
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  CRUD REPUESTOS (Inventario)
// ═══════════════════════════════════════════════════════════════════════════════

// Ver inventario de repuestos
app.get('/repuestos', authMiddleware, (req, res) => {
    const buscar = (req.query.q || '').trim();
    let sql = 'SELECT * FROM repuestos';
    let params = [];
    if (buscar) {
        sql += ' WHERE nombre LIKE ? OR modelo_compatible LIKE ?';
        const like = '%' + buscar + '%';
        params.push(like, like);
    }
    sql += ' ORDER BY creado_en DESC';

    oConexion.query(sql, params, (error, results) => {
        if (error) return res.status(500).send("Error de servidor");
        res.render('repuestos', { repuestos: results, buscar, user: req.user, active: 'repuestos' });
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  REGISTRO DE ENTREGAS Y CARTOLA
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/entregas', authMiddleware, (req, res) => {
    const sql = `
        SELECT e.*, o.codigo, o.cliente_nombre, o.equipo_marca, o.equipo_modelo, o.costo_total
        FROM entregas e
        JOIN ordenes o ON e.orden_id = o.id
        ORDER BY e.fecha_entrega DESC
    `;
    oConexion.query(sql, (error, results) => {
        if (error) return res.status(500).send("Error");
        res.render('entregas', { entregas: results, user: req.user, active: 'entregas' });
    });
});

app.get('/comprobante-entrega/:id', (req, res) => {
    const id = req.params.id;
    const sql = `
        SELECT e.*, o.*
        FROM ordenes o
        LEFT JOIN entregas e ON o.id = e.orden_id
        WHERE o.id = ?
    `;
    oConexion.query(sql, [id], (err, results) => {
        if (err || results.length === 0) return res.status(404).send("Comprobante no encontrado");
        
        const orden = results[0];
        
        const sqlFotos = "SELECT * FROM fotos WHERE orden_id = ? AND tipo='avance'";
        oConexion.query(sqlFotos, [id], (errF, fotos) => {
            const sqlFallas = "SELECT * FROM fallas_extra WHERE orden_id = ? AND aceptada = 1";
            oConexion.query(sqlFallas, [id], (errF2, fallas) => {
                res.render('comprobante-entrega', { orden, fotos, fallas });
            });
        });
    });
});


// Crear Repuesto
app.post('/repuestos/crear', authMiddleware, (req, res) => {
    const { nombre, modelo_compatible, cantidad, precio_compra, precio_venta } = req.body;
    const sql = `INSERT INTO repuestos (nombre, modelo_compatible, cantidad, precio_compra, precio_venta) VALUES (?, ?, ?, ?, ?)`;
    oConexion.query(sql, [nombre, modelo_compatible, cantidad || 0, precio_compra || 0, precio_venta || 0], (error) => {
        if (error) return res.status(500).send("Error al crear repuesto");
        res.redirect('/repuestos');
    });
});

// Editar Repuesto (actualiza y redirecciona)
app.post('/repuestos/actualizar', authMiddleware, (req, res) => {
    const { id, nombre, modelo_compatible, cantidad, precio_compra, precio_venta } = req.body;
    const sql = 'UPDATE repuestos SET nombre=?, modelo_compatible=?, cantidad=?, precio_compra=?, precio_venta=? WHERE id=?';
    oConexion.query(sql, [nombre, modelo_compatible, cantidad || 0, precio_compra || 0, precio_venta || 0, id], (error) => {
        if (error) return res.status(500).send("Error al actualizar");
        res.redirect('/repuestos');
    });
});

// Borrar Repuesto
app.post('/repuestos/eliminar', authMiddleware, (req, res) => {
    oConexion.query('DELETE FROM repuestos WHERE id = ?', [req.body.id], (error) => {
        if (error) return res.status(500).send("Error al borrar");
        res.redirect('/repuestos');
    });
});

// API Check stock
app.get('/api/repuestos/check', authMiddleware, (req, res) => {
    const modelo = (req.query.modelo || '').trim();
    if (!modelo) return res.json({ available: false, repuestos: [] });

    // Busca si hay coincidencia parcial del modelo
    const sql = 'SELECT * FROM repuestos WHERE modelo_compatible LIKE ? AND cantidad > 0';
    oConexion.query(sql, ['%' + modelo + '%'], (err, results) => {
        if (err) return res.status(500).json({ error: "Error db" });
        if (results.length > 0) {
            res.json({ available: true, repuestos: results });
        } else {
            res.json({ available: false, repuestos: [] });
        }
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  MÓDULO DE COTIZACIONES PROFORMA
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/cotizaciones', authMiddleware, (req, res) => {
    const buscar = (req.query.q || '').trim();
    let sql = 'SELECT * FROM cotizaciones';
    let params = [];
    if (buscar) {
        sql += ' WHERE codigo LIKE ? OR cliente_nombre LIKE ? OR equipo LIKE ?';
        const like = '%' + buscar + '%';
        params.push(like, like, like);
    }
    sql += ' ORDER BY fecha_emision DESC';
    
    oConexion.query(sql, params, (err, results) => {
        if (err) return res.status(500).send("Error de BD");
        res.render('cotizaciones', { cotizaciones: results, buscar, user: req.user, active: 'cotizaciones' });
    });
});

app.get('/nueva-cotizacion', authMiddleware, (req, res) => {
    res.render('nueva-cotizacion', { user: req.user, active: 'cotizaciones' });
});

app.post('/crear-cotizacion', authMiddleware, (req, res) => {
    const { cliente_nombre, cliente_telefono, equipo, falla_descripcion, valor_estimado } = req.body;
    
    // Generar código de cotización
    const fecha = new Date();
    const rand = Math.floor(Math.random() * 900) + 100;
    const codigo = `COT-${fecha.getFullYear()}-${rand}`;

    const sql = `INSERT INTO cotizaciones 
        (codigo, cliente_nombre, cliente_telefono, equipo, falla_descripcion, valor_estimado, creado_por) 
        VALUES (?, ?, ?, ?, ?, ?, ?)`;
        
    oConexion.query(sql, [codigo, cliente_nombre, cliente_telefono, equipo, falla_descripcion, valor_estimado, req.session.userId], (err, result) => {
        if (err) return res.status(500).send("Error al crear cotización");
        
        const dominioPublico = process.env.DOMAIN_URL || `http://localhost:${port}`;
        const linkCartola = `${dominioPublico}/presupuesto/${codigo}`;
        
        let linkWtp = null;
        if (cliente_telefono) {
            const fonoLimpio = cliente_telefono.replace(/\D/g, '');
            const mensajeCli = 
                `*YJMREPAIR PRO* 🛠️\n\n` +
                `Hola *${cliente_nombre}*! 👋\n` +
                `Adjuntamos la cotización de reparación para tu *${equipo}*.\n\n` +
                `📄 Puedes ver el Presupuesto Oficial haciendo clic aquí:\n` +
                `👉 ${linkCartola}\n\n` +
                `_Este presupuesto tiene una validez de 7 días._`;

            linkWtp = `https://wa.me/${fonoLimpio}?text=${encodeURIComponent(mensajeCli)}`;
        }
        
        res.render('confirmacion-cotizacion', { user: req.user, linkWtp, linkCartola, codigo });
    });
});

app.get('/presupuesto/:codigo', (req, res) => {
    const codigo = req.params.codigo;
    const sql = 'SELECT * FROM cotizaciones WHERE codigo = ?';
    oConexion.query(sql, [codigo], (err, results) => {
        if (err || results.length === 0) return res.status(404).send("Cotización no encontrada");
        res.render('presupuesto', { cotizacion: results[0] });
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  SOCKET.IO — tiempo real
// ═══════════════════════════════════════════════════════════════════════════════

io.on('connection', (socket) => {
    // El cliente/técnico se une a la sala de su orden
    socket.on('unirse_orden', (orden_id) => {
        socket.join('orden_' + orden_id);
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  PANEL ADMINISTRADOR (Dashboard con Ventas Reales)
// ═══════════════════════════════════════════════════════════════════════════════
app.get('/admin', [authMiddleware, adminMiddleware], (req, res) => {
    // 1. Modificamos sqlStats para que incluya la suma de historial_ventas
    const sqlStats = `
        SELECT
            COUNT(*) AS total,
            SUM(CASE WHEN MONTH(fecha_ingreso) = MONTH(NOW()) AND YEAR(fecha_ingreso) = YEAR(NOW()) THEN 1 ELSE 0 END) AS este_mes,
            COALESCE(SUM(costo_total), 0) AS ingresos,
            (SELECT COUNT(*) FROM telefonos_venta WHERE disponible = 1) AS en_venta,
            (SELECT COALESCE(SUM(precio_venta), 0) FROM historial_ventas) AS ingresos_ventas
        FROM ordenes
    `;

    const sqlMeses = `
        SELECT DATE_FORMAT(fecha_ingreso, '%b %Y') Mes, COUNT(*) AS total
        FROM ordenes
        WHERE fecha_ingreso >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
        GROUP BY Mes, DATE_FORMAT(fecha_ingreso, '%Y-%m')
        ORDER BY fecha_ingreso ASC
    `;

    const sqlFallas = `
        SELECT COALESCE(equipo_tipo, 'Otros') AS falla, COUNT(*) AS total
        FROM ordenes
        GROUP BY equipo_tipo
        ORDER BY total DESC
        LIMIT 6
    `;

    const sqlOrdenes = "SELECT * FROM ordenes WHERE estado != 'entregado' ORDER BY fecha_ingreso DESC LIMIT 20";

    // Ejecución controlada de consultas
    oConexion.query(sqlStats, (e1, statsResults) => {
        if (e1) { console.error("Error en Stats:", e1); return res.status(500).send("Error en el servidor"); }

        oConexion.query(sqlMeses, (e2, meses) => {
            if (e2) { console.error("Error en Meses:", e2); return res.status(500).send("Error en el servidor"); }

            oConexion.query(sqlFallas, (e3, fallas) => {
                if (e3) { console.error("Error en Fallas:", e3); return res.status(500).send("Error en el servidor"); }

                oConexion.query(sqlOrdenes, (e4, ordenes) => {
                    if (e4) { console.error("Error en Ordenes:", e4); return res.status(500).send("Error en el servidor"); }

                    const safeMeses = meses || [];
                    const safeFallas = fallas || [];
                    const currentStats = statsResults[0] || { total: 0, este_mes: 0, ingresos: 0, en_venta: 0, ingresos_ventas: 0 };

                    res.render('admin', {
                        user: req.user,
                        stats: currentStats,
                        
                        mesesLabels: safeMeses.map(m => m.Mes || 'Sin fecha'),
                        mesesData:   safeMeses.map(m => m.total || 0),
                        
                        fallasLabels: safeFallas.map(f => f.falla || 'Otros'),
                        fallasData:   safeFallas.map(f => f.total || 0),
                        
                        ordenes: ordenes || [],
                        buscar: ''
                    });
                });
            });
        });
    });
});

// ─── RUTA PARA VER EL DETALLE DE VENTAS (Solo Admin) ───
app.get('/ventas', [authMiddleware, adminMiddleware], (req, res) => {
    const sql = `
        SELECT h.*, u.nombre as vendedor 
        FROM historial_ventas h 
        JOIN usuarios u ON h.vendedor_id = u.id 
        ORDER BY h.fecha_venta DESC`;
    
    oConexion.query(sql, (error, results) => {
        if (error) return res.status(500).send("Error");
        const totalRecaudado = results.reduce((sum, v) => sum + parseFloat(v.precio_venta), 0);
        res.render('ventas', { ventas: results, total: totalRecaudado, user: req.user });
    });
});
// Historial con búsqueda
app.get('/admin/historial', [authMiddleware, adminMiddleware], (req, res) => {
    const buscar = req.query.q || '';
    const like = '%' + buscar + '%';
    const sql = `SELECT * FROM ordenes WHERE cliente_nombre LIKE ? OR equipo_modelo LIKE ? OR codigo LIKE ? ORDER BY fecha_ingreso DESC`;
    const sqlMeses = `SELECT DATE_FORMAT(fecha_ingreso,'%b %Y') AS mes, COUNT(*) AS total FROM ordenes WHERE fecha_ingreso >= DATE_SUB(NOW(), INTERVAL 6 MONTH) GROUP BY mes ORDER BY fecha_ingreso ASC`;
    const sqlFallas = `SELECT equipo_tipo AS falla, COUNT(*) AS total FROM ordenes GROUP BY equipo_tipo ORDER BY total DESC LIMIT 6`;
    const sqlStats = `SELECT COUNT(*) AS total, SUM(MONTH(fecha_ingreso)=MONTH(NOW()) AND YEAR(fecha_ingreso)=YEAR(NOW())) AS este_mes, SUM(costo_total) AS ingresos, (SELECT COUNT(*) FROM telefonos_venta WHERE disponible=1) AS en_venta FROM ordenes`;

    oConexion.query(sql, [like, like, like], (e1, ordenes) => {
        oConexion.query(sqlStats, (e2, stats) => {
            oConexion.query(sqlMeses, (e3, meses) => {
                oConexion.query(sqlFallas, (e4, fallas) => {
                    res.render('admin', {
                        user: req.user,
                        stats: stats[0],
                        mesesLabels: meses.map(m => m.mes),
                        mesesData:   meses.map(m => m.total),
                        fallasLabels: fallas.map(f => f.falla || 'Sin datos'),
                        fallasData:   fallas.map(f => f.total),
                        ordenes,
                        buscar
                    });
                });
            });
        });
    });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  CAJA DIARIA Y FINANZAS (Solo Admin)
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/admin/caja', authMiddleware, (req, res) => {
    // 1. Ver si hay una caja abierta
    oConexion.query('SELECT * FROM caja_diaria WHERE estado = "abierta" ORDER BY id DESC LIMIT 1', (err, cajaRes) => {
        if (err) return res.status(500).send("Error");
        
        const cajaActiva = cajaRes.length > 0 ? cajaRes[0] : null;
        
        if (!cajaActiva) {
            // Si no hay caja abierta, mostramos panel de apertura
            return res.render('caja', { cajaActiva: null, transacciones: [], user: req.user, active: 'caja' });
        }
        
        // 2. Si hay caja abierta, traemos las transacciones
        oConexion.query('SELECT * FROM transacciones_caja WHERE caja_id = ? ORDER BY fecha DESC', [cajaActiva.id], (err2, transacciones) => {
            if (err2) return res.status(500).send("Error transacciones");
            
            res.render('caja', { cajaActiva, transacciones, user: req.user, active: 'caja' });
        });
    });
});

app.post('/admin/abrir-caja', [authMiddleware, adminMiddleware], (req, res) => {
    const { monto_inicial } = req.body;
    const sql = 'INSERT INTO caja_diaria (monto_inicial, abierta_por) VALUES (?, ?)';
    oConexion.query(sql, [monto_inicial || 0, req.session.userId], (err) => {
        if (err) return res.status(500).send("Error abriendo caja");
        res.redirect('/admin/caja');
    });
});

app.post('/admin/transaccion-manual', [authMiddleware, adminMiddleware], (req, res) => {
    const { caja_id, tipo, concepto, monto, metodo_pago } = req.body;
    const sql = 'INSERT INTO transacciones_caja (caja_id, tipo, concepto, monto, metodo_pago, usuario_id) VALUES (?, ?, ?, ?, ?, ?)';
    oConexion.query(sql, [caja_id, tipo, concepto, monto, metodo_pago || 'efectivo', req.session.userId], (err) => {
        if (err) return res.status(500).send("Error en transacción");
        res.redirect('/admin/caja');
    });
});

app.post('/admin/cerrar-caja', authMiddleware, (req, res) => {
    const { caja_id } = req.body;
    const sql = 'UPDATE caja_diaria SET estado = "cerrada", fecha_cierre = CURRENT_TIMESTAMP, cerrada_por = ? WHERE id = ?';
    oConexion.query(sql, [req.session.userId, caja_id], (err) => {
        if (err) return res.status(500).send("Error cerrando caja");
        res.redirect('/admin/caja');
    });
});

// ── USUARIOS ─────────────────────────────────────────────────────────────────

app.get('/admin/usuarios', [authMiddleware, adminMiddleware], (req, res) => {
    oConexion.query('SELECT * FROM usuarios ORDER BY creado_en DESC', (error, usuarios) => {
        if (error) throw error;
        res.render('admin-usuarios', { user: req.user, usuarios, msg: req.query.msg });
    });
});

app.get('/admin/usuarios/nuevo', [authMiddleware, adminMiddleware], (req, res) => {
    res.render('admin-nuevo-usuario', { user: req.user });
});

app.post('/admin/usuarios/crear', [authMiddleware, adminMiddleware], async (req, res) => {
    const { nombre, email, password, rol } = req.body;
    const hash = await bcrypt.hash(password, 10);
    const sql = 'INSERT INTO usuarios (nombre, email, password, rol) VALUES (?,?,?,?)';
    oConexion.query(sql, [nombre, email, hash, rol], (error) => {
        if (error) {
            return res.render('admin-nuevo-usuario', { user: req.user, error: 'El email ya existe' });
        }
        res.redirect('/admin/usuarios?msg=Usuario creado correctamente');
    });
});

app.get('/admin/usuarios/password/:id', [authMiddleware, adminMiddleware], (req, res) => {
    oConexion.query('SELECT * FROM usuarios WHERE id = ?', [req.params.id], (error, results) => {
        if (error) throw error;
        res.render('admin-password', { user: req.user, objetivo: results[0] });
    });
});

app.post('/admin/usuarios/actualizar-password', [authMiddleware, adminMiddleware], async (req, res) => {
    const { id, password, password2 } = req.body;
    if (password !== password2) {
        oConexion.query('SELECT * FROM usuarios WHERE id = ?', [id], (e, r) => {
            res.render('admin-password', { user: req.user, objetivo: r[0], msg: 'Las contraseñas no coinciden' });
        });
        return;
    }
    const hash = await bcrypt.hash(password, 10);
    oConexion.query('UPDATE usuarios SET password = ? WHERE id = ?', [hash, id], (error) => {
        if (error) throw error;
        res.redirect('/admin/usuarios?msg=Contraseña actualizada correctamente');
    });
});

app.post('/admin/usuarios/borrar', [authMiddleware, adminMiddleware], (req, res) => {
    oConexion.query('DELETE FROM usuarios WHERE id = ?', [req.body.id], (error) => {
        if (error) throw error;
        res.redirect('/admin/usuarios?msg=Usuario eliminado');
    });
    
});

// ═══════════════════════════════════════════════════════════════════════════════
//  INICIAR SERVIDOR
// ═══════════════════════════════════════════════════════════════════════════════
server.listen(port, () => {
    console.log(`YJMRepair Pro corriendo en http://localhost:${port}`);
});

