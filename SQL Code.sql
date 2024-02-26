# https://www.kaggle.com/datasets/jmmvutu/ecommerce-users-of-a-french-c2c-fashion-store?select=countries_with_top_sellers_fashion_c2c.csv
# nb sellers
# 1 number of sellers from each country
select country, count(*) as total_sellers
from sellers_gender_country
group by country
order by total_sellers;
# there are atmost two sellers from each country

# 2 number of sellers from each country by gender
select country, sex, count(*) total_count
from sellers_gender_country
group by country, sex
order by total_count desc;

# 3 Countries only with female sellers
select country, sex, nbsellers
from sellers_gender_country
where sex='female' and
country not in (
	select country from sellers_gender_country where sex='male'
);

# 4 Countries with only male sellers
select country, sex, nbsellers
from sellers_gender_country
where sex='male' and
country not in (
	select country from sellers_gender_country where sex='female'
);

# 5 Total female, male sellers
select *
from sellers_gender_country
where country = '';

select sex, sum(nbsellers)
from sellers_gender_country
where country not in (select country from sellers_gender_country where country='')
group by sex;
# after doing the above I found that three rows with mean values for male, female sellers and overall sellers is also given.
# We wish to delete them for further analysis
delete from sellers_gender_country
where country = '';
# now the total rows are 70. we shall check that again
select count(*)
from sellers_gender_country;

# NOW FINALLY, THE TOTAL NUMBER OF MALE AND FEMALE SELLERS
select sex, sum(nbsellers) as total_count
from sellers_gender_country
group by sex;

# Are these same as the total users registered with the website?
select count(distinct identifierHash)
from users_data;

# USING OTHER COLUMNS OF SELLERS_GENDER_COUNTRY
# overall mean products sold
select round(avg(nbsellers*meanproductssold),2) as overall_avg
from sellers_gender_country;

################################### DATE: 23 Feb 2024 #######################################

# mean products sold based on gender
select sex, round(avg(nbsellers*meanproductssold),2) as overall_avg
from sellers_gender_country
group by sex;
# -> the females have higher sales compared to the males

# mean products sold by country
select country, round(avg(nbsellers*meanproductssold),2) as overall_avg
from sellers_gender_country
group by country
order by overall_avg desc;
	# Here it seems that there are some countries having 0 mean products sold
    
# total products sold by country
select country, sum(totalproductssold) as total_sold
from sellers_gender_country
group by country
order by total_sold desc;
# Here too there are some countries that have 0 total products sold

# countries with zero mean products sold
select country, round(avg(nbsellers*meanproductssold),2) as overall_avg_sale
from sellers_gender_country
group by country
having overall_avg_sale=0
order by country;

select country, sum(totalproductssold) as total_sale
from sellers_gender_country
group by country
having total_sale=0
order by country;

# the number of sellers from these countries
# Country, gender, total_sale
with t1 as (
select country, sum(totalproductssold) as total_sale
from sellers_gender_country
group by country
having total_sale=0
order by country)

select sgc.country, sgc.sex, round(avg(t1.total_sale),0) as total_sale
from sellers_gender_country sgc
inner join t1
on sgc.country = t1.country
group by country, sex;
# All these sellers are female

# Creating an index for sellers_gender_country
alter table sellers_gender_country add column index_no int;
select * from sellers_gender_country;
select * from users_data;
UPDATE sellers_gender_country
JOIN users_data ON sellers_gender_country.country = users_data.country
SET sellers_gender_country.index_no = users_data.identifierHash/10000000000;

update sellers_gender_country
set index_no=0
where index_no is null
##########################################24 Feb 2024#################################################
# Top 5 selling countries
select country, round(num/total_sellers, 2) as mean
from (
	select country, sum(meanproductssold*nbsellers) as num, sum(nbsellers) as total_sellers
    from sellers_gender_country
    group by country
) table2
order by mean desc
limit 5;

# total products listed by the sellers
select country, sum(totalproductslisted) as total_products
from sellers_gender_country
group by country
order by total_products;
# top 5 countries in that are 
# Italy, France, Royaume-Uni, Etats-Unis, Espagne
# And Kazakhstan, Bahamas, Slovenia have no produts listed

# Checking whether there is any relation between total_products_listed and total_products_sold
select country, rank() over(order by total_sale desc) as sale_rank, rank() over(order by total_listed desc) as list_rank
from (select country, sum(totalproductssold) as total_sale, sum(totalproductslisted) as total_listed
from sellers_gender_country
group by country) t2
order by 3;
# There seems to be a positive correlation between the total_products_listed and total_products_sold

select country, meanfollowing, meanfollowers
from top_selling_countries
order by meanfollowing desc;

select country, rank() over(order by meanfollowing desc) as following_rank, rank() over (order by meanfollowers desc) as followers_rank
from top_selling_countries
order by 2;
# Here there seems to be not much correlation.

# users based on country
select distinct countryCode, country
from users_data
where country = 'Qatar';	

# total socialNbfollowers
select country, total_followers
from (
	select country, sum(socialNbFollowers) as total_followers, count(*) as nb_followers
    from users_data
    group by country
) users_data1
order by total_followers desc;

select gender, sum(socialNbFollowers) as total_followers
from users_data
group by gender
