-- Trigger que se dispara despu�s de ejecutar el procedimiento almacenado
USE Super;

CREATE TRIGGER Trigger_InsertarFactura
ON Ventas
AFTER INSERT
AS
BEGIN
    DECLARE @IVA DECIMAL(10, 2);
    DECLARE @Descuento DECIMAL(10, 2);
    DECLARE @SubTotal DECIMAL(10, 2);
    DECLARE @Total DECIMAL(10, 2);
    DECLARE @NIT VARCHAR(20);
    DECLARE @ID_Cliente INT;
    DECLARE @ID_Venta INT;
    DECLARE @Cliente VARCHAR(60);

    -- Declarar e inicializar el cursor para obtener el �ltimo cliente ingresado
    DECLARE UltimoClienteCursor CURSOR FOR
    SELECT TOP 1 ID_Cliente
    FROM Clientes
    ORDER BY ID_Cliente DESC;

    -- Abrir el cursor
    OPEN UltimoClienteCursor;

    -- Obtener el ID_Cliente del �ltimo cliente
    FETCH NEXT FROM UltimoClienteCursor INTO @ID_Cliente;

    -- Cerrar y liberar el cursor
    CLOSE UltimoClienteCursor;
    DEALLOCATE UltimoClienteCursor;

    -- Obt�n el valor de ID_Venta de la fila reci�n insertada en la tabla Ventas
    SELECT @ID_Venta = ID_Venta FROM Inserted;

    -- Obt�n los dem�s valores de la venta
    SELECT
        @IVA = 0.13 * v.MontoVenta,
        @Descuento = 0.00,
        @SubTotal = v.MontoVenta,
        @Total = v.MontoVenta * 1.13,
        @NIT = '12345778978956'
    FROM Inserted i
    JOIN Ventas v ON i.ID_Venta = v.ID_Venta;

    -- Obt�n el nombre del cliente
    SELECT @Cliente = Nombres FROM Clientes WHERE ID_Cliente = @ID_Cliente;

    -- Inserta una nueva factura en la tabla Facturas
    INSERT INTO Facturas (IVA, Descuento, SubTotal, Total, NIT, ID_Cliente, ID_Venta)
    VALUES (@IVA, @Descuento, @SubTotal, @Total, @NIT, @ID_Cliente, @ID_Venta);

    -- Muestra un mensaje al finalizar la operaci�n
    PRINT 'Nueva factura registrada para el cliente: ' + @Cliente;
END;


USE Super;

-- Ejecuta el procedimiento con una fecha de venta y un monto espec�ficos
-- Luego del insert en la tabla ventas se debe disparar el trigger, asignando
-- una factura al cliente m�s reciente en la tabla
EXEC InsertarVenta
@FechaVenta = '2023-11-13',
@MontoVenta = 300.00;

select * from Facturas;
select * from Ventas;