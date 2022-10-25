use mavenfuzzyfactory;
desc website_pageviews;

select * from website_pageviews 
where  website_pageview_id < 1000; -- arbitrary


-- Analying top view pages
select pageview_url,
	   count(distinct website_pageview_id) as pvs
from website_pageviews
where website_pageview_id <1000 -- arbitrary
group by pageview_url
order by pvs desc;

create temporary table first_pageview
select website_session_id,min(website_pageview_id ) as min_pv_id
from website_pageviews where website_pageview_id < 1000 -- arbitrary
group by website_session_id;

select *from first_pageview;

select wp.pageview_url,
	   count(distinct fp.website_session_id) as landing_page -- aka entry page
from first_pageview fp
left join website_pageviews wp
on       fp.min_pv_id = wp.website_pageview_id
group by 1;

-- Finding top website pages
/*
select pageview_url,
	   count(distinct website_pageview_id) as sessions
from website_pageviews
where created_at < '2012-06-09'
group by pageview_url
order by sessions desc;
       
*/

select pageview_url,
	   count(distinct website_pageview_id) as sessions
from website_pageviews
where created_at < '2012-06-09'
group by pageview_url
order by sessions desc;



select pageview_url,
	   count(distinct website_pageview_id) as sessions
from website_pageviews
where created_at < '2012-06-09'
group by pageview_url
order by sessions desc ;


-- setp1 : find the first page view for each session
-- step2 : find the url the customer saw on the first pageview
create temporary table firstpageview
select website_session_id ,
	   min(website_pageview_id) as min_pageview
from website_pageviews 
where created_at < "2012-06-12"
group by 1;

select * from firstpageview;

select wp.pageview_url ,
	   count(distinct fp.website_session_id) as sessions
from firstpageview fp
left join website_pageviews wp
on wp.website_pageview_id = fp.min_pageview
where created_at<"2012-06-12"
group by 1
order by sessions desc limit 3;

-- Buiness context : we want to see the landing page performance for certain period
-- step 1 : find out first website pageview id for relevant session
-- step 2 : finding landing page for each  session
-- step 3 : counting pageviews for each session , to identify "bounces"
-- step 4 : summarizing total sessions and bounced sessions , LP

-- finding minimum pageview_id for website_session_ id

select wp.website_session_id ,
	   min(wp.website_pageview_id) as min_pageview_id
from website_pageviews wp
inner join website_sessions ws 
on ws.website_session_id = wp.website_session_id 
and ws.created_at between '2014-01-01' and '2014-02-01'
group by wp.website_session_id;

-- create temporary table first_page_views_demo
create temporary table first_pageviews_demo
select wp.website_session_id ,
	   min(wp.website_pageview_id) as min_pageview_id
from website_pageviews wp
inner join website_sessions ws 
on ws.website_session_id = wp.website_session_id 
and ws.created_at between '2014-01-01' and '2014-02-01'
group by wp.website_session_id;

select *from first_pageviews_demo limit 3;

-- get landing page for each session
create temporary table sessions_w_landing_page
select fpd.website_session_id,
       wp.pageview_url as landing_page
from first_pageviews_demo fpd
left join website_pageviews wp
on wp.website_pageview_id = fpd.min_pageview_id ;-- website pageview is the landing page;

select  *from sessions_w_landing_page;

--  make a table  to include  a count of page views per session
create temporary table bounced_sessions_only
select swlp.website_session_id,
	   swlp.landing_page,
       count(wp.website_pageview_id) as count_of_pages_viewed
from sessions_w_landing_page swlp
left join website_pageviews wp
on wp.website_session_id = swlp.website_session_id
group by 1,2
having count(wp.website_pageview_id) = 1;

select swlp.landing_page,
	   swlp.website_session_id,
       bso.website_session_id as bounced_website_session_id
from sessions_w_landing_page swlp
left join bounced_sessions_only bso
on bso.website_session_id = swlp.website_session_id
order by swlp.website_session_id;

select swlp.landing_page,
	   count(distinct swlp.website_session_id) as sessions,
       count(distinct bso.website_session_id) as bounced_sessions,
       count(distinct bso.website_session_id)/count(distinct swlp.website_session_id) as bounce_rate
from sessions_w_landing_page swlp
left join bounced_sessions_only bso
on bso.website_session_id = swlp.website_session_id
group by 1;

-- Calculating Bounce rates
-- step 1 : finding the first website_pageview_id for each session
-- step 2 : identifying the landing page of each session
-- step 3 : count of pageviews for each each session , to identify bounce sessions
-- step 4 : summarizing by counting total sessions and bounced sessions


create temporary table first_pageviews
select website_session_id , min(website_pageview_id) as min_pageview_id
from website_pageviews
where created_at< '2012-06-04'
group by website_session_id;

select * from first_pageviews ;

create temporary table sessions_hm_landing_page
select fp.website_session_id,wp.pageview_url as landing_page
from first_pageviews fp left join website_pageviews wp on
wp.website_pageview_id = fp.min_pageview_id
where wp.pageview_url = "/home";

select *from sessions_hm_landing_page;

create temporary table bounced_sessions
select shlp.website_session_id,
	   shlp.landing_page,
       count(wp.website_pageview_id) as coun_of_pages_viewed
from sessions_hm_landing_page shlp left join website_pageviews wp on
wp.website_session_id = shlp.website_session_id
group by 1,2
having count(wp.website_pageview_id) = 1;

select *from bounced_sessions;


select count(distinct shlm.website_session_id) as sessions,
	   count(distinct bs.website_session_id) as bounced_sessions,
       count(distinct bs.website_session_id)/count(distinct shlm.website_session_id) as bounce_rate
from sessions_hm_landing_page shlm left join
bounced_sessions bs on bs.website_session_id = shlm.website_session_id;

-- step 2 : find out when the new page/lander launched
-- step 1 : finding the first website_pageview_id for each session
-- step 2 : identifying the landing page of each session
-- step 3 : count of pageviews for each each session , to identify bounce sessions
-- step 4 : summarizing by counting total sessions and bounced sessions by "LP"

select min(created_at) as first_created_at,min(website_pageview_id) as first_pageview_id
from website_pageviews  where pageview_url = "/lander-1"
	and created_at is not null;

drop table  if exists first_page_views ;
create temporary table first_page_views
select wp.website_session_id,min(wp.website_pageview_id) as min_pageview_id
from website_pageviews wp
inner join website_sessions ws on
ws.website_session_id = wp.website_session_id
and ws.created_at < '2012-07-28'
and wp.website_pageview_id > 23504
and ws.utm_source = 'gsearch'
and ws.utm_campaign = 'nonbrand'
group by wp.website_session_id;

select * from first_page_views;

create temporary table non_branded_test_session_landingpage
select fpv.website_session_id , wp.pageview_url as landing_page
from first_page_views fpv left join website_pageviews wp
on wp.website_session_id = fpv.website_session_id
where wp.pageview_url in ('/home','/lander-1');

create temporary table nonbrand_test_bounced_sessions
select ntsl.website_session_id,
	   ntsl.landing_page,
       count(wp.website_pageview_id) as count_of_pages_viewed
from non_branded_test_session_landingpage ntsl left join website_pageviews wp on
wp.website_session_id = ntsl.website_session_id
group by 1,2
having count(wp.website_pageview_id) = 1;

select * from nonbrand_test_bounced_sessions;

select ntsl.landing_page ,
	   count(distinct ntsl.website_session_id) as sessions,
	   count(distinct ntbs.website_session_id) as bounced_sessions,
       count(distinct ntbs.website_session_id)/count(distinct ntsl.website_session_id) as bounce_rate
from non_branded_test_session_landingpage ntsl left join
nonbrand_test_bounced_sessions ntbs on ntbs.website_session_id = ntsl.website_session_id
group by ntsl.landing_page;


-- Landing page trend analysis







