import sqlparse
import sys
import re

contents = sys.stdin.read();

interpolations = re.findall(r"\$\{[^}]*\}",contents)

new_interpolations=[]

for old in interpolations:
    new_interpolations.append('__id_'+f'"{old}"')

new_contents=contents
for (to_be_replaced_str,new_interpolation) in zip(interpolations,new_interpolations):
    new_contents=new_contents.replace(to_be_replaced_str,new_interpolation);

result = sqlparse.format(new_contents, indent_columns=True
                         , keyword_case='lower'
                         , identifier_case='lower' 
                         , reindent=True
                         , reindent_aligned=True
                         , use_space_around_operators=True
                         , output_format='sql'
                         , indent_after_first=True
                         , wrap_after=80
                         , comma_first=False
                         )
with open('/tmp/tmp.txt','w') as f:
    f.write(contents)
    f.write("\n"+result)

for (to_be_replaced_str,interpolation) in zip(new_interpolations,interpolations):
    result=result.replace(to_be_replaced_str,interpolation);

print(result.strip())
