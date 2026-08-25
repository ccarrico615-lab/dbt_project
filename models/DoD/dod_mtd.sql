{{ config( materialized='view', 
            alias = 'dod_mtd_progress') }}

with steps as (
    select date, step_tot
    from {{ source('dod_raw', 'dod_steps') }}
),

workouts as (
    select date, sum(session_cnt) as session_cnt, sum(duration_minutes) as duration_minutes, sum(vol_lbs) as vol_lbs
    from {{ source('dod_raw', 'dod_workout') }}
    group by date
),

dates as (
    select date, wk_no, mth_no
    from {{ source('dod_raw', 'dim_date') }}
    where date<=(select max(date) from steps)
)

SELECT  date, mth_no, mtd_session_cnt, mtd_vol_lbs, mtd_step_tot, curr_rcrd_ind
FROM
(
    SELECT
        dt.date,
        dt.mth_no,
        sum(wo.session_cnt) over(partition by dt.mth_no order by dt.date) as mtd_session_cnt,
        sum(wo.vol_lbs) over(partition by dt.mth_no order by dt.date) as mtd_vol_lbs,
        sum(stp.step_tot) over(partition by dt.mth_no order by dt.date) as mtd_step_tot,
        case
            when dt.mth_no = lead(dt.mth_no,1) over(order by dt.date) then 0
            else 1
        end as eom_ind,
        case
            when dt.date = max(dt.date) over()  then 1 
            else 0 
        end as curr_rcrd_ind
    FROM
        dates as dt
        LEFT JOIN workouts as wo
            ON dt.date = wo.date
        LEFT JOIN  steps as stp
            ON dt.date = stp.date
)
WHERE
    eom_ind = 1