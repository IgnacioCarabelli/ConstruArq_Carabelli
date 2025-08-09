-- Base de datos
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

-- Tabla: Personal_Tecnico

CREATE TABLE Personal_Tecnico (
id_tecnico INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
apellido VARCHAR(100) NOT NULL,
especialidad VARCHAR(50) NOT NULL,
telefono VARCHAR(20) NOT NULL UNIQUE,
email VARCHAR(100) NOT NULL UNIQUE
);


-- Tabla: Obrero

CREATE TABLE Obrero (
id_obrero INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
apellido VARCHAR(100) NOT NULL,
oficio VARCHAR(50) NOT NULL,
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

-- Tabla: Asignacion_Personal

CREATE TABLE Asignacion_Personal (
id_obra INT NOT NULL,
id_personal INT NOT NULL,
rol VARCHAR(20) NOT NULL,
PRIMARY KEY (id_obra, id_personal),
FOREIGN KEY (id_obra) REFERENCES Obra(id_obra)
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


-- CARGA DE DATOS

-- Insert: Materiales

INSERT INTO Material (nombre, unidad_medida) VALUES
('Cemento', 'kg'),
('Ladrillos', 'unidad'),
('Hierro', 'kg'),
('Arena', 'm3');

-- Insert: Stock Material

INSERT INTO Stock_Material (id_material, cantidad_disponible) VALUES
(1, 10000),
(2, 5000),
(3, 2500),
(4, 100);

-- Insert: Proveedores

INSERT INTO Proveedor (nombre, telefono, email, direccion) VALUES
('Construmax', '1165432100', 'ventas@construmax.com', 'Av. Libertador 1234'),
('Hierros SRL', '1134567890', 'contacto@hierrossrl.com', 'Calle 9 Nº 234'),
('Materiales Zona Norte', '1122334455', 'info@zonanorte.com', 'Ruta 8 km 35');

-- Insert: Personal Técnico

INSERT INTO Personal_Tecnico (nombre, apellido, especialidad, telefono, email) VALUES
('Juan', 'Pérez', 'Ingeniero Civil', '1111222233', 'juan.perez@ejemplo.com'),
('Laura', 'Martínez', 'Arquitecta', '1111445566', 'laura.martinez@ejemplo.com');

-- Insert: Obreros

INSERT INTO Obrero (nombre, apellido, oficio, telefono, email) VALUES
('Carlos', 'Gómez', 'Albañil', '1111999888', 'carlos.gomez@ejemplo.com'),
('Pedro', 'López', 'Plomero', '1111888777', 'pedro.lopez@ejemplo.com');

-- Insert: Maquinaria

INSERT INTO Maquinaria (nombre_maquinaria, tipo, estado) VALUES
('Excavadora CAT 320', 'Excavadora', 'Disponible'),
('Grúa Liebherr', 'Grúa', 'En uso');

-- Insert: Herramientas

INSERT INTO Herramienta (nombre, cantidad_total) VALUES
('Martillo', 50),
('Taladro', 20),
('Cinta métrica', 30);

-- Insert: Obras

INSERT INTO Obra (nombre_obra, ubicacion, fecha_inicio, fecha_fin) VALUES
('Torre Norte', 'Av. Córdoba 1234, CABA', '2025-07-01', '2026-12-31'),
('Residencias del Lago', 'Av. Libertador 5678, Tigre', '2025-08-01', '2026-10-15');

-- Insert: Asignación de Herramientas

INSERT INTO Asignacion_Herramienta (id_obra, id_herramienta, cantidad_asignada) VALUES
(1, 1, 10), -- Martillos a Torre Norte
(1, 2, 5), -- Taladros a Torre Norte
(2, 1, 8); -- Martillos a Residencias del Lago

-- Insert: Asignación de Maquinaria

INSERT INTO Asignacion_Maquinaria (id_obra, id_maquinaria, fecha_inicio, fecha_fin) VALUES
(1, 1, '2025-07-01', '2025-12-31'), -- Excavadora a Torre Norte
(2, 2, '2025-08-01', NULL); -- Grúa a Residencias del Lago

-- Insert: Asignación de Personal

INSERT INTO Asignacion_Personal (id_obra, id_personal, rol) VALUES
(1, 1, 'tecnico'), -- Juan Pérez a Torre Norte
(1, 3, 'obrero'), -- Carlos Gómez a Torre Norte
(2, 2, 'tecnico'), -- Laura Martínez a Residencias
(2, 4, 'obrero'); -- Pedro López a Residencias

-- Insert: Consumo de Materiales

INSERT INTO Consumo_Material (id_obra, id_material, cantidad, fecha_consumo) VALUES
(1, 1, 2000, '2025-07-10'), -- 2000kg de cemento
(1, 2, 1000, '2025-07-11'),
(2, 1, 1500, '2025-08-05'),
(2, 4, 10, '2025-08-06');

-- Insert: Órdenes de Compra

INSERT INTO Orden_Compra (id_proveedor, fecha_compra) VALUES
(1, '2025-07-05'),
(2, '2025-07-06');

-- Insert: Detalles de Orden

INSERT INTO Detalle_Orden (id_orden, id_material, cantidad, precio_unitario) VALUES
(1, 1, 5000, 15.50), -- Cemento
(1, 2, 2000, 8.00), -- Ladrillos
(2, 3, 1000, 25.00); -- Hierro
