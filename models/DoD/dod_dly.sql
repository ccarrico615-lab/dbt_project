{{ config( materialized='view', 
            alias = 'dod_dly_stats') }}

with steps as (
    select date, step_tot
    from {{ source('dod_raw', 'dod_steps') }}
),

workouts as (
    select date, sum(session_cnt) as session_cnt, sum(cal_cnt) as cal_cnt, sum(duration_minutes) as duration_minutes, sum(vol_lbs) as vol_lbs
    from {{ source('dod_raw', 'dod_workout') }}
    group by date
),

dates as (
    select date, wk_no, mth_no
    from {{ source('dod_raw', 'dim_date') }}
    where date<=(select max(date) from steps)
)

 SELECT
        dt.date,
        dt.wk_no,
        dt.mth_no,
        coalesce(wo.session_cnt,0) as session_cnt,
        coalesce(wo.cal_cnt,0) as cal_cnt,
        coalesce(wo.duration_minutes,0) as duration_minutes,
        coalesce(wo.vol_lbs,0) as vol_lbs,
        stp.step_tot,
        (coalesce(wo.cal_cnt/300,0) + coalesce(wo.vol_lbs/10000,0) + coalesce(stp.step_tot/10000,0)) as exertion_scr
    FROM
        dates as dt
        LEFT JOIN workouts as wo
            ON dt.date = wo.date
        LEFT JOIN  steps as stp
            ON dt.date = stp.date
