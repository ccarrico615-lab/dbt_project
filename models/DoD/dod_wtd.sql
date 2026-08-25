{{ config( materialized='view', 
            alias = 'dod_wtd_progress') }}
            
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
    select date, wk_no, mth_no, min(date) over(partition by wk_no) as wk_st, max(date) over(partition by wk_no) as wk_end
    from {{ source('dod_raw', 'dim_date') }}
    where date<=(select max(date) from steps)
)

SELECT  date, wk_no, wk_st, wk_end, wtd_session_cnt, wtd_duration_minutes, wtd_vol_lbs, wtd_step_tot, curr_rcrd_ind
FROM
(
    SELECT
        dt.date,
        dt.wk_no,
        dt.wk_st,
        dt.wk_end,
        sum(wo.session_cnt) over(partition by dt.wk_no order by dt.date) as wtd_session_cnt,
        sum(wo.duration_minutes) over(partition by dt.wk_no order by dt.date) as wtd_duration_minutes,
        sum(wo.vol_lbs) over(partition by dt.wk_no order by dt.date) as wtd_vol_lbs,
        sum(stp.step_tot) over(partition by dt.wk_no order by dt.date) as wtd_step_tot,
        case when
            dt.wk_no = lead(dt.wk_no,1) over(order by dt.date) then 0
            else 1
        end as eow_ind,
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
WHERE eow_ind = 1