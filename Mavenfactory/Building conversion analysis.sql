use mavenfuzzyfactory;

-- Demo on building funnels
-- Business context
	-- we want to build a mini conversion funnel,from /lander2 to /cart
	-- we want to know how many people reach step and drop off rate
	-- for simplicity we are looking at /lander-2 traffic only
	-- for simplicity demo we are looking at Mr fuzzy only
-- step 1 : select all pageviews for relevant session
-- step 2 : identify each relevant pageview as the specific funnel step
-- step 3 : create session level conversion funnel
-- step 4 : aggregate the data to assess funnel performance

select 
		ws.website_session_id ,
        wp.pageview_url,
        wp.created_at,
        case when wp.pageview_url = '/products' then 1 else 0 end as products_page,
        case when wp.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
        case when wp.pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions ws
left join website_pageviews wp on
wp.website_session_id = ws.website_session_id
where wp.created_at between '2014-01-01' and '2014-02-01'
and wp.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by ws.website_session_id,wp.created_at ;
drop table session_level_made_it_flags_demo;
create temporary table session_level_made_it_flags_demo
select website_session_id ,
	   max(products_page) as product_made_it,
       max(mrfuzzy_page) as mrfuzzy_made_it,
       max(cart_page) as cartpage_made_it
from
(
select 
		ws.website_session_id ,
        wp.pageview_url,
        wp.created_at,
        case when wp.pageview_url = '/products' then 1 else 0 end as products_page,
        case when wp.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
        case when wp.pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions ws
left join website_pageviews wp on
wp.website_session_id = ws.website_session_id
where wp.created_at between '2014-01-01' and '2014-02-01'
and wp.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by ws.website_session_id,wp.created_at 
) as pageview_level
group by website_session_id;

select * from session_level_made_it_flags_demo;

select count(distinct website_session_id),
	   count(distinct case when product_made_it= 1 then website_session_id else null end)
       /count(distinct website_session_id) as click_to_products,
       count(distinct case when mrfuzzy_made_it= 1 then website_session_id else null end)
       /count(distinct case when product_made_it= 1 then website_session_id else null end) as click_to_mrfuzzy,
       count(distinct case when cartpage_made_it = 1 then website_session_id else null end)
       /count(distinct case when mrfuzzy_made_it= 1 then website_session_id else null end) as click_to_carts
from session_level_made_it_flags_demo;

--  Building conversion funnels
-- step 1 : select all pageviews for each session
-- step 2 : identify each sessions as the specific funnel session
-- step 3 : create session level conversion funnel view
-- step 4 : aggregate the date to assess funnel performance 

select 
		ws.website_session_id ,
        wp.pageview_url,
        case when wp.pageview_url = '/products' then 1 else 0 end as products_page,
        case when wp.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
        case when wp.pageview_url = '/cart' then 1 else 0 end as cart_page,
        case when wp.pageview_url = '/billing' then 1 else 0 end as billing_page,
        case when wp.pageview_url = '/thank-you-for-order' then 1 else 0 end as thankyou_page
from website_sessions ws
left join website_pageviews wp on
wp.website_session_id = ws.website_session_id
where wp.created_at between '2012-08-05' and '2014-09-05'
and ws.utm_source='gsearch'
and ws.utm_campaign='nonbrand'
order by ws.website_session_id,wp.created_at;

drop table session_level_made_it;
create temporary table session_level_made_it
select website_session_id,
	   max(products_page) as product_made_it,
       max(mrfuzzy_page) as mrfuzzy_made_it,
       max(cart_page) as cartpage_made_it,
       max(billing_page) as billingpage_made_it,
       max(thankyou_page) as thankyou_made_it
from (
select 
		ws.website_session_id ,
        wp.pageview_url,
        case when wp.pageview_url = '/products' then 1 else 0 end as products_page,
        case when wp.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
        case when wp.pageview_url = '/cart' then 1 else 0 end as cart_page,
        case when wp.pageview_url = '/billing' then 1 else 0 end as billing_page,
        case when wp.pageview_url = '/thank-you-for-order' then 1 else 0 end as thankyou_page
from website_sessions ws
left join website_pageviews wp on
wp.website_session_id = ws.website_session_id
where wp.created_at between '2012-08-05' and '2012-09-05'
and ws.utm_source='gsearch'
and ws.utm_campaign='nonbrand'
order by ws.website_session_id,wp.created_at
) as pageview_level
group by website_session_id;


select count(distinct website_session_id),
	   count(distinct case when product_made_it= 1 then website_session_id else null end)
       /count(distinct website_session_id) as click_to_products,
       count(distinct case when mrfuzzy_made_it= 1 then website_session_id else null end)
       /count(distinct case when product_made_it= 1 then website_session_id else null end) as click_to_mrfuzzy,
       count(distinct case when cartpage_made_it = 1 then website_session_id else null end)
       /count(distinct case when mrfuzzy_made_it= 1 then website_session_id else null end) as click_to_carts,
       count(distinct case when billingpage_made_it = 1 then website_session_id else null end)
       /count(distinct case when cartpage_made_it = 1 then website_session_id else null end) as shipping_click_rate,
       count(distinct case when thankyou_made_it = 1 then website_session_id else null end)
       /count(distinct case when billingpage_made_it = 1 then website_session_id else null end) as billing_click_rate
from session_level_made_it;















