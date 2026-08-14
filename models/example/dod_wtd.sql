
with dates as (
    select date, wk_no, mth_no
    from {{ source('dod_raw', 'dim_date') }}
),

workouts as (
    select date, sum(session_cnt) as session_cnt, sum(duration_minutes) as duration_minutes, sum(vol_lbs) as vol_lbs
    from {{ source('dod_raw', 'dod_workout') }}
    group by date
),

steps as (
    select date, step_tot
    from {{ source('dod_raw', 'dod_steps') }}
)

SELECT  date, wk_no, eow_ind,
        wtd_session_cnt, wtd_duration_minutes
FROM
(
    SELECT
        dt.date,
        dt.wk_no,
        sum(wo.session_cnt) over(partition by dt.wk_no order by dt.date) as wtd_session_cnt,
        sum(wo.duration_minutes) over(partition by dt.wk_no order by dt.date) as wtd_duration_minutes,
        case when
            dt.wk_no = lead(dt.wk_no,1) over(order by dt.date) then 0
            else 1
        end as eow_ind
    FROM
        dates as dt
        LEFT JOIN workouts as wo
            ON dt.date = wo.date
        LEFT JOIN  steps as stp
            ON dt.date = stp.date
)