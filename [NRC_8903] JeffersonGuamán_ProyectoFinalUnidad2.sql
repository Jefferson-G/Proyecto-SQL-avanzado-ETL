select * from playlists;
select * from customers;
select * from invoices;
select * from invoice_items;
select * from media_types;
select * from tracks;
select * from artists;
select * from employees;
select * from albums;
select * from genres;
select * from playlist_track;

--Nombre del agente de ventas correspondiente a cada cliente, así cómo también la Fecha de la primer y última compra de cada cliente, seguido del monto total que ha pagado entre esas fechas.  
select employees.FirstName as Nombre_Empleado ,customers.LastName as Apellido_Cliente, customers.FirstName as Nombre_Cliente, 
min(invoices.InvoiceDate) as Primer_Pago, max(invoices.InvoiceDate) as Ultimo_Pago
, sum(invoices.Total) as Total_Pagado
from invoices
inner join customers on invoices.CustomerId = customers.CustomerId
inner join employees on employees.EmployeeId=customers.SupportRepId
Group by customers.LastName;

--Lista de ventas con que se pudieron haber facturado más de 0.99 dolares con el 14% y sin el impuesto. 
--así como también de los 

select media_types.Name, genres.Name as Genero, albums.Title AS Album, artists.Name as Artista, tracks.Name as Canción, tracks.UnitPrice, sum(invoice_items.Quantity) as Total_Unidades_Vendidas,
    sum(invoice_items.Quantity*invoice_items.UnitPrice) as Total_Facturado,
    sum(invoice_items.Quantity*invoice_items.UnitPrice)*1.14 as Total_Impuesto_14
from tracks 
inner join invoice_items on tracks.TrackId = invoice_items.TrackId
inner join media_types on tracks.MediaTypeId = media_types.MediaTypeId
inner join albums on tracks.AlbumId = albums.AlbumId
inner join artists on albums.AlbumId = artists.ArtistId
inner join genres on tracks.GenreId = genres.GenreId
group by tracks.Name
having sum (invoice_items.Quantity*invoice_items.UnitPrice) >= 0.99;

--las pistas que no han estado en ninguna factura, muestre su id, nombre, compositor, album, valor unitario, nombre artista, 
--genero y tipo

select tracks.TrackId, tracks.Name, tracks.Composer, 
tracks.UnitPrice, albums.Title, artists.Name, 
genres.Name, media_types.Name
from tracks
inner join albums on tracks.AlbumId = albums.AlbumId
inner join artists on albums.ArtistId = artists.ArtistId
inner join genres on tracks.GenreId = genres.GenreId
inner join media_types on tracks.MediaTypeId = media_types.MediaTypeId
where TrackId NOT IN (
    SELECT TrackId
    from invoice_items);

--Nombres de clientes y el monto que han pagado cada uno de ellos, considerando que existan clientes
-- que estan registrados pero no han realizado una compra

select  employees.FirstName as Nombre_Empleado, customers.FirstName as Nombre_Cliente,
customers.LastName as Apellido_Cliente, customers.Country as País_Cliente,
count(customers.CustomerId) as Cantidad_de_Facturas, sum(invoices.Total) as Total_Pagado
from customers
LEFT JOIN invoices on customers.CustomerId = invoices.CustomerId
inner join employees on employees.EmployeeId=customers.SupportRepId
group by customers.FirstName;

-- Que pistas estan entre los 5510424 y 4331779 Bytes.

select tracks.Name, tracks.Composer, tracks.Bytes 
from tracks
inner join albums on tracks.AlbumId = albums.AlbumId
inner join artists on albums.ArtistId = artists.ArtistId
inner join genres on tracks.GenreId = genres.GenreId
inner join media_types on tracks.MediaTypeId = media_types.MediaTypeId
where tracks.Bytes between 4331779 and 5510424;

--Listar el Nombre y Apellido de los “Agentes de Ventas” así como la facturación de los clientes que tienen asignados, 
-- junto con la cantidad de artículos facturados y el precio asociado a las pistas con su respectivo album 
--y nombre del artista, con la facturación total.
SELECT employees.EmployeeId, employees.FirstName AS Nombre, employees.LastName AS Apellido, 
invoice_items.Quantity as Cantidad, tracks.UnitPrice as PrecioUnitario,  albums.Title as Nombre_Album,
artists.Name as Nombre_artista, sum(Total) AS Total_Facturas 
FROM invoices
inner join employees on employees.EmployeeId=customers.SupportRepId
inner join customers on customers.CustomerId=invoices.CustomerId
inner join invoice_items on invoices.InvoiceId= invoice_items.InvoiceId
inner join tracks on invoice_items.TrackId = tracks.TrackId
inner join albums on tracks.AlbumId = albums.AlbumId
inner join artists on albums.ArtistId = artists.ArtistId
GROUP BY EmployeeId
ORDER BY Total_Facturas DESC;
   
               
--Listar los 10 mejores clientes (aquellos a los que se les ha facturado más cantidad) 
--indicando Nombre, Apellidos, Pais, junto con la cantidad de artículos de facturas, el nombre de la pista, el nombre de la lista de reproducicion 
-- y tipo de medio mas el importe total de su facturación.
SELECT FirstName as Nombre, LastName as Apellido, Country as País, invoice_items.Quantity as CantidadArticulos,
tracks.Name as Pista,playlists.Name as Lista_Reproducción, media_types.Name as TipoDeMedio,  SUM(Total)as Factura
                 FROM  invoices
                 inner join customers on customers.CustomerId = invoices.CustomerId
                 inner join invoice_items on invoices.InvoiceId= invoice_items.InvoiceId
                 inner join tracks on invoice_items.TrackId = tracks.TrackId
                 inner join media_types on tracks.MediaTypeId= media_types.MediaTypeId
                 inner join playlist_track on tracks.TrackId = playlist_track.TrackId
                 inner join playlists on playlist_track.PlaylistId = playlists.PlaylistId
                 GROUP BY customers.CustomerId
                 ORDER BY Factura DESC
                 LIMIT 10;
 

--Proporcione una consulta que muestre la lista de reproducción, el nombre de la pista, su género musical, 
--mas el nombre del artista, el titulo del albúm y el tipo de medio de cada pista en orden desedente, 
--además calcule el maximo de milisegundos de cada pista.
SELECT  playlists.Name AS Lista_Reproducción, tracks.Name AS Nombre_Pista,
genres.Name AS Géneros_Musical, artists.Name AS Nombre_Artista,
albums.Title AS Titulo_Album, media_types.Name AS Tipo_Medio,
MAX(tracks.Milliseconds) AS "DuracionPista"
FROM tracks 
    INNER JOIN media_types ON media_types.MediaTypeId = tracks.MediaTypeId
    INNER JOIN genres ON genres.GenreId = tracks.GenreId
    INNER JOIN playlist_track ON playlist_track.TrackId = tracks.TrackId
    INNER JOIN playlists ON playlists.PlaylistId = playlist_track.PlaylistId
    INNER JOIN albums ON albums.AlbumId = tracks.AlbumId
    INNER JOIN artists ON artists.ArtistId = albums.ArtistId
GROUP BY tracks.TrackId
ORDER BY tracks.Name DESC
LIMIT 5;

                 
--Listar los 10 artistas, con su respectivo album, tipo de genero musical, el tipo de medio junto con su lista de reproduccion,
--con el mayor número de canciones de forma descendente, según el número de canciones.
SELECT artists.name as Grupo, albums.Title as Album, genres.Name as Tipo_Género,   
media_types.Name as Tipo_Medio, playlists.Name as Lista_Reproducción,  COUNT(*)as Canciones
                  FROM tracks 
                  inner join artists on artists.ArtistId=albums.ArtistId
                  inner join albums on albums.AlbumId=tracks.AlbumId
                  INNER JOIN genres ON genres.GenreId = tracks.GenreId
                  INNER JOIN media_types ON media_types.MediaTypeId = tracks.MediaTypeId
                  INNER JOIN playlist_track on playlist_track.TrackId = tracks.TrackId
                  INNER JOIN playlists ON playlists.PlaylistId = playlist_track.PlaylistId
                  GROUP BY artists.name
                  ORDER BY Canciones DESC
                  LIMIT 10;
                 
-- Consultar  el total de factura que an generado los agentes de Ventas desde una fecha inico y una fecha fin,
-- junto con que pais de los clientes se asociaron mas,  y que grupo de artistas resulto mas vendido junto con su album y
-- tipo de genero musical.                   
select e.FirstName||" "|| e.LastName as Agente_Ventas,
c.Country Ciudad , at.name as Grupo, a.Title as Album, 
g.Name as Tipo_Género,
count(i.InvoiceId) as TotalFacturas, min(InvoiceDate) as FechaMin,
max(InvoiceDate) as FechaMax, sum(Total) as ValorTotal
from invoices i
        inner join customers c on c.CustomerId = i.CustomerId
        inner join employees e on c.SupportRepId = e.EmployeeId
        inner join invoice_items it on i.InvoiceId= it.InvoiceId
        inner join tracks t on it.TrackId = t.TrackId
        inner join genres g on t.GenreId = g.GenreId
        inner join albums a on t.AlbumId = a.AlbumId
        inner join artists at on a.ArtistId = at.ArtistId
        group by Agente_Ventas
        order by ValorTotal DESC;

