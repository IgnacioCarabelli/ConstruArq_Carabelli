-- Vista1: Stock Actual
CREATE VIEW vista_stock_actual AS
SELECT m.nombre AS material, sm.cantidad_disponible, m.unidad_medida
FROM Stock_Material sm
JOIN Material m ON sm.id_material = m.id_material;

-- Vista2: Consumo por Obra
CREATE VIEW vista_consumo_por_obra AS
SELECT o.nombre_obra, m.nombre AS material, cm.cantidad, cm.fecha_consumo
FROM Consumo_Material cm
JOIN Obra o ON cm.id_obra = o.id_obra
JOIN Material m ON cm.id_material = m.id_material;

-- Vista3: Asignación de personal
CREATE VIEW vista_asignacion_personal AS
SELECT o.nombre_obra, p.nombre, p.apellido, p.tipo, ap.rol
FROM Asignacion_Personal ap
JOIN Personal p ON ap.id_personal = p.id_personal
JOIN Obra o ON ap.id_obra = o.id_obra;

-- ---------------------------------------------------------------------

-- Función: calcular stock total
DELIMITER //
CREATE FUNCTION calcular_stock_total()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT SUM(cantidad_disponible) INTO total FROM Stock_Material;
    RETURN total;
END;
//
DELIMITER ;

-- Función: calcular costo total de una orden
DELIMITER //
CREATE FUNCTION calcular_total_orden(id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(cantidad * precio_unitario)
    INTO total
    FROM Detalle_Orden
    WHERE id_orden = id;
    RETURN total;
END;
//
DELIMITER ;

-- ---------------------------------------------------------------------

-- Función1: calcular stock total
DELIMITER //
CREATE FUNCTION calcular_stock_total()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT SUM(cantidad_disponible) INTO total FROM Stock_Material;
    RETURN total;
END;
//
DELIMITER ;

-- Función2: calcular costo total de una orden
DELIMITER //
CREATE FUNCTION calcular_total_orden(id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(cantidad * precio_unitario)
    INTO total
    FROM Detalle_Orden
    WHERE id_orden = id;
    RETURN total;
END;
//
DELIMITER ;

-- ---------------------------------------------------------------------

-- SP1: Agregar nuevo material
DELIMITER //
CREATE PROCEDURE sp_agregar_material (
    IN p_nombre VARCHAR(100),
    IN p_unidad_medida VARCHAR(20),
    IN p_cantidad INT
)
BEGIN
    INSERT INTO Material (nombre, unidad_medida) VALUES (p_nombre, p_unidad_medida);
    INSERT INTO Stock_Material (id_material, cantidad_disponible)
    VALUES (LAST_INSERT_ID(), p_cantidad);
END;
//
DELIMITER ;

-- SP2: Obtener consumo de material por obra
DELIMITER //
CREATE PROCEDURE sp_consumo_por_obra (IN obra_id INT)
BEGIN
    SELECT m.nombre AS material, cm.cantidad, cm.fecha_consumo
    FROM Consumo_Material cm
    JOIN Material m ON cm.id_material = m.id_material
    WHERE cm.id_obra = obra_id;
END;
//
DELIMITER ;

-- ---------------------------------------------------------------------

-- Trigger1: Actualizar stock al consumir material
DELIMITER //
CREATE TRIGGER tr_descuento_stock
AFTER INSERT ON Consumo_Material
FOR EACH ROW
BEGIN
    UPDATE Stock_Material
    SET cantidad_disponible = cantidad_disponible - NEW.cantidad
    WHERE id_material = NEW.id_material;
END;
//
DELIMITER ;

-- Trigger2: Validar cantidad disponible
DELIMITER //
CREATE TRIGGER tr_validar_stock
BEFORE INSERT ON Consumo_Material
FOR EACH ROW
BEGIN
    DECLARE disponible INT;
    SELECT cantidad_disponible INTO disponible
    FROM Stock_Material
    WHERE id_material = NEW.id_material;

    IF disponible < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para realizar el consumo';
    END IF;
END;
//
DELIMITER ;

