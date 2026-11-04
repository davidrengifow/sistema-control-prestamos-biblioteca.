CREATE DATABASE IF NOT EXISTS biblioteca_coil
CHARACTER SET utf8mb4;

USE biblioteca_coil;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_alumno VARCHAR(30) UNIQUE,
    id_docente VARCHAR(30) UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    turno VARCHAR(30),
    curso VARCHAR(50),
    especialidad VARCHAR(100),
    ci VARCHAR(30) NOT NULL UNIQUE,
    correo_electronico VARCHAR(120) NOT NULL,
    
    CONSTRAINT chk_tipo_usuario CHECK (
        (id_alumno IS NOT NULL AND id_docente IS NULL)
        OR
        (id_alumno IS NULL AND id_docente IS NOT NULL)
    )
);

CREATE TABLE libro (
    id_libro INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    autor VARCHAR(120) NOT NULL,
    editorial VARCHAR(100),
    isbn VARCHAR(20) UNIQUE
);

CREATE TABLE ejemplar (
    id_ejemplar INT AUTO_INCREMENT PRIMARY KEY,
    id_libro INT NOT NULL,
    codigo_inventario VARCHAR(40) NOT NULL UNIQUE,
    condicion_libro VARCHAR(50) NOT NULL,
    habilitacion_prestamo BOOLEAN NOT NULL DEFAULT TRUE,
    cantidad_ejemplares INT NOT NULL DEFAULT 1,

    CONSTRAINT fk_ejemplar_libro
        FOREIGN KEY (id_libro)
        REFERENCES libro(id_libro),

    CONSTRAINT chk_cantidad_ejemplar
        CHECK (cantidad_ejemplares = 1)
);

CREATE TABLE prestamo (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_ejemplar INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion DATE,

    CONSTRAINT fk_prestamo_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario),

    CONSTRAINT fk_prestamo_ejemplar
        FOREIGN KEY (id_ejemplar)
        REFERENCES ejemplar(id_ejemplar),

    CONSTRAINT chk_fechas_prestamo
        CHECK (
            fecha_devolucion IS NULL
            OR fecha_devolucion >= fecha_prestamo
        )
);

INSERT INTO usuario (
    id_alumno, id_docente, nombre, apellido,
    turno, curso, especialidad, ci, correo_electronico
)
VALUES
(
    'ALU001', NULL, 'Ana', 'Gomez',
    'Manana', 'Segundo', 'Informatica',
    '7000001', 'ana@example.com'
),
(
    'ALU002', NULL, 'Luis', 'Perez',
    'Noche', 'Tercero', 'Administracion',
    '7000002', 'luis@example.com'
),
(
    NULL, 'DOC001', 'Maria', 'Lopez',
    'Manana', NULL, 'Base de datos',
    '7000003', 'maria@example.com'
);

INSERT INTO libro (nombre, autor, editorial, isbn)
VALUES
    ('Introduccion a SQL', 'Ana Torres', 'Editorial Alfa', NULL),
    ('Programacion en Python', 'Luis Ramirez', 'Editorial Beta', NULL),
    ('Fundamentos de Redes', 'Maria Duarte', 'Editorial Gamma', NULL);

INSERT INTO ejemplar (
    id_libro, codigo_inventario, condicion_libro,
    habilitacion_prestamo, cantidad_ejemplares
)
VALUES
    (1, 'INV001', 'Bueno', TRUE, 1),
    (1, 'INV002', 'Bueno', TRUE, 1),
    (2, 'INV003', 'Bueno', TRUE, 1),
    (3, 'INV004', 'En reparacion', FALSE, 1);

INSERT INTO prestamo (
    id_usuario, id_ejemplar,
    fecha_prestamo, fecha_devolucion
)
VALUES
    (1, 1, '2026-10-25', '2026-10-30'),
    (2, 3, '2026-11-01', NULL),
    (3, 1, '2026-11-02', NULL);

SHOW TABLES;

SELECT * FROM usuario;
SELECT * FROM libro;
SELECT * FROM ejemplar;
SELECT * FROM prestamo;

SELECT
    p.id_prestamo,
    CONCAT(u.nombre, ' ', u.apellido) AS usuario,
    l.nombre AS libro,
    e.codigo_inventario,
    p.fecha_prestamo,
    p.fecha_devolucion
FROM prestamo p
INNER JOIN usuario u
    ON p.id_usuario = u.id_usuario
INNER JOIN ejemplar e
    ON p.id_ejemplar = e.id_ejemplar
INNER JOIN libro l
    ON e.id_libro = l.id_libro
ORDER BY p.id_prestamo;

SELECT
    p.id_prestamo,
    u.nombre,
    u.apellido,
    l.nombre AS libro,
    e.codigo_inventario,
    p.fecha_prestamo
FROM prestamo p
INNER JOIN usuario u
    ON p.id_usuario = u.id_usuario
INNER JOIN ejemplar e
    ON p.id_ejemplar = e.id_ejemplar
INNER JOIN libro l
    ON e.id_libro = l.id_libro
WHERE p.fecha_devolucion IS NULL;

SELECT
    e.id_ejemplar,
    e.codigo_inventario,
    l.nombre AS libro,
    e.condicion_libro
FROM ejemplar e
INNER JOIN libro l
    ON e.id_libro = l.id_libro
WHERE e.habilitacion_prestamo = TRUE
AND NOT EXISTS (
    SELECT 1
    FROM prestamo p
    WHERE p.id_ejemplar = e.id_ejemplar
      AND p.fecha_devolucion IS NULL
);

SELECT
    l.id_libro,
    l.nombre AS libro,
    COUNT(e.id_ejemplar) AS total_ejemplares
FROM libro l
LEFT JOIN ejemplar e
    ON l.id_libro = e.id_libro
GROUP BY l.id_libro, l.nombre;

SELECT
    p.id_prestamo,
    l.nombre AS libro,
    e.codigo_inventario,
    p.fecha_prestamo,
    p.fecha_devolucion
FROM prestamo p
INNER JOIN ejemplar e
    ON p.id_ejemplar = e.id_ejemplar
INNER JOIN libro l
    ON e.id_libro = l.id_libro
WHERE p.id_usuario = 1
ORDER BY p.fecha_prestamo DESC;
