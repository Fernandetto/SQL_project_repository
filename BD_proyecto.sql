---------------------------------------------------------
-- CREAR ESQUEMA
---------------------------------------------------------
CREATE SCHEMA restaurante;
GO


---------------------------------------------------------
-- 1. CATEGORIAS
---------------------------------------------------------
CREATE TABLE restaurante.Categorias (
    CategoriaId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion NVARCHAR(250) NULL
);
GO


---------------------------------------------------------
-- 2. MESEROS
---------------------------------------------------------
CREATE TABLE restaurante.Meseros (
    MeseroId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL,
    Telefono NVARCHAR(20) NULL,
    Email NVARCHAR(150) NULL,
    FechaIngreso DATE NOT NULL DEFAULT (GETDATE())
);
GO


---------------------------------------------------------
-- 3. MESAS
---------------------------------------------------------
CREATE TABLE restaurante.Mesas (
    MesaId INT IDENTITY(1,1) PRIMARY KEY,
    Numero INT NOT NULL UNIQUE,
    Capacidad INT NOT NULL CHECK (Capacidad > 0),
    Estado NVARCHAR(20) NOT NULL DEFAULT ('Libre')  -- Libre/Ocupada/Reservada
);
GO


---------------------------------------------------------
-- 4. MENÚ PRODUCTOS
---------------------------------------------------------
CREATE TABLE restaurante.MenuProductos (
    ProductoId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(200) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    Precio DECIMAL(10,2) NOT NULL CHECK (Precio >= 0),
    CategoriaId INT NOT NULL,
    Activo BIT NOT NULL DEFAULT (1),
    CONSTRAINT FK_MenuProductos_Categorias FOREIGN KEY (CategoriaId)
        REFERENCES restaurante.Categorias (CategoriaId)
        ON DELETE NO ACTION
);
GO


---------------------------------------------------------
-- 5. ÓRDENES
---------------------------------------------------------
CREATE TABLE restaurante.Ordenes (
    OrdenId INT IDENTITY(1,1) PRIMARY KEY,
    MesaId INT NOT NULL,
    MeseroId INT NOT NULL,
    FechaCreacion DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    FechaCierre DATETIME2 NULL,
    Total DECIMAL(12,2) NULL,
    Estado NVARCHAR(30) NOT NULL DEFAULT ('Abierta'),
    Comentarios NVARCHAR(500) NULL,
    CONSTRAINT FK_Ordenes_Mesas FOREIGN KEY (MesaId)
        REFERENCES restaurante.Mesas (MesaId)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Ordenes_Meseros FOREIGN KEY (MeseroId)
        REFERENCES restaurante.Meseros (MeseroId)
        ON DELETE NO ACTION
);
GO


---------------------------------------------------------
-- 6. DETALLES ORDEN
---------------------------------------------------------
CREATE TABLE restaurante.DetallesOrden (
    DetalleId INT IDENTITY(1,1) PRIMARY KEY,
    OrdenId INT NOT NULL,
    ProductoId INT NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL CHECK (PrecioUnitario >= 0),
    Subtotal AS (Cantidad * PrecioUnitario) PERSISTED,
    Estado NVARCHAR(30) NOT NULL DEFAULT ('Pendiente'),
    CONSTRAINT FK_DetallesOrden_Ordenes FOREIGN KEY (OrdenId)
        REFERENCES restaurante.Ordenes (OrdenId)
        ON DELETE CASCADE,
    CONSTRAINT FK_DetallesOrden_Productos FOREIGN KEY (ProductoId)
        REFERENCES restaurante.MenuProductos (ProductoId)
        ON DELETE NO ACTION
);
GO


---------------------------------------------------------
-- ÍNDICES RECOMENDADOS
---------------------------------------------------------
CREATE INDEX IX_MenuProductos_Categoria ON restaurante.MenuProductos (CategoriaId);
CREATE INDEX IX_Ordenes_Mesa_Fecha ON restaurante.Ordenes (MesaId, FechaCreacion);
CREATE INDEX IX_DetallesOrden_Orden ON restaurante.DetallesOrden (OrdenId);
GO


---------------------------------------------------------
-- DATOS DE EJEMPLO (SEED)
---------------------------------------------------------
INSERT INTO restaurante.Categorias (Nombre, Descripcion) VALUES
('Entradas','Entradas frías y calientes'),
('Platos Fuertes','Platos principales'),
('Bebidas','Bebidas alcohólicas y no alcohólicas');

INSERT INTO restaurante.Meseros (Nombre, Telefono, Email) VALUES
('Carlos Pérez','+50412345678','carlos@restaurante.example'),
('María López','+50487654321','maria@restaurante.example');

INSERT INTO restaurante.Mesas (Numero, Capacidad, Estado) VALUES
(1,4,'Libre'),
(2,2,'Libre'),
(3,6,'Libre');

INSERT INTO restaurante.MenuProductos (Nombre, Descripcion, Precio, CategoriaId) VALUES
('Sopa del Día','Sopa casera',55.00,1),
('Hamburguesa Clásica','Carne de res 200g',120.00,2),
('Coca-Cola 500ml','Refresco',25.00,3);
GO