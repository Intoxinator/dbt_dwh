{% macro pmt(rate, nper, pv, type) %}
  if(
    {{ rate }} is null or {{ rate }} = 0,
    round(-{{ pv }} / {{ nper }}, 2),
    if(
      {{ type }} = 0,
      round(-{{ pv }} * {{ rate }} / (1 - power(1 + {{ rate }}, -{{ nper }})), 2),
      round(-{{ pv }} * {{ rate }} / ((1 - power(1 + {{ rate }}, -{{ nper }})) * (1 + {{ rate }})), 2)
    )
  )
{% endmacro %}

{% macro cumipmt(rate, nper, pv, start_period, end_period, type) %}
  if(
    {{ start_period }} < 1 or {{ end_period }} < 1 or {{ start_period }} > {{ end_period }} or {{ end_period }} > {{ nper }} or {{ nper }} <= 0,
    null,
    if(
      {{ rate }} = 0,
      null,
      if(
        {{ start_period }} = 1 and {{ end_period }} = {{ nper }},
        -- Total interest over entire loan period
        round({{ nper }} * {{ pmt(rate, nper, pv, type) }} + {{ pv }}, 2),
        -- Standard Excel CUMIPMT formula
        round(
          if(
            {{ type }} = 0,
            -- End of period payments
            {{ pmt(rate, nper, pv, type) }} * (1 - power(1 + {{ rate }}, {{ start_period }} - 1 - {{ nper }})) / {{ rate }} -
            {{ pmt(rate, nper, pv, type) }} * (1 - power(1 + {{ rate }}, {{ end_period }} - {{ nper }})) / {{ rate }},
            -- Beginning of period payments
            ({{ pmt(rate, nper, pv, type) }} * (1 - power(1 + {{ rate }}, {{ start_period }} - 1 - {{ nper }})) / {{ rate }} -
             {{ pmt(rate, nper, pv, type) }} * (1 - power(1 + {{ rate }}, {{ end_period }} - {{ nper }})) / {{ rate }}) / (1 + {{ rate }})
          ), 2
        )
      )
    )
  )
{% endmacro %}

{% macro cumprinc(rate, nper, pv, start_period, end_period, type) %}
  if(
    {{ start_period }} < 1 or {{ end_period }} < 1 or {{ start_period }} > {{ end_period }} or {{ end_period }} > {{ nper }} or {{ nper }} <= 0,
    null,
    if(
      {{ rate }} = 0,
      round(-1 * ({{ end_period }} - {{ start_period }} + 1) * ({{ pv }} / {{ nper }}), 2),
      round(
        ({{ end_period }} - {{ start_period }} + 1) * {{ pmt(rate, nper, pv, type) }} - 
        {{ cumipmt(rate, nper, pv, start_period, end_period, type) }}, 2
      )
    )
  )
{% endmacro %}