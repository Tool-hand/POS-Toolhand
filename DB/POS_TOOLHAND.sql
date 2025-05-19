-- Script para crear la base de datos y las tablas del sistema de punto de venta (POS) ToolHand.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Paso 1: Crear la Base de Datos si no existe
--------------------------------------------------------------------------------
sqlcmd -S localhost\SQLEXPRESS -E --Damos enter y esperamos a que se ejecute el script para entrar al modo interativo (>1), acontinuación copiamos y ejecutamos cada script uno por uno 
-----------------------------------------------
IF DB_ID('POS_TOOLHAND') IS NULL
BEGIN
    PRINT 'La base de datos [POS_TOOLHAND] no existe. Creándola ahora...';
    CREATE DATABASE [POS_TOOLHAND];
    PRINT 'Base de datos [POS_TOOLHAND] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos [POS_TOOLHAND] ya existe. No se requiere ninguna acción para su creación.';
END
GO

--------------------------------------------------------------------------------
-- Paso 2: Usar la Base de Datos recién creada o existente
--------------------------------------------------------------------------------
USE [POS_TOOLHAND];
GO

PRINT 'Contexto cambiado a la base de datos POS_TOOLHAND.';
GO
--------------------------------------------------------------------------------

-- Paso 3: Crear las Tablas
-- Tabla: Users
-- Propósito: Almacena información sobre los usuarios del sistema (empleados).
--------------------------------------------------------------------------------

PRINT 'Creando tabla Users...';
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),       -- Identificador único del usuario (autoincremental)
    UserId VARCHAR(255) UNIQUE NULL,        -- ID de usuario para login (puede ser el mismo que email o un código)
    FirstName VARCHAR(100) NOT NULL,        -- Nombre(s) del usuario
    LastName VARCHAR(100) NOT NULL,         -- Apellido(s) del usuario
    Password VARCHAR(255) NOT NULL,         -- Contraseña (¡Debe almacenarse hasheada en una aplicación real!)
    Email VARCHAR(255) UNIQUE NOT NULL,     -- Correo electrónico del usuario (único)
    Age INT NULL,                           -- Edad del usuario
    Gender VARCHAR(50) NULL,                -- Género del usuario
    Role VARCHAR(50) NOT NULL,              -- Rol del usuario en el sistema (Ej: "Admin", "Cajero", "Gerente")
    Salary DECIMAL(18, 2) NULL,             -- Salario del usuario (si aplica)
    JoinDate DATE NULL,                     -- Fecha de ingreso del usuario
    Birthdate DATE NULL,                    -- Fecha de nacimiento del usuario
    NID VARCHAR(100) NULL,                  -- Número de Identificación Nacional/Personal
    Phone VARCHAR(50) NULL,                 -- Número de teléfono
    HomeTown VARCHAR(255) NULL,             -- Ciudad de origen
    CurrentCity VARCHAR(255) NULL,          -- Ciudad actual de residencia
    Division VARCHAR(100) NULL,             -- División o departamento (si aplica)
    BloodGroup VARCHAR(10) NULL,            -- Grupo sanguíneo
    PostalCode VARCHAR(20) NULL             -- Código postal
);
GO

--------------------------------------------------------------------------------
-- Tabla: MainCategories
-- Propósito: Almacena las categorías principales de productos.
--------------------------------------------------------------------------------
PRINT 'Creando tabla MainCategories...';
CREATE TABLE MainCategories (
    MainCategoryId INT PRIMARY KEY IDENTITY(1,1), -- Identificador único de la categoría principal
    MainCategoryName VARCHAR(255) NOT NULL,       -- Nombre de la categoría principal (único idealmente)
    MainCategoryImage VARCHAR(255) NULL           -- URL o ruta a la imagen de la categoría principal
);
GO

--------------------------------------------------------------------------------
-- Tabla: SecondCategories
-- Propósito: Almacena las subcategorías (segundo nivel) de productos.
--------------------------------------------------------------------------------
PRINT 'Creando tabla SecondCategories...';
CREATE TABLE SecondCategories (
    SecondCategoryId INT PRIMARY KEY IDENTITY(1,1), -- Identificador único de la subcategoría
    MainCategoryId INT NOT NULL,                    -- FK a MainCategories
    SecondCategoryName VARCHAR(255) NOT NULL,       -- Nombre de la subcategoría
    SecondCategoryImage VARCHAR(255) NULL,          -- URL o ruta a la imagen de la subcategoría
    CONSTRAINT FK_SecondCategories_MainCategories FOREIGN KEY (MainCategoryId) REFERENCES MainCategories(MainCategoryId)
);
GO

--------------------------------------------------------------------------------
-- Tabla: ThirdCategories
-- Propósito: Almacena las categorías de tercer nivel de productos.
--------------------------------------------------------------------------------
PRINT 'Creando tabla ThirdCategories...';
CREATE TABLE ThirdCategories (
    ThirdCategoryId INT PRIMARY KEY IDENTITY(1,1),  -- Identificador único de la categoría de tercer nivel
    SecondCategoryId INT NOT NULL,                  -- FK a SecondCategories
    ThirdCategoryName VARCHAR(255) NOT NULL,        -- Nombre de la categoría de tercer nivel
    ThirdCategoryImage VARCHAR(255) NULL,           -- URL o ruta a la imagen de la categoría
    CONSTRAINT FK_ThirdCategories_SecondCategories FOREIGN KEY (SecondCategoryId) REFERENCES SecondCategories(SecondCategoryId)
);
GO

--------------------------------------------------------------------------------
-- Tabla: Vendors
-- Propósito: Almacena información sobre los proveedores de productos.
--------------------------------------------------------------------------------
PRINT 'Creando tabla Vendors...';
CREATE TABLE Vendors (
    VendorId INT PRIMARY KEY IDENTITY(1,1),         -- Identificador único del proveedor
    VendorTag VARCHAR(100) NULL,                    -- Etiqueta o código corto del proveedor (Corregido de "VednorTag")
    VendorName VARCHAR(255) NOT NULL,               -- Nombre del proveedor
    ThirdCategoryId INT NULL,                       -- FK a ThirdCategories (Categoría principal asociada al proveedor, según ERD)
    VendorDescription VARCHAR(MAX) NULL,            -- Descripción del proveedor
    VendorStatus VARCHAR(50) NULL,                  -- Estado del proveedor (Ej: "Activo", "Inactivo")
    VendorImage VARCHAR(255) NULL,                  -- URL o ruta al logo/imagen del proveedor
    RegisterDate DATE NULL,                         -- Fecha de registro del proveedor
    CONSTRAINT FK_Vendors_ThirdCategories FOREIGN KEY (ThirdCategoryId) REFERENCES ThirdCategories(ThirdCategoryId)
);
GO

--------------------------------------------------------------------------------
-- Tabla: Brands
-- Propósito: Almacena información sobre las marcas de los productos.
--------------------------------------------------------------------------------
PRINT 'Creando tabla Brands...';
CREATE TABLE Brands (
    BrandId INT PRIMARY KEY IDENTITY(1,1),          -- Identificador único de la marca
    BrandTag VARCHAR(100) NULL,                     -- Etiqueta o código corto de la marca
    BrandName VARCHAR(255) NOT NULL,                -- Nombre de la marca
    VendorId INT NULL,                              -- FK a Vendors (Proveedor principal de esta marca)
    BrandDescription VARCHAR(MAX) NULL,             -- Descripción de la marca
    BrandStatus VARCHAR(50) NULL,                   -- Estado de la marca (Ej: "Activa", "Discontinuada")
    BrandImage VARCHAR(255) NULL,                   -- URL o ruta al logo/imagen de la marca
    CONSTRAINT FK_Brands_Vendors FOREIGN KEY (VendorId) REFERENCES Vendors(VendorId)
);
GO

--------------------------------------------------------------------------------
-- Tabla: Products
-- Propósito: Catálogo central de todos los productos disponibles para la venta.
--------------------------------------------------------------------------------
PRINT 'Creando tabla Products...';
CREATE TABLE Products (
    ProductId INT PRIMARY KEY IDENTITY(1,1),        -- Identificador único del producto
    ProductTag VARCHAR(100) NULL,                   -- Etiqueta o código corto del producto
    OrderId INT NULL,                               -- Columna presente en ERD. Si es FK a Orders, crea dependencia circular. Se deja como INT NULL. Su propósito debe aclararse.
    ProductName VARCHAR(255) NOT NULL,              -- Nombre del producto
    BrandId INT NULL,                               -- FK a Brands (Marca a la que pertenece el producto)
    ProductDescription VARCHAR(MAX) NULL,           -- Descripción detallada del producto
    ProductQuantityPerUnit VARCHAR(100) NULL,       -- Ej: "1 Kg", "Paquete de 6", "Unidad"
    ProductPerUnitPrice DECIMAL(18, 2) NOT NULL,    -- Precio de venta unitario del producto
    ProductMSRP DECIMAL(18, 2) NULL,                -- Precio de venta sugerido por el fabricante o costo
    ProductStatus VARCHAR(50) NULL,                 -- Estado del producto (Ej: "Activo", "Agotado", "Discontinuado")
    ProductDiscountRate DECIMAL(5, 2) DEFAULT 0.00, -- Tasa de descuento aplicable (ej. 0.10 para 10%)
    ProductSize VARCHAR(50) NULL,                   -- Tamaño del producto (Ej: "Chico", "Grande", "500ml")
    ProductColor VARCHAR(50) NULL,                  -- Color del producto
    ProductWeight DECIMAL(10, 3) NULL,              -- Peso del producto (ej. en Kg)
    ProductUnitStock INT DEFAULT 0,                 -- Cantidad actual en inventario
    CONSTRAINT FK_Products_Brands FOREIGN KEY (BrandId) REFERENCES Brands(BrandId)
);
GO

--------------------------------------------------------------------------------
-- Tabla: BarCodes
-- Propósito: Almacena los códigos de barras.
--------------------------------------------------------------------------------
PRINT 'Creando tabla BarCodes...';
CREATE TABLE BarCodes (
    BarCodeId INT PRIMARY KEY IDENTITY(1,1),        -- Identificador único del registro de código de barras
    BarCode VARCHAR(255) NOT NULL UNIQUE            -- Valor del código de barras (debe ser único)
);
GO

--------------------------------------------------------------------------------
-- Tabla: Orders
-- Propósito: Registra cada transacción de venta (pedido).
--------------------------------------------------------------------------------
PRINT 'Creando tabla Orders...';
CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY(1,1),          -- Identificador único del pedido (autoincremental)
    UserId INT NOT NULL,                            -- FK a Users (Empleado que procesó el pedido)
    OrderTag VARCHAR(100) NULL,                     -- Etiqueta o nota para el pedido
    BarCodeId INT NULL,                             -- FK a BarCodes (Código de barras asociado a la orden general, ej: cupón, según ERD)
    [Date] DATETIME NOT NULL DEFAULT GETDATE(),     -- Fecha y hora de creación del pedido ("Date" entre corchetes por ser palabra reservada)
    ProductId INT NULL,                             -- FK a Products (Producto principal o si la orden es de un solo producto, según ERD)
    ProductName VARCHAR(255) NULL,                  -- Nombre del producto (denormalizado o para producto principal)
    ProductPerUnitPrice DECIMAL(18, 2) NULL,        -- Precio unitario (denormalizado o para producto principal)
    ProductQuantity INT NULL,                       -- Cantidad (denormalizado o para producto principal)
    OrderStatus VARCHAR(50) NOT NULL,               -- Estado del pedido (Ej: "Pendiente", "Completado", "Cancelado")
    PaymentMethod VARCHAR(100) NULL,                -- Método de pago utilizado
    TotalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0.00, -- Monto total del pedido
    CustomerFullName VARCHAR(200) NULL,             -- Nombre completo del cliente (si se registra)
    CustomerPhone VARCHAR(50) NULL,                 -- Teléfono del cliente
    CustomerEmail VARCHAR(255) NULL,                -- Email del cliente
    CustomerAddress VARCHAR(MAX) NULL,              -- Dirección del cliente
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
    CONSTRAINT FK_Orders_BarCodes FOREIGN KEY (BarCodeId) REFERENCES BarCodes(BarCodeId),
    CONSTRAINT FK_Orders_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);
GO

--------------------------------------------------------------------------------
-- Tabla: OrdersProductsMap
-- Propósito: Tabla de unión para la relación muchos-a-muchos entre Orders y Products.
--            Permite que un pedido tenga múltiples productos.
--------------------------------------------------------------------------------
PRINT 'Creando tabla OrdersProductsMap...';
CREATE TABLE OrdersProductsMap (
    OrderProductsCategoriesId INT PRIMARY KEY IDENTITY(1,1), -- PK de la tabla. El nombre "Categories" aquí es según ERD.
    OrderId INT NOT NULL,                                    -- FK a Orders
    ProductId INT NOT NULL,                                  -- FK a Products
    -- Se podrían añadir columnas como QuantityOfProductInOrder, UnitPriceAtSale si no se manejan en la tabla Orders.
    CONSTRAINT FK_OrdersProductsMap_Orders FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    CONSTRAINT FK_OrdersProductsMap_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT UQ_OrdersProductsMap_OrderProduct UNIQUE (OrderId, ProductId) -- Para evitar duplicados del mismo producto en la misma orden.
);
GO

--------------------------------------------------------------------------------
-- Tabla: ProCateMap
-- Propósito: Tabla desnormalizada para búsquedas y reportes rápidos,
--            consolidando información de productos, categorías, marcas y proveedores.
--------------------------------------------------------------------------------
PRINT 'Creando tabla ProCateMap...';
CREATE TABLE ProCateMap (
    PCID INT PRIMARY KEY IDENTITY(1,1),             -- Identificador único del registro en el mapa
    ProductId INT NOT NULL,                         -- FK a Products
    ProductName VARCHAR(255) NULL,                  -- Denormalizado desde Products
    BrandId INT NOT NULL,                           -- FK a Brands
    BrandName VARCHAR(255) NULL,                    -- Denormalizado desde Brands
    VendorId INT NOT NULL,                          -- FK a Vendors
    VendorName VARCHAR(255) NULL,                   -- Denormalizado desde Vendors
    MainCategoryId INT NOT NULL,                    -- FK a MainCategories
    MainCategoryName VARCHAR(255) NULL,             -- Denormalizado desde MainCategories
    SecondCategoryId INT NOT NULL,                  -- FK a SecondCategories
    SecondCategoryName VARCHAR(255) NULL,           -- Denormalizado desde SecondCategories
    ThirdCategoryId INT NOT NULL,                   -- FK a ThirdCategories
    ThirdCategoryName VARCHAR(255) NULL,            -- Denormalizado desde ThirdCategories
    CONSTRAINT FK_ProCateMap_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT FK_ProCateMap_Brands FOREIGN KEY (BrandId) REFERENCES Brands(BrandId),
    CONSTRAINT FK_ProCateMap_Vendors FOREIGN KEY (VendorId) REFERENCES Vendors(VendorId),
    CONSTRAINT FK_ProCateMap_MainCategories FOREIGN KEY (MainCategoryId) REFERENCES MainCategories(MainCategoryId),
    CONSTRAINT FK_ProCateMap_SecondCategories FOREIGN KEY (SecondCategoryId) REFERENCES SecondCategories(SecondCategoryId),
    CONSTRAINT FK_ProCateMap_ThirdCategories FOREIGN KEY (ThirdCategoryId) REFERENCES ThirdCategories(ThirdCategoryId)
);
GO

--------------------------------------------------------------------------------
-- Tabla: Expenses
-- Propósito: Registra los gastos operativos del negocio.
--------------------------------------------------------------------------------
PRINT 'Creando tabla Expenses...';
CREATE TABLE Expenses (
    ExpenseId INT PRIMARY KEY IDENTITY(1,1),        -- Identificador único del gasto
    ExpenseTag VARCHAR(100) NULL,                   -- Etiqueta o categoría del gasto
    ExpenseName VARCHAR(255) NOT NULL,              -- Nombre o descripción del gasto
    ExpenseAmount DECIMAL(18, 2) NOT NULL,          -- Monto del gasto
    ExpenseDate DATE NOT NULL                       -- Fecha en que se realizó el gasto
);
GO