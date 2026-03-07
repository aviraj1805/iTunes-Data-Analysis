-- iTunes Music Store Database Analysis
-- MySQL Internship Project
-- Database: itunes_db

use itunes_db;

-- ========================================
-- Part 1: Setting up Primary and Foreign Keys
-- ========================================

-- Adding primary keys to all tables
alter table artist add primary key (artist_id);
alter table album add primary key (album_id);
alter table media_type add primary key (media_type_id);
alter table genre add primary key (genre_id);
alter table playlist add primary key (playlist_id);
alter table employee add primary key (employee_id);
alter table customer add primary key (customer_id);
alter table track add primary key (track_id);
alter table invoice add primary key (invoice_id);
alter table invoice_line add primary key (invoice_line_id);
alter table playlist_track add primary key (playlist_id, track_id);

-- Setting up foreign key relationships
alter table album
  add constraint fk_album_artist
  foreign key (artist_id) references artist(artist_id);

alter table track
  add constraint fk_track_album
  foreign key (album_id) references album(album_id);

alter table track
  add constraint fk_track_genre
  foreign key (genre_id) references genre(genre_id);

alter table track
  add constraint fk_track_mediatype
  foreign key (media_type_id) references media_type(media_type_id);

alter table customer
  add constraint fk_customer_employee
  foreign key (support_rep_id) references employee(employee_id);

alter table invoice
  add constraint fk_invoice_customer
  foreign key (customer_id) references customer(customer_id);

alter table invoice_line
  add constraint fk_invoiceline_invoice
  foreign key (invoice_id) references invoice(invoice_id);

-- Note: Some foreign keys skipped due to data issues

alter table playlist_track
  add constraint fk_playlisttrack_playlist
  foreign key (playlist_id) references playlist(playlist_id);

alter table playlist_track
  add constraint fk_playlisttrack_track
  foreign key (track_id) references track(track_id);


-- ========================================
-- Part 2: Basic Data Exploration
-- ========================================

-- Checking how many records are in each table
select 'artist' as table_name, count(*) as total_rows from artist
union all
select 'album', count(*) from album
union all
select 'track', count(*) from track
union all
select 'genre', count(*) from genre
union all
select 'media_type', count(*) from media_type
union all
select 'playlist', count(*) from playlist
union all
select 'employee', count(*) from employee
union all
select 'customer', count(*) from customer
union all
select 'invoice', count(*) from invoice
union all
select 'invoice_line', count(*) from invoice_line;

-- Looking for any data quality issues
select count(*) as customers_with_no_rep
from customer
where support_rep_id is null;

select count(*) as tracks_with_no_genre
from track
where genre_id is null;

-- Checking the date range of our sales data
select
    min(invoice_date) as first_sale,
    max(invoice_date) as last_sale
from invoice;

-- Quick business overview
select
    count(*) as total_customers
from customer;

select
    count(*) as total_invoices,
    round(sum(total), 2) as total_revenue
from invoice;


-- ========================================
-- Part 3: Customer Analysis Questions
-- ========================================

-- Q1: Who are our top 10 spending customers?
select
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    c.country,
    round(sum(i.total), 2) as total_spent
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name, c.country
order by total_spent desc
limit 10;

-- Q2: What's the average customer lifetime value?
select
    round(avg(customer_total), 2) as avg_lifetime_value
from (
    select customer_id, sum(total) as customer_total
    from invoice
    group by customer_id
) as totals;

-- Q3: How many customers are repeat buyers vs one-time buyers?
select
    case
        when purchase_count = 1 then 'One-Time'
        else 'Repeat'
    end as customer_type,
    count(*) as num_customers
from (
    select customer_id, count(invoice_id) as purchase_count
    from invoice
    group by customer_id
) as purchases
group by customer_type;

-- Q4: Revenue per customer by country
select
    c.country,
    count(distinct c.customer_id) as num_customers,
    round(sum(i.total), 2) as total_revenue,
    round(sum(i.total) / count(distinct c.customer_id), 2) as revenue_per_customer
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.country
order by revenue_per_customer desc;

-- Q5: Which customers haven't purchased recently?
-- (using last 6 months as cutoff)
select
    concat(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    max(i.invoice_date) as last_purchase
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name, c.email
having last_purchase < date_sub(
    (select max(invoice_date) from invoice), interval 6 month
)
order by last_purchase;


-- ========================================
-- Part 4: Sales and Revenue Analysis
-- ========================================

-- Q1: Monthly revenue trends
select
    date_format(invoice_date, '%Y-%m') as month,
    count(invoice_id) as num_invoices,
    round(sum(total), 2) as revenue
from invoice
group by date_format(invoice_date, '%Y-%m')
order by month;

-- Q2: Yearly revenue comparison
select
    year(invoice_date) as year,
    count(invoice_id) as num_invoices,
    round(sum(total), 2) as revenue
from invoice
group by year(invoice_date)
order by year;

-- Q3: Average invoice values
select
    round(avg(total), 2) as avg_invoice,
    round(min(total), 2) as min_invoice,
    round(max(total), 2) as max_invoice
from invoice;

-- Q4: Which sales reps are bringing in the most revenue?
select
    concat(e.first_name, ' ', e.last_name) as sales_rep,
    count(distinct c.customer_id) as num_customers,
    round(sum(i.total), 2) as total_revenue
from employee e
join customer c on e.employee_id = c.support_rep_id
join invoice i on c.customer_id = i.customer_id
group by e.employee_id, e.first_name, e.last_name
order by total_revenue desc;

-- Q5: Best performing countries by revenue
select
    billing_country,
    count(*) as num_invoices,
    round(sum(total), 2) as total_revenue
from invoice
group by billing_country
order by total_revenue desc
limit 10;


-- ========================================
-- Part 5: Product Analysis (Tracks, Artists, Albums)
-- ========================================

-- Q1: Most popular genres by sales
select
    g.name as genre,
    count(il.invoice_line_id) as tracks_sold,
    round(sum(il.unit_price * il.quantity), 2) as revenue
from genre g
join track t on g.genre_id = t.genre_id
join invoice_line il on t.track_id = il.track_id
group by g.genre_id, g.name
order by revenue desc;

-- Q2: Top 10 best-selling artists
select
    ar.name as artist,
    count(il.invoice_line_id) as tracks_sold,
    round(sum(il.unit_price * il.quantity), 2) as revenue
from artist ar
join album al on ar.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join invoice_line il on t.track_id = il.track_id
group by ar.artist_id, ar.name
order by revenue desc
limit 10;

-- Q3: Top albums by revenue
select
    al.title as album,
    ar.name as artist,
    count(il.invoice_line_id) as tracks_sold,
    round(sum(il.unit_price * il.quantity), 2) as revenue
from album al
join artist ar on al.artist_id = ar.artist_id
join track t on al.album_id = t.album_id
join invoice_line il on t.track_id = il.track_id
group by al.album_id, al.title, ar.name
order by revenue desc
limit 10;

-- Q4: Most popular individual tracks
select
    t.name as track,
    ar.name as artist,
    count(il.invoice_line_id) as times_purchased,
    round(sum(il.unit_price * il.quantity), 2) as revenue
from track t
join album al on t.album_id = al.album_id
join artist ar on al.artist_id = ar.artist_id
join invoice_line il on t.track_id = il.track_id
group by t.track_id, t.name, ar.name
order by times_purchased desc
limit 10;

-- Q5: Track length analysis
select
    round(avg(milliseconds) / 60000, 2) as avg_track_length_minutes,
    round(min(milliseconds) / 60000, 2) as shortest_track_minutes,
    round(max(milliseconds) / 60000, 2) as longest_track_minutes
from track;

-- Q6: Price point analysis
select
    unit_price,
    count(*) as num_tracks
from track
group by unit_price
order by unit_price;


-- ========================================
-- Part 6: Media Type Analysis
-- ========================================

-- Q1: Sales by media type
select
    m.name as media_type,
    count(il.invoice_line_id) as items_sold,
    round(sum(il.unit_price * il.quantity), 2) as revenue
from media_type m
join track t on m.media_type_id = t.media_type_id
join invoice_line il on t.track_id = il.track_id
group by m.media_type_id, m.name
order by revenue desc;

-- Q2: Most common media type in library
select
    m.name as media_type,
    count(t.track_id) as num_tracks
from media_type m
join track t on m.media_type_id = t.media_type_id
group by m.media_type_id, m.name
order by num_tracks desc;


-- ========================================
-- Part 7: Employee and Geographic Analysis
-- ========================================

-- Q1: Employee performance comparison
select
    concat(e.first_name, ' ', e.last_name) as employee,
    e.title,
    e.hire_date,
    count(distinct c.customer_id) as customers,
    count(distinct i.invoice_id) as invoices,
    round(sum(i.total), 2) as revenue
from employee e
join customer c on e.employee_id = c.support_rep_id
join invoice i on c.customer_id = i.customer_id
group by e.employee_id, e.first_name, e.last_name, e.title, e.hire_date
order by revenue desc;

-- Q2: Top countries by revenue
select
    c.country,
    count(distinct c.customer_id) as customers,
    count(distinct i.invoice_id) as invoices,
    round(sum(i.total), 2) as revenue
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.country
order by revenue desc
limit 10;

-- Q3: Top cities by revenue
select
    c.city,
    c.country,
    count(distinct c.customer_id) as customers,
    round(sum(i.total), 2) as revenue
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.city, c.country
order by revenue desc
limit 10;


-- ========================================
-- Part 8: Advanced Analysis (Window Functions & CTEs)
-- ========================================

-- Q1: Customer ranking globally and by country
select
    concat(c.first_name, ' ', c.last_name) as customer,
    c.country,
    round(sum(i.total), 2) as total_spent,
    rank() over (order by sum(i.total) desc) as global_rank,
    rank() over (partition by c.country order by sum(i.total) desc) as country_rank
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name, c.country
order by global_rank;

-- Q2: Running total of revenue over time
with monthly_rev as (
    select
        date_format(invoice_date, '%Y-%m') as month,
        round(sum(total), 2) as revenue
    from invoice
    group by date_format(invoice_date, '%Y-%m')
)
select
    month,
    revenue,
    round(sum(revenue) over (
        order by month
        rows between unbounded preceding and current row
    ), 2) as running_total
from monthly_rev
order by month;

-- Q3: Customer segmentation based on spending
with customer_spending as (
    select
        c.customer_id,
        concat(c.first_name, ' ', c.last_name) as customer,
        c.country,
        round(sum(i.total), 2) as total_spent
    from customer c
    join invoice i on c.customer_id = i.customer_id
    group by c.customer_id, c.first_name, c.last_name, c.country
)
select
    customer,
    country,
    total_spent,
    case
        when total_spent >= 45 then 'High Value'
        when total_spent >= 35 then 'Medium Value'
        else 'Low Value'
    end as segment
from customer_spending
order by total_spent desc;

-- Q4: Top artist in each genre
with artist_sales as (
    select
        g.name as genre,
        ar.name as artist,
        round(sum(il.unit_price * il.quantity), 2) as revenue,
        rank() over (
            partition by g.name
            order by sum(il.unit_price * il.quantity) desc
        ) as rank_in_genre
    from genre g
    join track t on g.genre_id = t.genre_id
    join album al on t.album_id = al.album_id
    join artist ar on al.artist_id = ar.artist_id
    join invoice_line il on t.track_id = il.track_id
    group by g.name, ar.artist_id, ar.name
)
select genre, artist, revenue
from artist_sales
where rank_in_genre = 1
order by revenue desc;

-- Q5: Month over month revenue growth
with monthly as (
    select
        date_format(invoice_date, '%Y-%m') as month,
        round(sum(total), 2) as revenue
    from invoice
    group by date_format(invoice_date, '%Y-%m')
)
select
    month,
    revenue,
    lag(revenue) over (order by month) as prev_month,
    round(
        (revenue - lag(revenue) over (order by month))
        / lag(revenue) over (order by month) * 100
    , 2) as growth_percent
from monthly
order by month;

-- Q6: Average days between purchases for each customer
with purchase_dates as (
    select
        customer_id,
        invoice_date,
        lag(invoice_date) over (
            partition by customer_id
            order by invoice_date
        ) as previous_purchase
    from invoice
)
select
    concat(c.first_name, ' ', c.last_name) as customer,
    round(avg(
        datediff(pd.invoice_date, pd.previous_purchase)
    ), 1) as avg_days_between_purchases
from purchase_dates pd
join customer c on pd.customer_id = c.customer_id
where pd.previous_purchase is not null
group by pd.customer_id, c.first_name, c.last_name
order by avg_days_between_purchases;

-- Q7: How diverse are customer music tastes?
-- (counting how many different genres each customer has purchased)
with customer_genres as (
    select
        c.customer_id,
        concat(c.first_name, ' ', c.last_name) as customer,
        count(distinct g.genre_id) as num_genres
    from customer c
    join invoice i on c.customer_id = i.customer_id
    join invoice_line il on i.invoice_id = il.invoice_id
    join track t on il.track_id = t.track_id
    join genre g on t.genre_id = g.genre_id
    group by c.customer_id, c.first_name, c.last_name
)
select
    customer,
    num_genres,
    case
        when num_genres >= 8 then 'Very Diverse'
        when num_genres >= 5 then 'Somewhat Diverse'
        else 'Focused Taste'
    end as listener_type
from customer_genres
order by num_genres desc;

-- Q8: Playlist analysis - which playlists have the most tracks?
select
    p.name as playlist,
    count(pt.track_id) as num_tracks
from playlist p
left join playlist_track pt on p.playlist_id = pt.playlist_id
group by p.playlist_id, p.name
order by num_tracks desc;


-- End of Analysis Project
