use mavenfuzzyfactory;
select *from website_sessions;
select count(*) from website_sessions;

select ws.utm_content,
	   count(distinct(ws.website_session_id)) as sessions,
       count(distinct(o.order_id)) as orders,
       count(distinct(o.order_id))/count(distinct(ws.website_session_id)) as session_to_order_conv_rt
from website_sessions ws 
left join orders o on o.website_session_id = ws.website_session_id
where ws.website_session_id between 1000 and 2000
group by ws.utm_content
order by sessions desc;


-- (Site traffic breakdown) utm_source , utm_campaign , http_referer leads to   how many website sessions   
select utm_source ,utm_campaign,http_referer,
		count(distinct(website_session_id)) as sessions
from website_sessions 
where created_at < '2012-04-12'
group by 1,2,3
order by sessions desc;

-- Traffic source conversion rates ( how much perctange of website sessions having utm source as gsearch
-- and utm campaign as nonbrand leads to orders)
select count(distinct(ws.website_session_id)) as sessions,
	   count(distinct(o.order_id)) as orders,
       count(distinct(o.order_id))/count(distinct(ws.website_session_id)) as session_to_order_conv_rate
from website_sessions ws
left join orders o
on o.website_session_id = ws.website_session_id 
where ws.utm_source = "gsearch" and ws.utm_campaign = "nonbrand" and ws.created_at < '2012-04-14';

-- Date functions(trend analysis)
select year(created_at),
	   week(created_at),
       min(date(created_at)) as week_start,
       count(distinct website_session_id) as sessions
from website_sessions 
where website_session_id between 100000 and 115000 -- arbitrary
group by 1,2;

       
-- pivoting
select primary_product_id,
       count(case when items_purchased = 1 then order_id else null end ) as count_single_item_order,
       count(case when items_purchased = 2 then order_id else null end ) as count_two_item_order
from orders
where order_id between 31000 and 32000 -- arbitrary
group by 1 
order by primary_product_id;

-- Traffic source trending

select min(date(created_at)) as start_of_week ,
count(distinct(website_session_id)) as sessions
from website_sessions
where created_at  < '2012-05-10' and utm_source="gsearch" and utm_campaign="nonbrand"
group by yearweek(created_at);

-- Bid optimization for paid traffic

select ws.device_type,
	   count(distinct ws.website_session_id) as sessions,
	   count(distinct o.order_id) as orders,
       count(distinct o.order_id)/count(distinct ws.website_session_id) as session_to_order_conv_rt
from website_sessions ws
left join orders o
on o.website_session_id = ws.website_session_id
where ws.utm_source = "gsearch" and ws.utm_campaign = "nonbrand" and ws.created_at < '2012-05-11'
group by 1;

-- Gsearch device level trends

select min(date(created_at)) as start_of_week,
	   count(case when device_type="desktop" then 1 else null end) as desktop_sessions,
       count(case when device_type="mobile" then 1 else null end) as mobile_sessions
from website_sessions
where utm_source = "gsearch" and utm_campaign="nonbrand" and created_at between "2012-04-15" and "2012-06-09"
group by yearweek(created_at) ;

 






















