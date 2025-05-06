-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS AdministracionTiendas;
USE AdministracionTiendas;

-- Tabla de Estados
CREATE TABLE Estados (
    estado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    codigo VARCHAR(5) NOT NULL
);

-- Tabla de Ciudades
CREATE TABLE Ciudades (
    ciudad_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado_id INT NOT NULL,
    codigo_postal VARCHAR(10),
    FOREIGN KEY (estado_id) REFERENCES Estados(estado_id)
);

-- Tabla de Tiendas
CREATE TABLE Tiendas (
    tienda_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    ciudad_id INT NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100),
    fecha_apertura DATE NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ciudad_id) REFERENCES Ciudades(ciudad_id)
);

-- Tabla de Categorías de Productos
CREATE TABLE Categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- Tabla de Proveedores
CREATE TABLE Proveedores (
    proveedor_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(15),
    email VARCHAR(100),
    direccion VARCHAR(255),
    ciudad_id INT,
    FOREIGN KEY (ciudad_id) REFERENCES Ciudades(ciudad_id)
);

-- Tabla de Productos
CREATE TABLE Productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria_id INT NOT NULL,
    proveedor_id INT,
    precio_compra DECIMAL(10, 2) NOT NULL,
    precio_venta DECIMAL(10, 2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES Categorias(categoria_id),
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id)
);

-- Tabla de Posiciones de Almacenamiento
CREATE TABLE PosicionesAlmacen (
    posicion_id INT AUTO_INCREMENT PRIMARY KEY,
    tienda_id INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id)
);

-- Tabla de Roles de Empleados
CREATE TABLE Roles (
    rol_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- Tabla de Empleados
CREATE TABLE Empleados (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100),
    direccion VARCHAR(255),
    ciudad_id INT,
    fecha_contratacion DATE NOT NULL,
    rol_id INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ciudad_id) REFERENCES Ciudades(ciudad_id),
    FOREIGN KEY (rol_id) REFERENCES Roles(rol_id)
);

-- Tabla de Turnos
CREATE TABLE Turnos (
    turno_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

-- Tabla de Asignación de Turnos
CREATE TABLE AsignacionTurnos (
    asignacion_id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    tienda_id INT NOT NULL,
    turno_id INT NOT NULL,
    fecha DATE NOT NULL,
    encargado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id),
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),
    FOREIGN KEY (turno_id) REFERENCES Turnos(turno_id)
);

-- Tabla de Cajas Registradoras
CREATE TABLE Cajas (
    caja_id INT AUTO_INCREMENT PRIMARY KEY,
    tienda_id INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    ubicacion VARCHAR(100),
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id)
);

-- Tabla de Inventario
CREATE TABLE Inventario (
    inventario_id INT AUTO_INCREMENT PRIMARY KEY,
    tienda_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    posicion_id INT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),
    FOREIGN KEY (posicion_id) REFERENCES PosicionesAlmacen(posicion_id)
);

-- Tabla de Movimientos de Inventario (entradas/salidas no por venta)
CREATE TABLE MovimientosInventario (
    movimiento_id INT AUTO_INCREMENT PRIMARY KEY,
    tienda_id INT NOT NULL,
    producto_id INT NOT NULL,
    empleado_id INT NOT NULL,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA', 'AJUSTE', 'TRANSFERENCIA') NOT NULL,
    cantidad INT NOT NULL,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(255),
    tienda_destino_id INT,
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id),
    FOREIGN KEY (tienda_destino_id) REFERENCES Tiendas(tienda_id)
);

-- Tabla de Recepciones (cuando llega producto)
CREATE TABLE Recepciones (
    recepcion_id INT AUTO_INCREMENT PRIMARY KEY,
    tienda_id INT NOT NULL,
    proveedor_id INT NOT NULL,
    empleado_id INT NOT NULL,
    fecha_recepcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    referencia VARCHAR(100),
    notas TEXT,
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id),
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
);

-- Tabla de Detalles de Recepción
CREATE TABLE DetalleRecepcion (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    recepcion_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    posicion_id INT,
    FOREIGN KEY (recepcion_id) REFERENCES Recepciones(recepcion_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),
    FOREIGN KEY (posicion_id) REFERENCES PosicionesAlmacen(posicion_id)
);

-- Tabla de Métodos de Pago
CREATE TABLE MetodosPago (
    metodo_pago_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255)
);

-- Tabla de Ventas
CREATE TABLE Ventas (
    venta_id INT AUTO_INCREMENT PRIMARY KEY,
    tienda_id INT NOT NULL,
    caja_id INT NOT NULL,
    empleado_id INT NOT NULL, -- Vendedor
    encargado_id INT NOT NULL, -- Encargado de turno
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metodo_pago_id INT NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    impuestos DECIMAL(10, 2) NOT NULL,
    descuento DECIMAL(10, 2) DEFAULT 0,
    notas TEXT,
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),
    FOREIGN KEY (caja_id) REFERENCES Cajas(caja_id),
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id),
    FOREIGN KEY (encargado_id) REFERENCES Empleados(empleado_id),
    FOREIGN KEY (metodo_pago_id) REFERENCES MetodosPago(metodo_pago_id)
);

-- Tabla de Detalles de Venta
CREATE TABLE DetalleVenta (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    descuento_unitario DECIMAL(10, 2) DEFAULT 0,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (venta_id) REFERENCES Ventas(venta_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id)
);

-- Tabla de Devoluciones
CREATE TABLE Devoluciones (
    devolucion_id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT NOT NULL,
    empleado_id INT NOT NULL,
    encargado_id INT NOT NULL,
    fecha_devolucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT NOT NULL,
    monto_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (venta_id) REFERENCES Ventas(venta_id),
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id),
    FOREIGN KEY (encargado_id) REFERENCES Empleados(empleado_id)
);

-- Tabla de Detalles de Devolución
CREATE TABLE DetalleDevolucion (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    devolucion_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (devolucion_id) REFERENCES Devoluciones(devolucion_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id)
);

-- Tabla de Inventarios Físicos (para auditorías)
CREATE TABLE InventariosFisicos (
    inventario_fisico_id INT AUTO_INCREMENT PRIMARY KEY,
    tienda_id INT NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    empleado_id INT NOT NULL,
    estado ENUM('EN_PROGRESO', 'COMPLETADO', 'CANCELADO') DEFAULT 'EN_PROGRESO',
    notas TEXT,
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
);

-- Tabla de Detalles de Inventarios Físicos
CREATE TABLE DetalleInventarioFisico (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    inventario_fisico_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad_sistema INT NOT NULL,
    cantidad_fisica INT NOT NULL,
    diferencia INT GENERATED ALWAYS AS (cantidad_fisica - cantidad_sistema) STORED,
    posicion_id INT,
    FOREIGN KEY (inventario_fisico_id) REFERENCES InventariosFisicos(inventario_fisico_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),
    FOREIGN KEY (posicion_id) REFERENCES PosicionesAlmacen(posicion_id)
);

-- Índices para optimizar consultas frecuentes
CREATE INDEX idx_productos_categoria ON Productos(categoria_id);
CREATE INDEX idx_inventario_tienda_producto ON Inventario(tienda_id, producto_id);
CREATE INDEX idx_ventas_fecha ON Ventas(fecha_venta);
CREATE INDEX idx_ventas_empleado ON Ventas(empleado_id);
CREATE INDEX idx_asignacion_fecha_tienda ON AsignacionTurnos(fecha, tienda_id);
CREATE INDEX idx_recepciones_fecha ON Recepciones(fecha_recepcion);

-- Procedimiento almacenado para registrar una venta y actualizar inventario
DELIMITER //
CREATE PROCEDURE RegistrarVenta(
    IN p_tienda_id INT,
    IN p_caja_id INT,
    IN p_empleado_id INT,
    IN p_encargado_id INT,
    IN p_metodo_pago_id INT,
    IN p_total DECIMAL(10, 2),
    IN p_impuestos DECIMAL(10, 2),
    IN p_descuento DECIMAL(10, 2),
    IN p_notas TEXT
)
BEGIN
    DECLARE v_venta_id INT;
    
    -- Iniciar transacción
    START TRANSACTION;
    
    -- Insertar la venta
    INSERT INTO Ventas (
        tienda_id, caja_id, empleado_id, encargado_id, 
        metodo_pago_id, total, impuestos, descuento, notas
    ) VALUES (
        p_tienda_id, p_caja_id, p_empleado_id, p_encargado_id,
        p_metodo_pago_id, p_total, p_impuestos, p_descuento, p_notas
    );
    
    -- Obtener el ID de la venta insertada
    SET v_venta_id = LAST_INSERT_ID();
    
    -- Devolver el ID de la venta para usar en DetalleVenta
    SELECT v_venta_id AS venta_id;
    
    COMMIT;
END //
DELIMITER ;

-- Procedimiento almacenado para agregar detalle de venta y actualizar inventario
DELIMITER //
CREATE PROCEDURE AgregarDetalleVenta(
    IN p_venta_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_precio_unitario DECIMAL(10, 2),
    IN p_descuento_unitario DECIMAL(10, 2),
    IN p_tienda_id INT
)
BEGIN
    DECLARE v_subtotal DECIMAL(10, 2);
    DECLARE v_stock_actual INT;
    
    -- Calcular subtotal
    SET v_subtotal = (p_precio_unitario - p_descuento_unitario) * p_cantidad;
    
    -- Iniciar transacción
    START TRANSACTION;
    
    -- Verificar stock disponible
    SELECT cantidad INTO v_stock_actual 
    FROM Inventario 
    WHERE tienda_id = p_tienda_id AND producto_id = p_producto_id;
    
    IF v_stock_actual >= p_cantidad THEN
        -- Insertar detalle de venta
        INSERT INTO DetalleVenta (
            venta_id, producto_id, cantidad, precio_unitario, 
            descuento_unitario, subtotal
        ) VALUES (
            p_venta_id, p_producto_id, p_cantidad, p_precio_unitario,
            p_descuento_unitario, v_subtotal
        );
        
        -- Actualizar inventario
        UPDATE Inventario 
        SET cantidad = cantidad - p_cantidad 
        WHERE tienda_id = p_tienda_id AND producto_id = p_producto_id;
        
        -- Registrar movimiento de inventario
        INSERT INTO MovimientosInventario (
            tienda_id, producto_id, empleado_id, tipo_movimiento, 
            cantidad, motivo
        ) VALUES (
            p_tienda_id, p_producto_id, 
            (SELECT empleado_id FROM Ventas WHERE venta_id = p_venta_id), 
            'SALIDA', p_cantidad, CONCAT('Venta #', p_venta_id)
        );
        
        COMMIT;
        SELECT 'Éxito' AS resultado;
    ELSE
        ROLLBACK;
        SELECT 'Error: Stock insuficiente' AS resultado;
    END IF;
END //
DELIMITER ;

-- Procedimiento almacenado para registrar recepción de productos
DELIMITER //
CREATE PROCEDURE RegistrarRecepcion(
    IN p_tienda_id INT,
    IN p_proveedor_id INT,
    IN p_empleado_id INT,
    IN p_referencia VARCHAR(100),
    IN p_notas TEXT
)
BEGIN
    DECLARE v_recepcion_id INT;
    
    -- Iniciar transacción
    START TRANSACTION;
    
    -- Insertar la recepción
    INSERT INTO Recepciones (
        tienda_id, proveedor_id, empleado_id, referencia, notas
    ) VALUES (
        p_tienda_id, p_proveedor_id, p_empleado_id, p_referencia, p_notas
    );
    
    -- Obtener el ID de la recepción insertada
    SET v_recepcion_id = LAST_INSERT_ID();
    
    -- Devolver el ID de la recepción para usar en DetalleRecepcion
    SELECT v_recepcion_id AS recepcion_id;
    
    COMMIT;
END //
DELIMITER ;

-- Procedimiento almacenado para agregar detalle de recepción y actualizar inventario
DELIMITER //
CREATE PROCEDURE AgregarDetalleRecepcion(
    IN p_recepcion_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_precio_unitario DECIMAL(10, 2),
    IN p_posicion_id INT,
    IN p_tienda_id INT,
    IN p_empleado_id INT
)
BEGIN
    -- Iniciar transacción
    START TRANSACTION;
    
    -- Insertar detalle de recepción
    INSERT INTO DetalleRecepcion (
        recepcion_id, producto_id, cantidad, precio_unitario, posicion_id
    ) VALUES (
        p_recepcion_id, p_producto_id, p_cantidad, p_precio_unitario, p_posicion_id
    );
    
    -- Actualizar inventario - Si existe el producto, incrementar cantidad
    IF EXISTS (SELECT 1 FROM Inventario WHERE tienda_id = p_tienda_id AND producto_id = p_producto_id) THEN
        UPDATE Inventario 
        SET cantidad = cantidad + p_cantidad,
            posicion_id = IFNULL(p_posicion_id, posicion_id)
        WHERE tienda_id = p_tienda_id AND producto_id = p_producto_id;
    ELSE
        -- Si no existe, crear nuevo registro
        INSERT INTO Inventario (tienda_id, producto_id, cantidad, posicion_id)
        VALUES (p_tienda_id, p_producto_id, p_cantidad, p_posicion_id);
    END IF;
    
    -- Registrar movimiento de inventario
    INSERT INTO MovimientosInventario (
        tienda_id, producto_id, empleado_id, tipo_movimiento, 
        cantidad, motivo
    ) VALUES (
        p_tienda_id, p_producto_id, p_empleado_id, 
        'ENTRADA', p_cantidad, CONCAT('Recepción #', p_recepcion_id)
    );
    
    -- Actualizar precio de compra si ha cambiado
    UPDATE Productos
    SET precio_compra = p_precio_unitario
    WHERE producto_id = p_producto_id AND precio_compra != p_precio_unitario;
    
    COMMIT;
    SELECT 'Éxito' AS resultado;
END //
DELIMITER ;

-- Vista para mostrar niveles de inventario por tienda
CREATE VIEW VistaInventarioTiendas AS
SELECT 
    t.nombre AS tienda,
    c.nombre AS ciudad,
    e.nombre AS estado,
    p.codigo AS codigo_producto,
    p.nombre AS producto,
    cat.nombre AS categoria,
    i.cantidad,
    pa.nombre AS posicion,
    p.precio_compra,
    p.precio_venta,
    (p.precio_venta - p.precio_compra) AS margen,
    ((p.precio_venta - p.precio_compra) / p.precio_compra * 100) AS margen_porcentaje,
    (i.cantidad * p.precio_compra) AS valor_inventario
FROM Inventario i
JOIN Tiendas t ON i.tienda_id = t.tienda_id
JOIN Ciudades c ON t.ciudad_id = c.ciudad_id
JOIN Estados e ON c.estado_id = e.estado_id
JOIN Productos p ON i.producto_id = p.producto_id
JOIN Categorias cat ON p.categoria_id = cat.categoria_id
LEFT JOIN PosicionesAlmacen pa ON i.posicion_id = pa.posicion_id
WHERE i.cantidad > 0;

-- Vista para reporte de ventas diarias por tienda
CREATE VIEW VistaVentasDiarias AS
SELECT 
    DATE(v.fecha_venta) AS fecha,
    t.nombre AS tienda,
    c.nombre AS ciudad,
    e.nombre AS estado,
    COUNT(v.venta_id) AS total_transacciones,
    SUM(v.total) AS venta_total,
    SUM(v.impuestos) AS impuestos_total,
    SUM(v.descuento) AS descuentos_total,
    SUM(v.total - v.impuestos) AS venta_neta,
    SUM(dv.cantidad) AS unidades_vendidas,
    COUNT(DISTINCT v.empleado_id) AS vendedores_activos
FROM Ventas v
JOIN Tiendas t ON v.tienda_id = t.tienda_id
JOIN Ciudades c ON t.ciudad_id = c.ciudad_id
JOIN Estados e ON c.estado_id = e.estado_id
JOIN DetalleVenta dv ON v.venta_id = dv.venta_id
GROUP BY DATE(v.fecha_venta), t.tienda_id;

-- Vista para rendimiento de vendedores
CREATE VIEW VistaRendimientoVendedores AS
SELECT 
    CONCAT(e.nombre, ' ', e.apellido) AS vendedor,
    t.nombre AS tienda,
    DATE(v.fecha_venta) AS fecha,
    COUNT(DISTINCT v.venta_id) AS total_ventas,
    SUM(v.total) AS monto_total,
    AVG(v.total) AS ticket_promedio,
    SUM(dv.cantidad) AS unidades_vendidas
FROM Ventas v
JOIN Empleados e ON v.empleado_id = e.empleado_id
JOIN Tiendas t ON v.tienda_id = t.tienda_id
JOIN DetalleVenta dv ON v.venta_id = dv.venta_id
GROUP BY CONCAT(e.nombre, ' ', e.apellido), t.nombre, DATE(v.fecha_venta);

-- Vista para productos de bajo stock
CREATE VIEW VistaBajoStock AS
SELECT 
    t.nombre AS tienda,
    c.nombre AS ciudad,
    p.codigo AS codigo_producto,
    p.nombre AS producto,
    cat.nombre AS categoria,
    i.cantidad AS stock_actual,
    prov.nombre AS proveedor
FROM Inventario i
JOIN Tiendas t ON i.tienda_id = t.tienda_id
JOIN Ciudades c ON t.ciudad_id = c.ciudad_id
JOIN Productos p ON i.producto_id = p.producto_id
JOIN Categorias cat ON p.categoria_id = cat.categoria_id
LEFT JOIN Proveedores prov ON p.proveedor_id = prov.proveedor_id
WHERE i.cantidad <= 5;

-- Trigger para actualizar el precio de costo promedio
DELIMITER //
CREATE TRIGGER actualizarPrecioCosto
AFTER INSERT ON DetalleRecepcion
FOR EACH ROW
BEGIN
    DECLARE v_cantidad_total INT;
    DECLARE v_costo_total DECIMAL(10, 2);
    
    -- Calcular la cantidad total y costo total
    SELECT 
        SUM(dr.cantidad), 
        SUM(dr.cantidad * dr.precio_unitario)
    INTO 
        v_cantidad_total, 
        v_costo_total
    FROM DetalleRecepcion dr
    JOIN Recepciones r ON dr.recepcion_id = r.recepcion_id
    WHERE dr.producto_id = NEW.producto_id
    AND r.fecha_recepcion >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH);
    
    -- Actualizar el precio de compra con el promedio ponderado
    IF v_cantidad_total > 0 THEN
        UPDATE Productos
        SET precio_compra = v_costo_total / v_cantidad_total
        WHERE producto_id = NEW.producto_id;
    END IF;
END //
DELIMITER ;

-- Datos de ejemplo para Estados
INSERT INTO Estados (nombre, codigo) VALUES 
('Ciudad de México', 'CDMX'),
('Jalisco', 'JAL'),
('Nuevo León', 'NL'),
('Estado de México', 'EDOMEX'),
('Puebla', 'PUE');

-- Datos de ejemplo para Ciudades
INSERT INTO Ciudades (nombre, estado_id, codigo_postal) VALUES 
('Ciudad de México', 1, '06000'),
('Guadalajara', 2, '44100'),
('Monterrey', 3, '64000'),
('Toluca', 4, '50000'),
('Puebla', 5, '72000');

-- Datos de ejemplo para Categorías
INSERT INTO Categorias (nombre, descripcion) VALUES 
('Electrónicos', 'Productos electrónicos y gadgets'),
('Hogar', 'Artículos para el hogar'),
('Ropa', 'Prendas de vestir y accesorios'),
('Alimentos', 'Productos alimenticios'),
('Papelería', 'Artículos de oficina y papelería');

-- Datos de ejemplo para Roles
INSERT INTO Roles (nombre, descripcion) VALUES 
('Gerente', 'Administrador de tienda'),
('Vendedor', 'Atención al cliente y ventas'),
('Almacenista', 'Manejo de inventario y recepciones'),
('Cajero', 'Operación de caja registradora'),
('Encargado', 'Responsable durante turno específico');

-- Datos de ejemplo para Turnos
INSERT INTO Turnos (nombre, hora_inicio, hora_fin) VALUES 
('Matutino', '08:00:00', '16:00:00'),
('Vespertino', '16:00:00', '23:00:00'),
('Nocturno', '23:00:00', '08:00:00'),
('Completo', '09:00:00', '19:00:00'),
('Medio Turno Mañana', '09:00:00', '14:00:00');

-- Datos de ejemplo para Métodos de Pago
INSERT INTO MetodosPago (nombre, descripcion) VALUES 
('Efectivo', 'Pago en moneda nacional'),
('Tarjeta de Crédito', 'Pago con tarjeta de crédito'),
('Tarjeta de Débito', 'Pago con tarjeta de débito'),
('Transferencia', 'Transferencia bancaria'),
('Vales', 'Vales de despensa');