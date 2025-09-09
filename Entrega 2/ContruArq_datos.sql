-- Crear base de datos y usarla
CREATE DATABASE IF NOT EXISTS constructora_db;
USE constructora_db;

-- Tabla: Obra
CREATE TABLE Obra (
    id_obra INT AUTO_INCREMENT PRIMARY KEY,
    nombre_obra VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(150) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE
);

-- Tabla: Personal (unificada)
CREATE TABLE Personal (
    id_personal INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL, -- 'tecnico' o 'obrero'
    especialidad VARCHAR(50),  -- especialidad o oficio
    telefono VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla: Maquinaria
CREATE TABLE Maquinaria (
    id_maquinaria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_maquinaria VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    estado VARCHAR(20) NOT NULL
);

-- Tabla: Herramienta
CREATE TABLE Herramienta (
    id_herramienta INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cantidad_total INT NOT NULL
);

-- Tabla: Material
CREATE TABLE Material (
    id_material INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL
);

-- Tabla: Stock_Material
CREATE TABLE Stock_Material (
    id_material INT PRIMARY KEY,
    cantidad_disponible INT NOT NULL,
    FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

-- Tabla: Proveedor
CREATE TABLE Proveedor (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    direccion VARCHAR(150)
);

-- Tabla: Orden_Compra
CREATE TABLE Orden_Compra (
    id_orden INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT NOT NULL,
    fecha_compra DATE NOT NULL,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
);

-- Tabla: Detalle_Orden
CREATE TABLE Detalle_Orden (
    id_orden INT NOT NULL,
    id_material INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_orden, id_material),
    FOREIGN KEY (id_orden) REFERENCES Orden_Compra(id_orden),
    FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

-- Tabla: Asignacion_Herramienta
CREATE TABLE Asignacion_Herramienta (
    id_obra INT NOT NULL,
    id_herramienta INT NOT NULL,
    cantidad_asignada INT NOT NULL,
    PRIMARY KEY (id_obra, id_herramienta),
    FOREIGN KEY (id_obra) REFERENCES Obra(id_obra),
    FOREIGN KEY (id_herramienta) REFERENCES Herramienta(id_herramienta)
);

-- Tabla: Asignacion_Maquinaria
CREATE TABLE Asignacion_Maquinaria (
    id_obra INT NOT NULL,
    id_maquinaria INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    PRIMARY KEY (id_obra, id_maquinaria),
    FOREIGN KEY (id_obra) REFERENCES Obra(id_obra),
    FOREIGN KEY (id_maquinaria) REFERENCES Maquinaria(id_maquinaria)
);

-- Tabla: Asignacion_Personal (ahora con FK a Personal)
CREATE TABLE Asignacion_Personal (
    id_obra INT NOT NULL,
    id_personal INT NOT NULL,
    rol VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_obra, id_personal),
    FOREIGN KEY (id_obra) REFERENCES Obra(id_obra),
    FOREIGN KEY (id_personal) REFERENCES Personal(id_personal)
);

-- Tabla: Consumo_Material
CREATE TABLE Consumo_Material (
    id_obra INT NOT NULL,
    id_material INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_consumo DATE NOT NULL,
    PRIMARY KEY (id_obra, id_material, fecha_consumo),
    FOREIGN KEY (id_obra) REFERENCES Obra(id_obra),
    FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

-- ==============
-- CARGA DE DATOS 
-- ==============

-- Materiales
INSERT INTO Material (nombre, unidad_medida) VALUES
('Cemento', 'kg'),
('Ladrillos', 'unidad'),
('Hierro', 'kg'),
('Arena', 'm3');

-- Stock Material
INSERT INTO Stock_Material (id_material, cantidad_disponible) VALUES
(1, 10000),
(2, 5000),
(3, 2500),
(4, 100);

-- Proveedores
INSERT INTO Proveedor (nombre, telefono, email, direccion) VALUES
('Construmax', '1165432100', 'ventas@construmax.com', 'Av. Libertador 1234'),
('Hierros SRL', '1134567890', 'contacto@hierrossrl.com', 'Calle 9 Nº 234'),
('Materiales Zona Norte', '1122334455', 'info@zonanorte.com', 'Ruta 8 km 35');

-- Personal Técnico (insertado en tabla unificada)
INSERT INTO Personal (nombre, apellido, tipo, especialidad, telefono, email) VALUES
('Juan', 'Pérez', 'tecnico', 'Ingeniero Civil', '1111222233', 'juan.perez@ejemplo.com'),
('Laura', 'Martínez', 'tecnico', 'Arquitecta', '1111445566', 'laura.martinez@ejemplo.com');

-- Obreros (insertado en tabla unificada)
INSERT INTO Personal (nombre, apellido, tipo, especialidad, telefono, email) VALUES
('Carlos', 'Gómez', 'obrero', 'Albañil', '1111999888', 'carlos.gomez@ejemplo.com'),
('Pedro', 'López', 'obrero', 'Plomero', '1111888777', 'pedro.lopez@ejemplo.com');

-- Maquinaria
INSERT INTO Maquinaria (nombre_maquinaria, tipo, estado) VALUES
('Excavadora CAT 320', 'Excavadora', 'Disponible'),
('Grúa Liebherr', 'Grúa', 'En uso');

-- Herramientas
INSERT INTO Herramienta (nombre, cantidad_total) VALUES
('Martillo', 50),
('Taladro', 20),
('Cinta métrica', 30);

-- Obras
INSERT INTO Obra (nombre_obra, ubicacion, fecha_inicio, fecha_fin) VALUES
('Torre Norte', 'Av. Córdoba 1234, CABA', '2025-07-01', '2026-12-31'),
('Residencias del Lago', 'Av. Libertador 5678, Tigre', '2025-08-01', '2026-10-15');

-- Asignación Herramientas
INSERT INTO Asignacion_Herramienta (id_obra, id_herramienta, cantidad_asignada) VALUES
(1, 1, 10),
(1, 2, 5),
(2, 1, 8);

-- Asignación Maquinaria
INSERT INTO Asignacion_Maquinaria (id_obra, id_maquinaria, fecha_inicio, fecha_fin) VALUES
(1, 1, '2025-07-01', '2025-12-31'),
(2, 2, '2025-08-01', NULL);

-- Asignación Personal (usando IDs reales)
-- Supongamos: 1=Juan, 2=Laura, 3=Carlos, 4=Pedro

INSERT INTO Asignacion_Personal (id_obra, id_personal, rol) VALUES
(1, 1, 'tecnico'), -- Juan Pérez
(1, 3, 'obrero'),  -- Carlos Gómez
(2, 2, 'tecnico'), -- Laura Martínez
(2, 4, 'obrero');  -- Pedro López

-- Consumo de materiales
INSERT INTO Consumo_Material (id_obra, id_material, cantidad, fecha_consumo) VALUES
(1, 1, 2000, '2025-07-10'),
(1, 2, 1000, '2025-07-11'),
(2, 1, 1500, '2025-08-05'),
(2, 4, 10, '2025-08-06');

-- Órdenes de Compra
INSERT INTO Orden_Compra (id_proveedor, fecha_compra) VALUES
(1, '2025-07-05'),
(2, '2025-07-06');

-- Detalles de Orden
INSERT INTO Detalle_Orden (id_orden, id_material, cantidad, precio_unitario) VALUES
(1, 1, 5000, 15.50),
(1, 2, 2000, 8.00),
(2, 3, 1000, 25.00);
