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

-- Vista4: Detalle ordenes de compra
CREATE VIEW vista_ordenes_compra_detalle AS
SELECT 
    oc.id_orden,
    oc.fecha_compra,
    p.nombre AS proveedor,
    p.email,
    m.nombre AS material,
    d.cantidad,
    d.precio_unitario,
    (d.cantidad * d.precio_unitario) AS total_linea
FROM Orden_Compra oc
JOIN Proveedor p ON oc.id_proveedor = p.id_proveedor
JOIN Detalle_Orden d ON oc.id_orden = d.id_orden
JOIN Material m ON d.id_material = m.id_material;

-- Vista5: Maquinaria asignada
CREATE VIEW vista_maquinaria_asignada AS
SELECT 
    o.nombre_obra,
    m.nombre_maquinaria,
    m.tipo,
    m.estado,
    am.fecha_inicio,
    am.fecha_fin
FROM Asignacion_Maquinaria am
JOIN Obra o ON am.id_obra = o.id_obra
JOIN Maquinaria m ON am.id_maquinaria = m.id_maquinaria;

-- Vista6: Cosumo de materiales
CREATE VIEW vista_consumo_total_materiales AS
SELECT 
    m.nombre AS material,
    m.unidad_medida,
    SUM(cm.cantidad) AS total_consumido
FROM Consumo_Material cm
JOIN Material m ON cm.id_material = m.id_material
GROUP BY m.nombre, m.unidad_medida;

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

-- Función3: obtener consumo total de materiales
DELIMITER //
CREATE FUNCTION obtener_total_consumo_material(p_id_material INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_consumo INT;

    SELECT IFNULL(SUM(cantidad), 0)
    INTO total_consumo
    FROM Consumo_Material
    WHERE id_material = p_id_material;

    RETURN total_consumo;
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

-- SP3: Obtener el personal asignado a cada obra
DELIMITER //
CREATE PROCEDURE sp_listar_personal_por_obra(IN p_id_obra INT)
BEGIN
    SELECT 
        o.nombre_obra,
        p.nombre,
        p.apellido,
        p.tipo,
        p.especialidad,
        ap.rol
    FROM Asignacion_Personal ap
    JOIN Personal p ON ap.id_personal = p.id_personal
    JOIN Obra o ON ap.id_obra = o.id_obra
    WHERE o.id_obra = p_id_obra;
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

-- Trigger3: actualiza el stock con cada nueva compra de materiales
DELIMITER //
CREATE TRIGGER trg_actualizar_stock_compra
AFTER INSERT ON Detalle_Orden
FOR EACH ROW
BEGIN
    DECLARE existe INT;

    -- Verificamos si el material ya está en Stock_Material
    SELECT COUNT(*) INTO existe
    FROM Stock_Material
    WHERE id_material = NEW.id_material;

    IF existe > 0 THEN
        -- Si ya existe, actualizamos el stock
        UPDATE Stock_Material
        SET cantidad_disponible = cantidad_disponible + NEW.cantidad
        WHERE id_material = NEW.id_material;
    ELSE
        -- Si no existe, lo insertamos
        INSERT INTO Stock_Material (id_material, cantidad_disponible)
        VALUES (NEW.id_material, NEW.cantidad);
    END IF;
END;
//
DELIMITER ;