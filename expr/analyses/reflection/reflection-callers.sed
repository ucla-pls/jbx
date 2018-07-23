# Extracts reflection caller methods from output of `javap -c -p -s <classes>`
# Requires minimal post processing

# Match class
# TODO: can match keywords (i.e. public, private, protected, etc. more precisely)
/\{$/!b method
s/^.*class[ \t]{1,}([a-zA-Z_$][a-zA-Z0-9_$\.]*)(<.{1,}>)*[ \t]{1,}.*\{$/\1{/
h ; d

# Match method, constructor, or static initializer
:method
/\)([ \t]{1,}throws[ \t]{1,}.{1,}){0,1};$/!b static
s/^[ \t]*//g
/^([a-zA-Z_$][a-zA-Z0-9_$\.]*)\(.*\)([ \t]{1,}throws[ \t]{1,}.{1,}){0,1};$/!b prefix
s/^([a-zA-Z_$][a-zA-Z0-9_$\.]*)\(.*\)([ \t]{1,}throws[ \t]{1,}.{1,}){0,1};$/\1:/ ; b cleanup
:prefix
s/.{1,}[ \t]{1,}([a-zA-Z_$][a-zA-Z0-9_$\.]*)\(.*\)([ \t]{1,}throws[ \t]{1,}.{1,}){0,1};$/\1:/
b cleanup

:static
/static \{\}/!b signature
s/^[ \t]*(static[ \t]{1,}\{\});$/"<clinit>":/
b cleanup

# Match internal type signature
:signature
/Signature:[ \t]{1,}/!b reflection
s/^[ \t]*Signature:[ \t]{1,}// ;
x ; /:/!{x; b cleanup;} ; x
x ; s/(:)\n.{1,}$/\1/g ; x
H ; d

:cleanup
x ; s/(\{)\n.{1,}$/\1/ ; x
H; d

# Match reflection method
:reflection
/java\/lang\/reflect\/((Method\.invoke)|(Constructor\.newInstance))/b done
/java\/lang\/Class\.newInstance/b done

d

:done
g
s/\n//g ; s/^([a-zA-Z_$][a-zA-Z0-9_$\.]*)\{\1/\1{"<init>"/ ; s/\./\//g ; s/\{/./
p
