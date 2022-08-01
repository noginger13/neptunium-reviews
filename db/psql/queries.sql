-- REVIEWS
select r.id as review_id, r.rating, r.summary, r.recommend, r.response, r.body, r.date, r.reviewer_name, r.helpfulness, coalesce(rp.photos, '[]') as photos
from reviews r
left join lateral (
	select json_agg(json_build_object( 'id', rp.id, 'url', rp.url)) as photos
	from reviews_photos rp
	where rp.review_id = r.id
	) rp on true
where r.product_id = 12 and reported = false
order by r.helpfulness desc, r.date desc
offset 0 limit 15;

--METADATA
select json_build_object(
	'product_id',
	'12',
	'ratings',
	(
		select json_object_agg(rv.rating, rv.count)
		from (select r.rating, count(*)
			  from reviews r
			  where r.product_id=12
			  group by r.rating) as rv
	),
	'recommended',
	(
		select json_build_object('0',
								 (select count(*)
								  from reviews r
								  where r.product_id=12 and r.recommend=false),
								 '1',
								 (select count(*)
								  from reviews r
								  where r.product_id=12 and r.recommend=true)
								)
	),
	'characteristics',
	(select json_object_agg(cv.name, cv.vals) as obj
											 from (select c.name, json_build_object('id', c.id, 'value', avg(ctr.value)) as vals
												   from characteristics c
												   join (
													   select *
													   from reviews r
													   join characteristic_reviews cr
													   on cr.review_id = r.id
												   ) as ctr
												   on c.id = ctr.characteristic_id
												   where c.product_id=12
												   group by c.name, c.id
												  ) as cv)

) as metadata;

--REVIEW POST
--REVIEWS

--Date
(select (round(extract(epoch from now()) * 1000)) as date)
--REVIEWS PHOTOS

--REVIEWS CHAR


--HELPFULNESS
update reviews
set helpfulness = helpfulness + 1
where id = 12;

--REPORT
update reviews
set helpfulness = true
where id = 12;