--Most Senior Employee--

Select *
From `Music.Employee` 
Order by levels desc;

--Countries with most invoices--

Select billing_city, billing_country,Count(billing_country) as number_of_invoices
From `Music.Invoice`
Group by billing_country, billing_city
Order by number_of_invoices desc;

--Top 3 invoice totals--

Select *
From `Music.Invoice`
Order by total desc
Limit 3;

--City with highest invoice--

Select billing_city, total
From `Music.Invoice`
Order by total desc
Limit 1;

--Customer with highest spend--

Select c.customer_id, c.first_name, c.last_name,c.city,c.country,Sum(i.total) as Total_spend
From `Music.Customer` c
Join `Music.Invoice` i on i.customer_id = c.customer_id
Group by c.customer_id, c. first_name, c.last_name, c.city, c.country
Order by Total_spend desc;

--Customers who listen to Rock Music--
Select Distinct c.first_name,c.last_name,c.email, g.name
From `Music.Customer` c
Join `Music.Invoice` i on i.customer_id = c.customer_id
Join `Music.Invoice_line` il on il.invoice_id = i.invoice_id
Join `Music.Track` t on t.track_id = il.track_id
Join `Music.Genre` g on g.genre_id = t.genre_id
Where g.name ='Rock';

--Top 10 rock artists--
Select a.artist_id, a.name, Count(t.track_id) as No_of_tracks
From `Music.Artist` a 
Join `Music.Album` al on al.artist_id = a.artist_id
Join `Music.Track` t on t.album_id = al.album_id
Join `Music.Genre` g on g.genre_id = t.genre_id
Where g.name = 'Rock'
Group by a.artist_id, a.name
Order by No_of_tracks desc
Limit 10;
-- Tracks longer than avg track length--

Select name, milliseconds
From `Music.Track`
Where milliseconds > (select Avg(milliseconds) as avg_track_length
From `Music.Track`);

--Customers spend on each artist--
With artist_sales as 
(Select a.artist_id,a.name as artist_name, il.invoice_id, 
(il.unit_price*il.quantity) as total_sales
From `Music.Invoice_line` il
Join `Music.Track` t on t.track_id = il.track_id
Join `Music.Album` al on al.album_id = t.album_id
Join `Music.Artist` a on a.artist_id = al.artist_id)
Select c.customer_id,c.first_name,c.last_name,
arts.artist_id,arts.artist_name, Sum(arts.total_sales) as total_spend
From artist_sales arts
Join `Music.Invoice` i on i.invoice_id = arts.invoice_id
Join `Music.Customer` c on c.customer_id = i.customer_id
Group by c.customer_id, c.first_name,c.last_name,arts.artist_id,arts.artist_name
Having sum(arts.total_sales) > 0
Order by total_spend desc;

--Popular Muisc Genre based on Purchases--
With GenreRanks as (
  Select i.billing_country as Country,
  g.name as genre,
  Count(*) as purchase_count
  From `Music.Invoice` i 
  Join `Music.Invoice_line` il on i.invoice_id = il.invoice_id
  Join `Music.Track` t on il.track_id = t.track_id
  Join `Music.Genre` g on t.genre_id = g.genre_id
  Group by i.billing_country, g.name
),
RankedGenres as ( Select *,
Rank() Over(Partition by country order by purchase_count DESC) as genre_rank
From GenreRanks)
Select country, genre, purchase_count
From RankedGenres
Where genre_rank = 1 ;

--Top Spending Customer for each Country--

With CustomerSpending as (
  Select c.customer_id, c.first_name, c.last_name, i.billing_country as country,
  Sum(i.total) as total_spend
  From `Music.Customer` c
  Join `Music.Invoice` i on c.customer_id = i.customer_id
  Group by c.customer_id, c.first_name, c.last_name, i.billing_country),
  RankedCustomers as (
    Select *,
    Rank() Over(Partition by country order by total_spend) as Rank
   From CustomerSpending)
   Select customer_id,first_name,last_name, country,total_spend
   From RankedCustomers
   Where rank = 1;
   
--Revenue vs Quantity Sold--

Select
  g.name as genre,
  Sum(il.quantity) as total_quantity_sold,
  Round(Sum(il.unit_price * il.quantity), 2) as total_revenue
From `Music.Invoice_line` il
Join `Music.Track` t on il.track_id = t.track_id
Join `Music.Genre` g on t.genre_id = g.genre_id
Group by g.name
Order by total_quantity_sold Desc;










