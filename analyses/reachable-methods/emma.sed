/COVERAGE SUMMARY FOR PACKAGE/ {
    s/.*\[\([^]]\+\)\].*/\1\n/
    h
}

# the hold contains <package>\n<class>
/class / {
    s/.*\[\([^]]\+\)\].*/\1/
    G
    s/\(.*\)\n\(.*\)\n\(.*\)/\2\n\2.\1/
    h
}

# Methods visited
/):[^!]*$/ { 
    s/\([a-zA-Z0-9_$]\+\) \(([^)]*)\): \([a-zA-Z0-9_$]\+\).*/\3 \1\2/
    G 
    s/\(.*\)\n.*\n\(.*\)/<\2: \1>/p
}
