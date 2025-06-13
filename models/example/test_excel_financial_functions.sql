with
    params as (
        select
            rate,
            nper,
            pv,
            start_period,
            end_period,
            type
        from {{ ref("seed_test_excel_financial_functions") }}
    ),

    calculated as (
        select
            rate,
            nper,
            pv,
            type,
            {{ pmt("rate", "nper", "pv", "type") }} as pmt,
            {{ cumipmt(
                "rate",
                "nper",
                "pv",
                "start_period",
                "end_period",
                "type"
            ) }} as cumipmt,
            {{ cumprinc(
                "rate",
                "nper",
                "pv",
                "start_period",
                "end_period",
                "type"
            ) }} as cumprinc
        from params
    )

select
    rate,
    nper,
    pv,
    type,
    pmt,
    cumipmt,
    cumprinc
from calculated
