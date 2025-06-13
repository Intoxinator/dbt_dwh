{% macro pmt(rate, nper, pv, type) %}
  {{ log("pmt called with rate=" ~ rate ~ ", nper=" ~ nper ~ ", pv=" ~ pv ~ ", type=" ~ type, info=true) }}
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
  {{ log("cumipmt called", info=true) }}
  if(
    {{ start_period }} < 1 or {{ end_period }} < 1 or {{ start_period }} > {{ end_period }} or {{ end_period }} > {{ nper }} or {{ nper }} <= 0,
    null,
    if(
      {{ rate }} is null or {{ rate }} = 0,
      0,
      if(
        {{ start_period }} = 1 and {{ end_period }} = {{ nper }},
        round({{ nper }} * {{ pmt(rate, nper, pv, type) }} - {{ pv }}, 2),
        if(
          {{ start_period }} = {{ end_period }},
          round(
            if(
              {{ rate }} is null or {{ rate }} = 0,
              0,
              if(
                {{ type }} = 0,
                {{ pv }} * {{ rate }} * power(1 + {{ rate }}, {{ start_period }} - 1) / (1 - power(1 + {{ rate }}, -{{ nper }})),
                {{ pv }} * {{ rate }} * power(1 + {{ rate }}, {{ start_period }} - 1) / ((1 - power(1 + {{ rate }}, -{{ nper }})) * (1 + {{ rate }}))
              )
            ), 2
          ),
          round(
            -1 * (
              ({{ end_period }} - {{ start_period }} + 1) *
              if(
                {{ rate }} = 0,
                {{ pv }} / {{ nper }},
                if(
                  {{ type }} = 0,
                  {{ pv }} * {{ rate }} / (1 - power(1 + {{ rate }}, -{{ nper }})),
                  {{ pv }} * {{ rate }} / ((1 - power(1 + {{ rate }}, -{{ nper }})) * (1 + {{ rate }}))
                )
              )
            ),
            2
          )
        )
      )
    )
  )
{% endmacro %}

{% macro cumprinc(rate, nper, pv, start_period, end_period, type) %}
  {{ log("cumprinc called", info=true) }}
  if(
    {{ start_period }} < 1 or {{ end_period }} < 1 or {{ start_period }} > {{ end_period }} or {{ end_period }} > {{ nper }} or {{ nper }} <= 0,
    null,
    if(
      {{ rate }} is null or {{ rate }} = 0,
      round(-1 * ({{ end_period }} - {{ start_period }} + 1) * ({{ pv }} / {{ nper }}), 2),
      if(
        {{ start_period }} = 1 and {{ end_period }} = {{ nper }},
        round(-{{ pv }}, 2),
        if(
          {{ start_period }} = {{ end_period }},
          round(
            {{ pmt(rate, nper, pv, type) }} -
            if(
              {{ rate }} is null or {{ rate }} = 0,
              0,
              if(
                {{ type }} = 0,
                {{ pv }} * {{ rate }} * power(1 + {{ rate }}, {{ start_period }} - 1) / (1 - power(1 + {{ rate }}, -{{ nper }})),
                {{ pv }} * {{ rate }} * power(1 + {{ rate }}, {{ start_period }} - 1) / ((1 - power(1 + {{ rate }}, -{{ nper }})) * (1 + {{ rate }}))
              )
            ),
            2
          ),
          round(
            -1 * (
              {{ pv }} * (power(1 + {{ rate }}, {{ start_period }} - 1) - power(1 + {{ rate }}, {{ end_period }})) /
              power(1 + {{ rate }}, {{ start_period }} - 1)
            ),
            2
          )
        )
      )
    )
  )
{% endmacro %}