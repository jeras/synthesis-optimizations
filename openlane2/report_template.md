# Report

|{% for parameter in             parameters %} {{ parameter }} |{% endfor %}    hierarchy    |    techmap    |
|{% for parameter in             parameters %}-----------------|{% endfor %}-----------------|---------------|
{%- for combination in combinations %}
|{% for parameter in combination.parameters %} {{ parameter }} |{% endfor %} {{ hierarchy }} | {{ techmap }} |
{%- endfor %}
