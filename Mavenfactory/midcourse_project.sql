use mavenfuzzyfactory;

-- 1) Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions 
-- and orders so that we can showcase the growth there? 1
select year(ws.created_at) as yr,
	   month(ws.created_at) as mo,
       count(distinct ws.website_session_id) as sessions,
       count(distinct o.order_id) as orders,
       count(distinct o.order_id)/count(distinct ws.website_session_id) as conv_rate
from website_sessions ws
left join orders o
on o.website_session_id=ws.website_session_id
where ws.created_at < '2012-11-27'
and ws.utm_source = 'gsearch'
group by 1,2;

-- 2) Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and 
-- brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell. 2
select year(ws.created_at) as yr,
	   month(ws.created_at) as mo,
       count(distinct ws.website_session_id) as sessions,
       ws.utm_campaign,
       count(distinct o.order_id) as orders
from website_sessions ws
left join orders o
on o.website_session_id=ws.website_session_id
where ws.created_at < '2012-11-27'
and ws.utm_source = 'gsearch'
and ws.utm_campaign in ('brand','nonbrand')
group by 1,2,utm_content;

-- 3) While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device 3 type? 
-- I want to flex our analytical muscles a little and show the board we really know our traffic sources. 
select year(ws.created_at) as yr,
	   month(ws.created_at) as mo,
       count(distinct case when device_type = "desktop" then ws.website_session_id else null end) as desktop_sessions,
       count(distinct case when device_type = "desktop" then o.order_id else null end) as desktop_orders,
       count(distinct case when device_type = "mobile" then ws.website_session_id else null end) as mobile_sessions,
       count(distinct case when device_type = "mobile" then o.order_id else null end) as mobile_orders
from website_sessions ws
left join orders o
on o.website_session_id=ws.website_session_id
where ws.created_at < '2012-11-27'
and ws.utm_source = 'gsearch'
and ws.utm_campaign in ('nonbrand')
group by 1,2,utm_content;

-- 4)I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from 4 Gsearch. 
 -- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?

select distinct utm_source,  utm_campaign, http_referer
from website_sessions;